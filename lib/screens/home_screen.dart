import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:med4u/models/medecin.dart';
import 'package:med4u/widgets/affiche_rendez_tile.dart';
import '../widgets/filtrer_trie.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
  static List<AfficheRendezTile>? afficheRendezTileList;
}

class _HomeScreenState extends State<HomeScreen> {
  var user = FirebaseAuth.instance.currentUser!;
  final database = FirebaseDatabase.instance.ref();
  List? dataRendezList, listMedecinsId, medecinsList, rendez;

  late var listOfValue = HomeScreen.afficheRendezTileList;
  List listSortType = [
    'Nearest to farthest',
    'A-Z(title)',
    'A-Z(Doctors)',
    'Add recent'
  ];
  late String choosedType = listSortType[0];
  TextEditingController textController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void dispose() {
    super.dispose();
    textController.dispose();
  }

  Future<void> loadData() async {
    await _dataRendez();
    //listMedecinsId = _listMedecinsId(dataRendezList!);
    //medecinsList = await _medecinsList(listMedecinsId!);
    HomeScreen.afficheRendezTileList =
        _afficheRendezTileList(dataRendezList!, medecinsList!)
            as List<AfficheRendezTile>;
    setState(() {});
    trierList(choosedType);
  }

  Future<void> _dataRendez() async {
    final Completer<void> completer = Completer<void>();
    database
        .child('rendez')
        .orderByChild('idPatient')
        .equalTo(user.uid)
        .onValue
        .listen((event) async {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        dataRendezList = data.values
            .map((e) => e)
            .where((element) => DateTime(element['year'], element['month'],
                    element['day'], element['hour'], element['minute'])
                .isAfter(DateTime.now()))
            .toList();
      } else {
        HomeScreen.afficheRendezTileList = [];
        dataRendezList = [];
      }
      listMedecinsId = _listMedecinsId(dataRendezList!);
      medecinsList = await _medecinsList(listMedecinsId!);
      HomeScreen.afficheRendezTileList =
          _afficheRendezTileList(dataRendezList!, medecinsList!)
              as List<AfficheRendezTile>;
      trierList(choosedType);
      //setState(() {dataRendezList = dataRendezListe;});

      // Renvoyer les données une fois qu'elles sont prêtes
      setState(() {});
      completer.complete();
    });
    return completer.future;
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

  List<dynamic> _listMedecinsId(List dataRendezList) {
    List listMedecinsId = [];
    for (int i = 0; i < dataRendezList.length; i++) {
      if (!listMedecinsId.contains(dataRendezList[i]['idMedecin'])) {
        listMedecinsId.add(dataRendezList[i]['idMedecin']);
      }
    }
    return listMedecinsId;
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
      ));
    }
    return afficheRendezTileList;
  }

  void trierList(String? val) {
    List<AfficheRendezTile> sortedList = [...HomeScreen.afficheRendezTileList!];

    if (val == 'Nearest to farthest') {
      sortedList.sort((a, b) => a.dateRendez.compareTo(b.dateRendez));
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
    listOfValue = HomeScreen.afficheRendezTileList!
        .where((element) => element.title.contains(value))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        loadData();
      });
    });
    if (HomeScreen.afficheRendezTileList == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (!HomeScreen.afficheRendezTileList!.isEmpty) {
      return Scaffold(
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
      );
    } else {
      return Scaffold(
        body: Center(
          child: Text(
            'you dont have any appointement yet!',
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
