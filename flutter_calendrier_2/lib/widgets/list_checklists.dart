import 'package:flutter/material.dart';

class ListCheckmarks extends StatefulWidget {
  const ListCheckmarks({Key? key}) : super(key: key);

  @override
  State<ListCheckmarks> createState() => _ListCheckmarksState();
}

class _ListCheckmarksState extends State<ListCheckmarks> {
  @override
  Widget build(BuildContext context) {
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
                  children: [],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Ajouter une liste'),
                Icon(Icons.add),
              ],
            ),
          )
        ]
    );
  }
}
