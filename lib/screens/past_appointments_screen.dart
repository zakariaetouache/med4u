import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../models/medecin.dart';
import '../widgets/affiche_rendez_tile.dart';
import '../widgets/filtrer_trie.dart';

class PastAppointementsScreen extends StatefulWidget {
  @override
  State<PastAppointementsScreen> createState() =>
      _PastAppointementsScreenState();
}

class _PastAppointementsScreenState extends State<PastAppointementsScreen> {
  final database = FirebaseDatabase.instance.ref();

  final user = FirebaseAuth.instance.currentUser;
  List? dataRendezList, listMedecinsId, medecinsList;
  List<AfficheRendezTile>? afficheRendezTileList = [];
  late var listOfValue = afficheRendezTileList;
  List listSortType = [
    'Recent',
    'A-Z(title)',
    'A-Z(Doctors)',
  ];
  TextEditingController textController = TextEditingController();
  late String choosedType = listSortType[0];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await _dataRendez();
    afficheRendezTileList =
        _afficheRendezTileList(dataRendezList!, medecinsList!)
            as List<AfficheRendezTile>;
    setState(() {});
    trierList(choosedType);
  }

  Future<void> _dataRendez() async {
    Completer<void> completer = Completer<void>();
    final event = await database
        .child('rendez')
        .orderByChild('idPatient')
        .equalTo(user!.uid)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      dataRendezList = data.values
          .map((e) => e)
          .where((element) => DateTime(element['year'], element['month'],
                  element['day'], element['hour'], element['minute'])
              .isBefore(DateTime.now()))
          .toList();
      listMedecinsId = _listMedecinsId(dataRendezList!);
      medecinsList = await _medecinsList(listMedecinsId!);
      afficheRendezTileList =
          _afficheRendezTileList(dataRendezList!, medecinsList!)
              as List<AfficheRendezTile>;
    }
    completer.complete();
    return completer.future;
  }

  List<dynamic> _listMedecinsId(List dataRendezList) {
    List listMedecinsId = [];
    for (int i = 0; i < dataRendezList.length; i++) {
      if (!listMedecinsId.contains(dataRendezList[i]['idMedecin'])) {
        listMedecinsId.add(dataRendezList[i]['idMedecin']);
      }
    }
    return listMedecinsId;
  }

  Future<List<dynamic>> _medecinsList(List listMedecinsId) async {
    List medecinsList;
    final event = await database.child('medecinsUsers').once();
    final data = event.snapshot.value as Map;

    medecinsList = data.values
        .map((e) => Medecin(
            dur: e['dur'],
            id: e['id'],
            nom: e['nom'],
            prenom: e['prenom'],
            adress: e['adress'],
            ville: e['ville'],
            imageUrl: e['imageUrl'],
            e_mail: e['e_mail'],
            tel: e['tel'],
            nomCat: e['nomCat']))
        .where((element) => listMedecinsId.contains(element.id))
        .toList();
    return medecinsList;
  }

  List _afficheRendezTileList(List dataRendezList, List medecinsList) {
    List<AfficheRendezTile> afficheRendezTileList = [];
    for (int i = 0; i < dataRendezList.length; i++) {
      afficheRendezTileList.add(AfficheRendezTile(
        title: dataRendezList[i]['title'],
        dateRendez: DateTime(
            dataRendezList[i]['year'],
            dataRendezList[i]['month'],
            dataRendezList[i]['day'],
            dataRendezList[i]['hour'],
            dataRendezList[i]['minute']),
        ajouterTime: dataRendezList[i]['ajouterTime'],
        medecin: medecinsList[medecinsList.indexWhere((element) =>
            element.id == dataRendezList[i]['idMedecin'].toString())],
        press: false,
      ));
    }
    return afficheRendezTileList;
  }

  void trierList(String? val) {
    List<AfficheRendezTile> sortedList = [...afficheRendezTileList!];

    if (val == 'Nearest to farthest') {
      sortedList.sort((b, a) => a.dateRendez.compareTo(b.dateRendez));
    } else if (val == 'A-Z(title)') {
      sortedList.sort((a, b) => a.title.compareTo(b.title));
    } else if (val == 'A-Z(Doctors)') {
      sortedList.sort((a, b) => a.medecin.nom.compareTo(b.medecin.nom));
    } else if (val == 'Add recent') {
      sortedList.sort((b, a) => a.ajouterTime.compareTo(b.ajouterTime));
    }

    setState(() {
      choosedType = val as String;
      listOfValue = sortedList;
    });
  }

  void textFieldFunction(String value) {
    listOfValue = afficheRendezTileList!
        .where((element) => element.title.contains(value))
        .toList();
    setState(() {});
  }

  Widget build(BuildContext context) {
    if (afficheRendezTileList == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (!afficheRendezTileList!.isEmpty) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade600,
            title: Text(
              'Appointments passed',
            ),
          ),
          body: Column(
            children: [
              Container(
                child: FiltrerTrier(
                  textController: textController,
                  hintTextTextController: 'Find an appointment',
                  textFieldFunction: textFieldFunction,
                  dropDownTitle: 'Sort',
                  dropDownIcon: Icons.sort,
                  listType: listSortType,
                  ch: trierList,
                  color: Colors.grey.shade200,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      NewWidget(listOfValue: listOfValue),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Text(
            'you don\'t have any appointment passed',
          ),
        ),
      );
    }
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({
    super.key,
    required this.listOfValue,
  });

  final List<AfficheRendezTile>? listOfValue;

  @override
  Widget build(BuildContext context) {
    if (listOfValue!.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: listOfValue!,
        ),
      );
    } else {
      return Row(
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
      );
    }
  }
}
