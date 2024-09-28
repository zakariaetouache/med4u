import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:med4u/widgets/category_item.dart';
import 'package:med4u/widgets/category_medecin_item.dart';
import 'package:med4u/widgets/filtrer_trie.dart';

class CategoryMedecinsScreen extends StatefulWidget {
  @override
  State<CategoryMedecinsScreen> createState() => _CategoryMedecinsScreenState();
}

class _CategoryMedecinsScreenState extends State<CategoryMedecinsScreen> {
  final database = FirebaseDatabase.instance.ref();
  List<CategoryMedecinItem>? listmedecins;
  late List<CategoryMedecinItem>? listMedecinsAfficher = listmedecins;
  late String categoryTitle;
  late String categoryId;
  TextEditingController medecinstextController = TextEditingController();
  var listCities = [];
  late bool b;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgument =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    categoryId = routeArgument['id']!;
    categoryTitle = routeArgument['title']!;
    b = routeArgument['b'];
    _activateListeners();
  }

  void _activateListeners() async {
    final event = await database
        .child('medecinsUsers')
        .orderByChild('categoryId')
        .equalTo('$categoryId')
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      listmedecins = data.values
          .map((e) => CategoryMedecinItem(
              id: e['id'],
              nom: e['nom'],
              prenom: e['prenom'],
              imageUrl: e['imageUrl'],
              adress: e['adress'],
              ville: e['ville'],
              b: b,))
          .toList();
      listCities = listmedecins!.map((e) => e.ville).toSet().toList();
      listCities.sort((a, b) => a.toString().compareTo(b.toString()));
    } else {
      listmedecins = [];
    }
    setState(() {});
    ch(listCities[0]);
  }

  void textFieldFunction(String value) {
    listMedecinsAfficher = listmedecins!
        .map((e) => e)
        .where((element) =>
            element.nom.contains(value) || element.prenom.contains(value))
        .toList();
    setState(() {});
  }

  void ch(String? value) {
    listMedecinsAfficher = listmedecins!
        .map((e) => e)
        .where((element) => element.ville.contains(value!))
        .toList();
    setState(() {});
  }

  Future<void> delCat() async {
    final event = await database
        .child('categoryItem')
        .orderByChild('id')
        .equalTo(categoryId)
        .once();
    final data = event.snapshot.value as Map;
    final ref = data.keys.first;
    await database.child('categoryItem').child(ref).remove();
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    /*final routeArgument =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    //categoryId = routeArgument['id']!;
    //categoryTitle = routeArgument['title']!;
    b = routeArgument['b'];*/
    if (listmedecins == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade600,
          title: Text(
            categoryTitle,
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (listmedecins!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            if (b)
              IconButton(
                iconSize: 35,
                onPressed: () => delCat(),
                icon: Icon(
                  Icons.delete,
                  color: Colors.yellow.shade900,
                ),
              ),
          ],
          backgroundColor: Colors.grey.shade600,
          title: Text(
            categoryTitle,
          ),
        ),
        body: Center(
          child: Text(
            'no medecins for this moment',
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          actions: [
            if (b)
              IconButton(
                iconSize: 35,
                onPressed: () => delCat(),
                icon: Icon(
                  Icons.delete,
                  color: Colors.yellow.shade900,
                ),
              ),
          ],
          backgroundColor: Colors.grey.shade600,
          title: Text(
            categoryTitle,
          ),
        ),
        body: Column(
          children: [
            FiltrerTrier(
              textController: medecinstextController,
              hintTextTextController: 'find a doctor',
              textFieldFunction: textFieldFunction,
              dropDownTitle: 'Filter by cities',
              dropDownIcon: Icons.location_on,
              listType: listCities,
              ch: ch,
              color: Colors.grey.shade200,
            ),
            if (listMedecinsAfficher!.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: listMedecinsAfficher!,
                  ),
                ),
              ),
            if (listMedecinsAfficher!.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    }
  }
}
