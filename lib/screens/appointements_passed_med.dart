import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../models/patient.dart';
import '../widgets/affiche_rendez_tile_med.dart';

class AppointementsPassedMed extends StatefulWidget {
  const AppointementsPassedMed({super.key});

  @override
  State<AppointementsPassedMed> createState() => _AppointementsPassedMedState();
}

class _AppointementsPassedMedState extends State<AppointementsPassedMed> {
  final User user = FirebaseAuth.instance.currentUser!;

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
        .equalTo(user.uid)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      rd = data.values
          .map((e) => e)
          .where((element) => DateTime(element['year'], element['month'],
                  element['day'], element['hour'], element['minute'])
              .isBefore(DateTime.now()))
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
        .sort((b, a) => a.dateTime.toString().compareTo(b.dateTime.toString()));
  }

  @override
  Widget build(BuildContext context) {
    if (listRendez == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      if (listRendez!.isEmpty) {
        return Scaffold(
          body: Center(
            child: Text(
              'You dont\'t have any appointment passed',
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade600,
            title: Text('Passed appointments'),
          ),
          body: ListView(
            children: listRendez!,
          ),
        );
      }
    }
  }
}
