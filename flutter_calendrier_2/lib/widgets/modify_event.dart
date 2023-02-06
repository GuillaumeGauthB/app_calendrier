import 'package:flutter/material.dart';
import '../res/events.dart';
import 'add_event.dart';

/**
 *
 * REMANT D'UN VIEU MORCEAU DE CODE
 *
 * NE SAIS PAS ENCORE SI DOIT DELETE
 *
 */

class ModifyEvent extends StatefulWidget {
  //const ModifyEvent({Key? key}) : super(key: key);
  late int id;

  ModifyEvent(this.id);

  @override
  State<ModifyEvent> createState() => _ModifyEventState(this.id);
}

class _ModifyEventState extends State<ModifyEvent> {
  late int id;

  _ModifyEventState(this.id);

  @override
  Widget build(BuildContext context) {
    //print('current element: ${tableaux_evenements.singleWhere((e) => e['id'] == id)}');
    return AddEvent({'id': id});
  }
}
