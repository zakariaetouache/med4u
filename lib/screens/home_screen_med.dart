import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:med4u/models/medecin.dart';
import 'package:med4u/models/patient.dart';
import 'package:med4u/widgets/affiche_rendez_tile.dart';
import 'package:med4u/widgets/affiche_rendez_tile_med.dart';

class HomeScreenMed extends StatefulWidget {
  Medecin medecin;

  HomeScreenMed({required this.medecin});

  @override
  State<HomeScreenMed> createState() => _HomeScreenMedState();
}

class _HomeScreenMedState extends State<HomeScreenMed> {
  @override
  void initState() {
    super.initState();
    loadDate();
  }

  final database = FirebaseDatabase.instance.ref();
  List listPatients = [];
  List listIdPatients = [];
  List rendezData = [];
  List<AfficheRendezTileMed>? listRendez;

  void loadDate() async {
    await dataRendez();
    _listIdPatients();
    await _listPatients();
    _listAfficheRendezTile();
  }

  Future<void> dataRendez() async {
    Completer<void> completer = Completer<void>();
    List rd = [];
    final event = await database
        .child('rendez')
        .orderByChild('idMedecin')
        .equalTo(widget.medecin.id)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      rd = data.values
          .map((e) => e)
          .where((element) => DateTime(element['year'], element['month'],
                  element['day'], element['hour'], element['minute'])
              .isAfter(DateTime.now()))
          .toList();
    }
    rendezData = rd;
    setState(() {});
    completer.complete();
    return completer.future;
  }

  void _listIdPatients() {
    for (int i = 0; i < rendezData.length; i++) {
      if (!listIdPatients.contains(rendezData[i]['idPatient'])) {
        listIdPatients.add(rendezData[i]['idPatient']);
      }
    }
  }

  Future<void> _listPatients() async {
    final event = await database.child('patientsUsers').once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      listPatients = data.values
          .map((e) => Patient(
              prenom: e['prenom'],
              nom: e['nom'],
              tel: e['tel'],
              email: e['email'],
              idPatient: e['idPatient']))
          .where((element) => listIdPatients.contains(element.idPatient))
          .toList();
    } else {
      listIdPatients = [];
    }
    setState(() {});
  }

  void _listAfficheRendezTile() {
    Patient _patient;
    List<AfficheRendezTileMed> listRend = [];
    for (int i = 0; i < rendezData.length; i++) {
      _patient = listPatients.firstWhere(
          (element) => element.idPatient == rendezData[i]['idPatient']);
      listRend.add(AfficheRendezTileMed(
          prenom: _patient.prenom,
          nom: _patient.nom,
          tel: _patient.tel,
          dateTime: DateTime(
            rendezData[i]['year'],
            rendezData[i]['month'],
            rendezData[i]['day'],
            rendezData[i]['hour'],
            rendezData[i]['minute'],
          )));
    }
    setState(() {
      listRendez = listRend;
    });
    listRendez!
        .sort((a, b) => a.dateTime.toString().compareTo(b.dateTime.toString()));
  }

  @override
  Widget build(BuildContext context) {
    if (listRendez == null) {
      return ScaffoldMessenger(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    } else {
      if (listRendez!.isNotEmpty) {
        return Scaffold(
          body: ListView(
            children: listRendez!,
          ),
        );
      } else {
        return Scaffold(
          body: Center(
            child: Text(
              'You don\'t Have any appointement',
            ),
          ),
        );
      }
    }
  }
}
