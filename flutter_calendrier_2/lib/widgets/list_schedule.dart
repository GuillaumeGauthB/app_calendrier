import 'package:flutter/material.dart';
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
      for(Map<String, dynamic> listeItem in listeHoraires){
        toPrint.add(
          GestureDetector(
            onTap: () {
              printModalBox(AddSchedule(id: listeItem['id']));
            },
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.20,
                child: Container(
                    decoration: BoxDecoration(
                        color: listeItem['color'].runtimeType == int ? Color(listeItem['color']) : Colors.transparent,
                        border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('${listeItem['name'] ?? 'Horaire sans nom'}'),
                            Text('${listeItem['color'] ?? 'Horaire sans couleur'}'),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_outlined,
                        )
                      ],
                    )
                )
            ),
          )
        );



        /// sert a rien sauf tester
        /*
        for(int i = 0; i < 50; i++){
          toPrint.add(
              GestureDetector(
                onTap: () {
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
                            child:Placeholder()
                        );
                      }
                  ).whenComplete(() => {setState(() {})});
                },
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: Container(
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black, width: 3))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('${listeItem['name'] ?? 'Horaire sans nom'}'),
                                Text('${listeItem['color'] ?? 'Horaire sans couleur'}'),
                              ],
                            ),
                            const Icon(
                              Icons.arrow_forward_outlined,
                            )
                          ],
                        )
                    )
                ),
              )
          );
        }
        */
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