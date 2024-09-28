import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:med4u/widgets/category_item.dart';
import 'package:med4u/widgets/category_medecin_item.dart';
import 'package:med4u/widgets/filtrer_trie.dart';

class SearchScreen extends StatefulWidget {
  final bool b;
  const SearchScreen({this.b = false});
  static Future<void> setchage() async {
    _SearchScreenState().loadData();
  }

  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _database = FirebaseDatabase.instance.ref();
  late List<CategoryItem> listItem = [];
  late List<CategoryItem>? listItemAfficher = listItem;
  //late StreamSubscription _dailySpecialStream;
  TextEditingController textEditingController = TextEditingController();
  late List<CategoryMedecinItem> listMedecinsItem;
  late List<CategoryMedecinItem>? listMedecinsItemAfficher = listMedecinsItem;
  List _list = [
    'Specialties',
    'Doctors',
  ];
  late String choosedType = _list[0];
  //String setHintText = 'Search for a specialty';
  bool k = true;

  @override
  /*void deactivate() {
    _dailySpecialStream.cancel();
    super.deactivate();
  }*/

  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    _activateListeners();
    await listMedecin();
    setState(() {
      k = false;
    });
  }

  void _activateListeners() {
    _database.child("categoryItem").onValue.listen((event) {
      final Map<dynamic, dynamic> data = event.snapshot.value as Map;
      if (data == null) {
        return;
      }
      setState(() {
        listItem = data.entries
            .map((entry) => CategoryItem(
                  id: entry.value['id'],
                  title: entry.value['title'],
                  imageUrl: entry.value['imageUrl'],
                  b: widget.b,
                ))
            .toList();
      });
      listItem.sort((a, b) => a.title.compareTo(b.title));
    });
  }

  void choosedTypFunction(String? val) {
    setState(() {
      choosedType = val as String;
    });
  }

  Future listMedecin() async {
    final event = await _database.child('medecinsUsers').once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      listMedecinsItem = data.values
          .map((e) => CategoryMedecinItem(
                id: e['id'],
                nom: e['nom'],
                prenom: e['prenom'],
                imageUrl: e['imageUrl'],
                adress: e['adress'],
                ville: e['ville'],
                nomCat: e['nomCat'],
                b: widget.b,
              ))
          .toList();
    } else {
      listMedecinsItem = [];
    }
    setState(() {});
  }

  void textFieldFunction(String text) {
    if (choosedType == 'Specialties') {
      final List<CategoryItem> listCategory;
      listCategory = listItem
          .where((element) =>
              element.title.toLowerCase().contains(text.toLowerCase()))
          .toList();
      setState(() {
        listItemAfficher = listCategory;
      });
    }
    if (choosedType == 'Doctors') {
      final List<CategoryMedecinItem> listMedecin;
      listMedecin = listMedecinsItem
          .where((element) =>
              element.nom.toLowerCase().contains(text.toLowerCase()) ||
              element.prenom.toLowerCase().contains(text.toLowerCase()) ||
              element.ville.toLowerCase().contains(text.toLowerCase()))
          .toList();
      setState(() {
        listMedecinsItemAfficher = listMedecin;
      });
    }
  }

  Widget build(BuildContext context) {
    if (k) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FiltrerTrier(
          hintTextTextController: choosedType == 'Doctors'
              ? 'Find a Doctor'
              : 'Search for a specialty',
          textController: textEditingController,
          textFieldFunction: textFieldFunction,
          dropDownTitle: 'dropDownTitle',
          dropDownIcon: null,
          listType: _list,
          ch: choosedTypFunction,
          color: Colors.grey.shade200,
        ),
        if (choosedType == 'Specialties')
          Expanded(
            child: GridView(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 7 / 8,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              children: listItemAfficher!,
            ),
          ),
        if (choosedType == 'Doctors')
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: listMedecinsItemAfficher!,
            ),
          ))
      ],
    );
  }
}
/*.map((item) => CategoryItem(
              id: item.id, title: item.title, imageUrl: item.imageUrl))
          .toList(),*/