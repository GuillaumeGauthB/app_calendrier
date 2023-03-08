import 'dart:convert'; // pour convertir en JSON
import 'dart:io'; // pour ecriture de fichiers
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_calendrier_2/widgets/refresh_data.dart';
import 'package:path_provider/path_provider.dart'; // pour trouver la location du dossier

import '../res/checklists.dart';
import '../res/events.dart';
import '../res/settings.dart';

enum OperationType {
  addition,
  modification,
  deletion,
  settings
}

// Classe servant a la lecture du fichier data.json de l'utilisateur
class FileUtils {
  /// Methode initialisant les fichiers de l'application
  /// Retourne une string permettant de savoir ce qui a ete initialiser
  static Future<String> get init async{
    /// Liste du contenu du dossier principal de l'application
    List directoryContents = await getDirectoryContent;
    /// Fichiers du type File dans le dossier
    Iterable directoryContentsFile = directoryContents.whereType<File>();
    /// String d'information disant quels fichiers ont ete creer
    String stringToReturn = '';
    /// si le fichier d'evenement n'existe pas, le creer avec un template
    /// Faire la mm chose pour tous les autres fichiers
    if(directoryContentsFile.where((element) => element.path.contains('data.json')).isEmpty){
      await saveToFile(data: jsonEncode(
          [
            {
              'emptySettingsTemplate': 'Empty Settings'
            }
          ]
      ));
      await RefreshData.getData(collection: Collections.Calendrier);
      stringToReturn += 'evenements';
    }

    if(directoryContentsFile.where((element) => element.path.contains('settings.json')).isEmpty){
      await saveToFile(data: jsonEncode(
        {
          'emptySettingsTemplate': 'Empty Settings'
        }
      ), fileName: 'settings.json');
      // RefreshData.getData(collection: Collections.Calendrier);
      stringToReturn += '__settings';
    }

    if(directoryContentsFile.where((element) => element.path.contains('horaires.json')).isEmpty){
      await saveToFile(data: jsonEncode(
          [
            {
              'emptySettingsTemplate': 'Empty Settings'
            }
          ]
      ), fileName: 'horaires.json');
      await RefreshData.getData(collection: Collections.Horaires);
      stringToReturn += '__horaires';
    }

    if(directoryContentsFile.where((element) => element.path.contains('checklists.json')).isEmpty){
      await saveToFile(data: jsonEncode(
          [
            {
              'emptySettingsTemplate': 'Empty Settings'
            }
          ]
      ), fileName: 'checklists.json');
      await RefreshData.getData(collection: Collections.Checklists);
      stringToReturn += '__checklists';
    }

    /// Retourner la liste des fichiers creer
    return stringToReturn;
  }

  /// Initialisation des listes a utiliser
  static Future<void> get listInit async {
    print(await FileUtils.init);
    app_settings = jsonDecode(await FileUtils.readFromFile(fileName: 'settings.json'));
    listeHoraires = jsonDecode(await FileUtils.readFromFile(fileName: 'horaires.json'));
    listeHoraires = jsonDecode(await FileUtils.readFromFile(fileName: 'horaires.json'));
    listeChecklists = jsonDecode(await FileUtils.readFromFile(fileName: 'checklists.json'));
    tableaux_evenements = jsonDecode(await FileUtils.readFromFile());
  }

  /// Retourner le path de l'application
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Retourner le fichier a modifier
  static Future<File> getFile({required String file}) async{
    final path = await getFilePath;
    return File('$path/$file');
  }

  /// Retourner le fichier modifier
  static Future<File> saveToFile(
      {
        required String data,
        String fileName = 'data.json'
      }
    ) async {
    final file = await getFile(file: fileName);
    return file.writeAsString(data);
  }

  /// fonction de test
  /// Retourner le contenu du dossier principal de l'application
  static Future<List<FileSystemEntity>> get getDirectoryContent async{
    final dir = Directory(await getFilePath);
    return await dir.list().toList();
  }

  /// Retourne soit le contenu du fichier ou sa location (pour debugging)
  static Future<String> readFromFile({String fileName = 'data.json'}) async{
    try{
      final file = await getFile(file: fileName);
      String fileContents = await file.readAsString();
      return fileContents.toString();
    }catch(e){
      return await getFilePath;
    }
  }

  /// Modifier la base de donnee
  static modifyDB({
    required String collection,
    required Object eventToAdd,
    int id = -1,
    OperationType mode = OperationType.addition,
  }) {
    /// Reference a la collection a modifier
    final CollectionReference collectionRef = FirebaseFirestore.instance
                                                        .collection(collection);
    /// Reference au document a modifier (s'il existe deja)
    QuerySnapshot? docRef;
    /// L'ID du document (s'il existe deja)
    String documentID = '';

    /// Executer une transaction avec le serveur
    FirebaseFirestore.instance.runTransaction((transaction) async => {
      /// Si on ajoute, ajouter a la base de donnee,
      /// Sinon, chercher le document et le modifier
      if(mode == OperationType.addition){
        await collectionRef.add(eventToAdd),
      } else {
        docRef = await collectionRef.where("id", isEqualTo: id).limit(1).get(),
        /// Si le document existe, modifier le document, sinon, erreur
        /// Si il y a une erreur et que le mode est modification, ajouter le
        /// document
        if(docRef!.docs.isNotEmpty
                        && docRef?.docs[0].reference.id.runtimeType == String){
          documentID = docRef?.docs[0].reference.id as String,
          /// Si on modifier, modifier
          /// Sinon, supprimer le document
          if( mode == OperationType.modification){
            collectionRef.doc(documentID).set(eventToAdd,
                                                      SetOptions(merge: true)),
          }
          else{
            collectionRef.doc(documentID).delete(),
          }
        } else if(mode == OperationType.modification) {
          print('Document does not exist'),
          await collectionRef.add(eventToAdd),
        }
      }
    });
  }

  /// Retourner le fichier modifier
  static Future<File> modifyFile(
      {
        Object itemToAdd = const {},
        String collection = 'Calendrier',
        OperationType mode = OperationType.addition,
        id,
        String fileName = 'data.json'
      }
    ) async{
    /// le fichier a modifier
    final file = await getFile(file: fileName);

    /// Si les settings ne sont pas modifier, faire des manipulations uniques aux
    /// autres fichiers
    if(mode != OperationType.settings){
      /// Liste du contenu du fichier
      List json = jsonDecode(await FileUtils.readFromFile(fileName: fileName));

      /// Si on ajoute pas, supprimer l'original
      if(mode != OperationType.addition) {
        json.removeWhere((e) => e['id'] == id);
      }

      /// Si on ne supprime pas, ajouter l'item
      if(mode != OperationType.deletion) {
        json.add(itemToAdd);
      }

      /// Modifier la base de donnee avec les informations necessaires
      modifyDB(
          collection: collection,
          mode: mode,
          eventToAdd: itemToAdd,
          id: (id.runtimeType != Null ? id : -1)
      );

      /// Retourner le fichier modifier
      return file.writeAsString(jsonEncode(json));
    } else{
      /// Retourner le fichier modifier
      return file.writeAsString(jsonEncode(itemToAdd));
    }
  }

  /// Retourne le dernier int a ajouter
  static int getNewID({required itemList}) {
    /// Liste contenant tous les id
    List tableau_id = [];
    if(itemList.isNotEmpty){
      itemList.forEach((x) => {if(x['id'] != null) tableau_id.add(x['id'])});
    }

    /// L'id a retourner
    int currentId = 0;

    /// Si la liste n'est pas vide, retourner l'id le plus elever incrementer de 1
    if(tableau_id.length > 0){
      currentId = tableau_id.reduce((value, element) => value > element ? value : element);
      currentId++;
    }

    /// Retourner l'id
    return currentId;
  }
}