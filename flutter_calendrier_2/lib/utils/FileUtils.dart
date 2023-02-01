import 'dart:convert'; // pour convertir en JSON
import 'dart:io'; // pour ecriture de fichiers
import 'package:path_provider/path_provider.dart'; // pour trouver la location du dossier

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

  /// Fonction qui modifie le contenu du fichier de sauvegarde
  static Future<File> modifyFile(Object eventToAdd, {String mode = "ajouter", id}) async{
    final file = await getFile;
    List json = jsonDecode(await FileUtils.readFromFile);

    if(mode != 'ajouter') {
      json.removeWhere((e) => e['id'] == id);
    }

    if(mode != 'supprimer') {
      json.add(eventToAdd);
    }

    return file.writeAsString(jsonEncode(json));
  }
}