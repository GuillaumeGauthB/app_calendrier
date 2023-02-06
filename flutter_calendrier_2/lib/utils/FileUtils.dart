import 'dart:convert'; // pour convertir en JSON
import 'dart:io'; // pour ecriture de fichiers
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart'; // pour trouver la location du dossier
import 'package:firebase_core/firebase_core.dart';

int testState = 0;

// Classe servant a la lecture du fichier data.json de l'utilisateur
class FileUtils {
  /// Getter servant a a prendre le path du fichier a modifier
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Getter a selectionner le fichier a modifier
  static Future<File> get getFile async{
    final path = await getFilePath;
    return File('$path/data.json');
  }

  /// Setter servant a modifier le fichier data.json
  static Future<File> saveToFile(String data) async{
    final file = await getFile;
    return file.writeAsString(data);
  }

  /// fonction de test servant a lire le contenu des dossiers locaux
  static Future<List<FileSystemEntity>> get getDirectoryContent async{
    final dir = Directory(await getFilePath + "/flutter_assets");
    return await dir.list().toList();
  }

  /// Fonction servant a lire le contenu du fichier modifier
  static Future<String> get readFromFile async{
    try{
      final file = await getFile;
      String fileContents = await file.readAsString();
      return fileContents.toString();
    }catch(e){
      return await getFilePath;
    }
  }

  static modifyDB({required String collection, int id = -1, String mode = 'ajouter', required Object eventToAdd}) {
    final CollectionReference collectionRef = FirebaseFirestore.instance.collection(collection);
    QuerySnapshot? docRef;
    String documentID = '';
    FirebaseFirestore.instance.runTransaction((transaction) async => {
      if(mode == 'ajouter'){
        await collectionRef.add(eventToAdd),
      } else {
        docRef = await collectionRef.where("id", isEqualTo: id).limit(1).get(),
        if(docRef?.docs[0].reference.id.runtimeType == String){
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
  static Future<File> modifyFile(Object eventToAdd, {String mode = "ajouter", id}) async{
    final file = await getFile;
    late DocumentReference docRef;
    List json = jsonDecode(await FileUtils.readFromFile);
    
    if(mode != 'ajouter') {
      json.removeWhere((e) => e['id'] == id);
    }

    if(mode != 'supprimer') {
      json.add(eventToAdd);
    }

    modifyDB(collection: 'Calendrier', mode: mode, eventToAdd: eventToAdd, id: (id.runtimeType.toString() != 'Null' ? id : -1));

    /*final CollectionReference ref = FirebaseFirestore.instance.collection('Calendrier');
    try{
      FirebaseFirestore.instance.runTransaction((transaction) async => {
        // lengthCollection = await ref.limit(1).get(),
        // TODO adapter ce code a la nouvelle maniere de faire
        // Si la collection est vide, creer un document
        //if(lengthCollection.docs.isEmpty){
        //  FirebaseFirestore.instance.collection('Calendrier').doc(documentID).set({})
        //},

        print(transaction),

        // TODO ajouter une maniere de checker si des evenements ont ete ajoutees offline, pis les faire update quand on revient en ligne
        await ref.add(eventToAdd),
        //await addToFile()
      });
    } on Exception catch(e){
      print('error:  $e');
    }*/

    return file.writeAsString(jsonEncode(json));
  }

  // static modifyEvents(Object event)
}