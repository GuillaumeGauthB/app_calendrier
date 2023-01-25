import 'dart:io'; // pour ecriture de fichiers
import 'package:path_provider/path_provider.dart'; // pour trouver la location du dossier

// Classe servant a la lecture du fichier data.json de l'utilisateur
class FileUtils {
  // Getter servant a a prendre le path du fichier a modifier
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Getter a selectionner le fichier a modifier
  static Future<File> get getFile async{
    final path = await getFilePath;
    return File('$path/data.json');
  }

  // Setter servant a modifier le fichier data.json
  static Future<File> saveToFile(String data) async{
    final file = await getFile;
    return file.writeAsString(data);
  }

  // fonction de test servant a lire le contenu des dossiers locaux
  static Future<List<FileSystemEntity>> get getDirectoryContent async{
    final dir = Directory(await getFilePath + "/flutter_assets");
    return await dir.list().toList();
  }

  // Fonction servant a lire le contenu du fichier modifier
  static Future<String> readFromFile() async{
    try{
      final file = await getFile;
      String fileContents = await file.readAsString();
      return fileContents.toString();
    }catch(e){
      return await getFilePath;
    }
  }
}