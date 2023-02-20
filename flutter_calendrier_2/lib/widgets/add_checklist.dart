import 'package:flutter/material.dart';

import '../res/checklists.dart';
import '../utils/file_utils.dart';

class AddChecklist extends StatefulWidget {
  const AddChecklist({Key? key, required this.id}) : super(key: key);

  final int? id;
  @override
  State<AddChecklist> createState() => _AddChecklistState(id: id);
}

class _AddChecklistState extends State<AddChecklist> {
  _AddChecklistState({required this.id});

  final int? id;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> listControllers = {
    'name': TextEditingController(),
    'description': TextEditingController(),
    'checkbox_1': TextEditingController(),
    'checkbox_2': TextEditingController(),
    'checkbox_3': TextEditingController(),
  };

  late int lengthNewCheckbox;

  @override void initState(){
    if(id != null){
      var currentItem = listChecklists.singleWhere((element) => element['id'] == id);
      listControllers['name'].text = currentItem['name'];
      listControllers['description'].text = currentItem['description'];
      for(var i in currentItem.keys.where((element) => element.contains('checkbox_') && !element.contains('completed')).toList()){
        listControllers[i] = TextEditingController(text: currentItem[i]);
      }
    }

    print(listControllers);
  }

  List get getFilledCheckbox {
    return listControllers.keys.where((element) => element.contains('checkbox_') && listControllers[element]?.text != '').toList();
  }

  @override
  Widget build(BuildContext context) {
    lengthNewCheckbox = listControllers.keys.where((element) => element.contains('checkbox_')).length;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ...getFormInputs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.40,
                      child: ElevatedButton(
                        onPressed: () {Navigator.pop(context);},
                        child: Text('Annuler'),
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: ElevatedButton(
                          onPressed: processingData,

                          child: Text( 'Ajouter'),
                        )
                    ),
                  ],
                )
              ]
            )
          ),
        ],
      ),
    );
  }

  List<Widget> get getFormInputs {
    return [
      /// Nom de la checklist
      TextFormField(
        decoration: const InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Nom',
          labelText: 'Nom de la checklist',
        ),
        controller: listControllers["name"],

        validator: (value) {
          // Empecher de sauvegarder un evenement sans titre
          if(value == null || value.isEmpty){
            return 'Veuillez saisir un titre';
          }
          return null;
        },
      ),
      /// Nom de la checklist
      TextFormField(
        decoration: const InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'Description',
          labelText: 'Description de la checklist',
        ),
        controller: listControllers["description"],

        validator: (value) {
          // Empecher de sauvegarder un evenement sans titre
          if(value == null || value.isEmpty){
            return 'Veuillez saisir un titre';
          }
          return null;
        },
      ),
      const Center(
        child: Text('Liste des checklists'),
      ),
      ...getNewChecklist,
      ElevatedButton(
        onPressed: () {
          listControllers['checkbox_${lengthNewCheckbox + 1}'] = TextEditingController();
          setState(() {

          });
        },
        child: Icon(Icons.add)
      ),
    ];
  }

  List<Widget> get getNewChecklist {
    List<Widget> toReturn = [];

    for(int i = 1; i <= lengthNewCheckbox; i++){
      toReturn.add(
        TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.check_circle_outline),
            hintText: 'Titre',
            labelText: 'Titre de la checkbox',
          ),
          controller: listControllers["checkbox_$i"],

          validator: (value) {
            if(i == 1){
              int filledCheckbox = getFilledCheckbox.length;
              // Empecher de sauvegarder un evenement sans titre
               //if(value == null || value.isEmpty){
              if(filledCheckbox == 0){
                return 'Veuillez créer au minimum une checkbox';
              }
            }
            return null;
          },
        ),
      );
    }


    return toReturn;
  }

  void processingData() {
    // Si le formulaire est valider...
    if (_formKey.currentState!.validate()) {
      int currentId = id ?? FileUtils.getNewID(itemList: listChecklists);

      Map<String, dynamic> checklistToAdd = {
        // 'id': (gestionClasse == 'modifier' ? parentParameters['id'] : currentId),
        'id': currentId,
        'name': '${listControllers["name"]?.text}',
        'description': '${listControllers["description"]?.text}',
        'completed': false,
      };

      int loop = 1;
      for(var checkboxKey in getFilledCheckbox){
        checklistToAdd['checkbox_$loop'] = listControllers[checkboxKey]?.text;
        checklistToAdd['checkbox_${loop}_completed'] = false;
        loop++;
      }

      if(listChecklists.isNotEmpty && id != null){
        listChecklists.removeWhere((e) => e['id'] == id);
      }

      // Ajouter la nouvelle checklist au tableau local
      listChecklists.add(checklistToAdd);

      // Appeler la methode de la classe static pour envoyer nos modifications dans le fichier local json et dans la base de donnee
      FileUtils.modifyFile(checklistToAdd, collection: 'Checklists', mode: id == null ? 'ajouter' : 'modifier', id: currentId, fileName: 'checklists.json');

      // Faire apparaitre un snackbar pour dire que le tout a fonctionner
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajout de l\'évènement')),
      );
      Navigator.pop(context);
    }
  }
}
