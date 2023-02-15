import 'package:flutter/material.dart';
import 'package:flutter_calendrier_2/utils/lists_manipulation.dart';
import '../res/settings.dart';
import 'add_schedule.dart';

class ListSchedule extends StatefulWidget {
  const ListSchedule({Key? key}) : super(key: key);

  @override
  State<ListSchedule> createState() => _ListScheduleState();
}

class _ListScheduleState extends State<ListSchedule> {
  List<Widget> toPrint = [];

  void printModalBox(Widget widgetToLoad) {
    showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        isDismissible: false,
        context: context,
        builder: (context) {
          /**
           * Class that adds event
           */
          return Container(
            // height: MediaQuery.of(context).size.height,
              child:widgetToLoad
          );
        }
    ).whenComplete(() => {setState(() {})});
  }

  @override
  Widget build(BuildContext context) {
    toPrint = [];
    if(listeHoraires.isNotEmpty){

      ListsManipulation.ListSchedule;

      for(Map<String, dynamic> listeItem in listeHoraires){
        late Color colorToUse;
        late Color colorToUseText;
        if(listeItem['color'].runtimeType == int){
          colorToUse = Color(listeItem['color']);
        }else if(listeItem['color'].runtimeType == Color){
          colorToUse = listeItem['color'];
        } else{
          colorToUse = Colors.transparent;
        }

        if(listeItem['color_frontend'].runtimeType == int){
          colorToUseText = Color(listeItem['color_frontend']);
        }else if(listeItem['color_frontend'].runtimeType == Color){
          colorToUseText = listeItem['color_frontend'];
        } else {
          colorToUseText = Colors.white;
        }

        toPrint.add(
          GestureDetector(
            onTap: () {
              printModalBox(AddSchedule(id: listeItem['id']));
            },
            child: Theme(
              data: ThemeData(
                textTheme: TextTheme(
                  bodyMedium: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: listeItem['color_font'].runtimeType == int ? Color(listeItem['color_font']) : Colors.black,
                  ),
                )
              ),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.20,
                  child: Container(
                      decoration: BoxDecoration(
                        color: colorToUse,
                        border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('${listeItem['name'] ?? 'Horaire sans nom'}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorToUseText)),
                              Text('${listeItem['color'] ?? 'Horaire sans couleur'}',  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorToUseText),),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_outlined,
                            color: colorToUseText,
                          )
                        ],
                      )
                  )
              ),
            )
          )
        );
      }
    } else {
      toPrint.add(
        Center(
          child: Text("Aucun horaire n'existe", style: Theme.of(context).textTheme.labelMedium,)
        )
      );
    }

    return Column(
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
          child: SizedBox(
            // height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: toPrint,
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => printModalBox(AddSchedule()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Ajouter un horaire'),
              Icon(Icons.add),
            ],
          ),
        )
      ]
    );
  }
}