import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../models/medecin.dart';
import '../widgets/category_medecin_item.dart';
import '../widgets/filtrer_trie.dart';

class DoctorsAppointmentScreen extends StatefulWidget {
  @override
  State<DoctorsAppointmentScreen> createState() =>
      _DoctorsAppointmentScreenState();
}

class _DoctorsAppointmentScreenState extends State<DoctorsAppointmentScreen> {
  final database = FirebaseDatabase.instance.ref();

  final user = FirebaseAuth.instance.currentUser;
  List? dataRendezList, listMedecinsId;
  late List<CategoryMedecinItem>? medecinsList = [],
      listMedecinsAfficher = medecinsList;
  TextEditingController medecinstextController = TextEditingController();
  var listCities = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await _dataRendez();
    setState(() {});
    //trierList(choosedType);
  }

  Future<void> _dataRendez() async {
    //Completer<void> completer = Completer<void>();
    print('load DAta');
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
              .isAfter(DateTime.now()))
          .toList();
      listMedecinsId = _listMedecinsId(dataRendezList!);

      medecinsList = await _medecinsList(listMedecinsId!);
      setState(() {
        listMedecinsAfficher = medecinsList;
      });
    } else {
      medecinsList = [];
    }
    //completer.complete();
    //return completer.future;
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

  Future<List<CategoryMedecinItem>> _medecinsList(List listMedecinsId) async {
    List<CategoryMedecinItem> medecinsList;
    final event = await database.child('medecinsUsers').once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      medecinsList = data.values
          .map((e) => CategoryMedecinItem(
                id: e['id'],
                nom: e['nom'],
                prenom: e['prenom'],
                imageUrl: e['imageUrl'],
                adress: e['adress'],
                ville: e['ville'],
                nomCat: e['nomCat'],
              ))
          .where((element) => listMedecinsId.contains(element.id))
          .toList();
      print('medecinsList ==== ${medecinsList[0].id}');
      listCities = medecinsList.map((e) => e.ville).toSet().toList();
      listCities.sort((a, b) => a.compareTo(b));
    } else {
      medecinsList = [];
    }
    ch(listCities[0]);
    return medecinsList;
  }

  void ch(String? value) {
    listMedecinsAfficher = medecinsList!
        .map((e) => e)
        .where((element) => element.ville.contains(value!))
        .toList();
    setState(() {});
  }

  void textFieldFunction(String value) {
    listMedecinsAfficher = medecinsList!
        .map((e) => e)
        .where((element) =>
            element.nom.contains(value) || element.prenom.contains(value))
        .toList();
    setState(() {});
  }

  Widget build(BuildContext context) {
    if (medecinsList == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade600,
          title: Text(
            'Doctors',
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (medecinsList!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade600,
          title: Text(
            'Doctors',
          ),
        ),
        body: Center(
          child: Text(
            'You don\'t have any appointment',
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade600,
          title: Text(
            'Doctors',
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
