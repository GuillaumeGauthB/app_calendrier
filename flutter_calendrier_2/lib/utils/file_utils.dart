import 'dart:convert'; // pour convertir en JSON
import 'dart:io'; // pour ecriture de fichiers
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart'; // pour trouver la location du dossier
import 'package:firebase_core/firebase_core.dart';

int testState = 0;

// Classe servant a la lecture du fichier data.json de l'utilisateur
class FileUtils {
  ///
  static Future<String> get init async{
    List directoryContents = await getDirectoryContent;
    Iterable directoryContentsFile = directoryContents.whereType<File>();
    String stringToReturn = '';
    if(directoryContentsFile.where((element) => element.path.contains('data.json')).isEmpty){
      await saveToFile(data: jsonEncode(
          [
            {
              'emptySettingsTemplate': 'Empty Settings'
            }
          ]
      ));
      stringToReturn += 'oui';
    }

    if(directoryContentsFile.where((element) => element.path.contains('settings.json')).isEmpty){
      await saveToFile(data: jsonEncode(
        {
          'emptySettingsTemplate': 'Empty Settings'
        }
      ), fileName: 'settings.json');
      stringToReturn += 'oui';
    }

    if(directoryContentsFile.where((element) => element.path.contains('horaires.json')).isEmpty){
      await saveToFile(data: jsonEncode(
          [
            {
              'emptySettingsTemplate': 'Empty Settings'
            }
          ]
      ), fileName: 'horaires.json');
      stringToReturn += 'oui';
    }

    if(directoryContentsFile.where((element) => element.path.contains('checklists.json')).isEmpty){
      await saveToFile(data: jsonEncode(
          [
            {
              'emptySettingsTemplate': 'Empty Settings'
            }
          ]
      ), fileName: 'checklists.json');
      stringToReturn += 'oui';
    }

    return stringToReturn;
    //return directoryContents.whereType<File>().where((element) => element.path.contains('data.json'));
  }

  /// Getter servant a a prendre le path du fichier a modifier
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Getter a selectionner le fichier a modifier
  static Future<File> getFile({required String file}) async{
    final path = await getFilePath;
    return File('$path/$file');
  }

  /// Setter servant a modifier le fichier data.json
  static Future<File> saveToFile({required String data, String fileName = 'data.json'}) async{
    final file = await getFile(file: fileName);
    return file.writeAsString(data);
  }

  /// fonction de test servant a lire le contenu des dossiers locaux
  static Future<List<FileSystemEntity>> get getDirectoryContent async{
    final dir = Directory(await getFilePath);
    return await dir.list().toList();
  }

  /// Fonction servant a lire le contenu du fichier modifier
  static Future<String> readFromFile({String fileName = 'data.json'}) async{
    try{
      final file = await getFile(file: fileName);
      String fileContents = await file.readAsString();
      return fileContents.toString();
    }catch(e){
      return await getFilePath;
    }
  }

  /// Methode qui modifie la base de donnee
  static modifyDB({required String collection, int id = -1, String mode = 'ajouter', required Object eventToAdd}) {
    final CollectionReference collectionRef = FirebaseFirestore.instance.collection(collection);
    QuerySnapshot? docRef;
    String documentID = '';
    FirebaseFirestore.instance.runTransaction((transaction) async => {
      if(mode == 'ajouter'){
        await collectionRef.add(eventToAdd),
      } else {
        docRef = await collectionRef.where("id", isEqualTo: id).limit(1).get(),
        if(docRef!.docs.isNotEmpty && docRef?.docs[0].reference.id.runtimeType == String){
          documentID = docRef?.docs[0].reference.id as String,
          if( mode == 'modifier'){
            collectionRef.doc(documentID).set(eventToAdd,SetOptions(merge: true)),
          }
          else{
            collectionRef.doc(documentID).delete(),
          }
        } else if(mode == 'modifier') {
          print('Document does not exist'),
          await collectionRef.add(eventToAdd),
        }
        //  FirebaseFirestore.instance.collection('Calendrier').doc(documentID).set({})
        //},
      }
    });
  }

  /// Fonction qui modifie le contenu du fichier de sauvegarde
  static Future<File> modifyFile(Object eventToAdd, {String collection = 'Calendrier', String mode = "ajouter", id, String fileName = 'data.json'}) async{
    final file = await getFile(file: fileName);

    if(mode != 'settings'){
      List json = jsonDecode(await FileUtils.readFromFile(fileName: fileName));

      if(mode != 'ajouter') {
        json.removeWhere((e) => e['id'] == id);
      }

      if(mode != 'supprimer') {
        json.add(eventToAdd);
      }

      modifyDB(collection: collection, mode: mode, eventToAdd: eventToAdd, id: (id.runtimeType != Null ? id : -1));

      return file.writeAsString(jsonEncode(json));
    } else{
      return file.writeAsString(jsonEncode(eventToAdd));
    }
  }

  /// Methode qui renvoit le nouvel id a ajouter
  static int getNewID({required itemList}) {
    List tableau_id = [];
    if(itemList.isNotEmpty){
      itemList.forEach((x) => {if(x['id'] != null) tableau_id.add(x['id'])});
    }

    int currentId = 0;

    if(tableau_id.length > 0){
      currentId = tableau_id.reduce((value, element) => value > element ? value : element);
      currentId++;
    }

    return currentId;
  }
}