import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med4u/main.dart';
import 'package:med4u/models/medecin.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:med4u/screens/home_screen.dart';
import 'package:med4u/screens/profil_medecin_screen.dart';
import '../models/rendez.dart';
import 'dart:async';

import '../widgets/info_rendez_item.dart';

class RendezDataScreen extends StatefulWidget {
  @override
  State<RendezDataScreen> createState() => _RendezDataScreenState();
}

class _RendezDataScreenState extends State<RendezDataScreen> {
  final database = FirebaseDatabase.instance.ref();
  late Medecin medecin;
  late int ajouterTime;
  DateTime dtn = DateTime.now();
  Rendez? rendez;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final routeArgument = ModalRoute.of(context)?.settings.arguments as Map;
    medecin = routeArgument['medecin'];
    ajouterTime = routeArgument['ajouterTime'];
    await loadData();
  }

  Future loadData() async {
    final event = await database
        .child('rendez')
        .orderByChild('ajouterTime')
        .equalTo(ajouterTime)
        .once();
    final dd = event.snapshot.value as Map;
    final data = dd.entries.first;
    final e = data.value as Map;
    rendez = Rendez(
      e['ajouterTime'],
      e['title'],
      e['note'],
      e['year'],
      e['month'],
      e['day'],
      e['hour'],
      e['minute'],
      e['dur'],
      e['idPatient'],
      e['idMedecin'],
      medecin,
    );
    setState(() {});
  }

  Future deleteRendez(BuildContext ctx) async {
    await database.child('rendezDelete').push().set({
      'ajouterTime': rendez!.ajouterTime,
      'day': rendez!.day,
      'dur': rendez!.dur,
      'hour': rendez!.hour,
      'idMedecin': rendez!.idMedecin,
      'idPatient': rendez!.idPatient,
      'minute': rendez!.minute,
      'month': rendez!.month,
      'note': rendez!.note,
      'title': rendez!.title,
      'year': rendez!.year,
    });
    final event = await database
        .child('rendez')
        .orderByChild('ajouterTime')
        .equalTo(rendez!.ajouterTime)
        .once();
    final data = event.snapshot.value as Map;
    final rendezRef = data.keys.first;
    await database.child('rendez').child(rendezRef).remove();
    Navigator.of(ctx).pop();
  }

  void confirmerDeletion(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (context) {
        return AlertDialog(
            icon: Icon(
              Icons.delete,
              color: Colors.yellow.shade900,
              size: 40,
            ),
            title: Text('Confirmation message'),
            content: Text('do you really want to delete ${rendez!.title}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteRendez(ctx);
                },
                child: Text('Delete'),
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (rendez == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {});
      });
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade600,
          title: Text(rendez!.title),
          actions: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                onPressed: () => confirmerDeletion(context),
                icon: Icon(
                  Icons.delete,
                  color: Colors.yellow.shade900,
                  size: 35,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRendezItem(
                  text: rendez!.title,
                  hintText: 'Title',
                  selectedRendezItem: _showModalBottomSheet,
                  afficheIconMode: true,
                ),
                InfoRendezItem(
                  text: DateFormat('dd/MM/yyyy').format(rendez!.dateTimeRendez),
                  hintText: 'Date',
                ),
                InfoRendezItem(
                  text: DateFormat('HH:mm').format(rendez!.dateTimeRendez),
                  hintText: 'Time',
                ),
                InfoRendezItem(
                  text: DateFormat(
                    'dd/MM/yyyy - HH:mm',
                  ).format(rendez!.dateTimeRendezCreation),
                  hintText: 'Creation date',
                ),
                InfoRendezItem(
                  text: rendez!.afficheTimeRest(),
                  hintText: 'Time rester',
                ),
                InfoRendezItem(
                  text: '${rendez!.dur} minutes',
                  hintText: 'duration of consultation',
                ),
                InfoRendezItem(
                  text: DateFormat('dd/MM/yyyy - HH:mm')
                      .format(rendez!.dateTimeRendezFin),
                  hintText: 'Appointment end date',
                ),
                Text(
                  'Doctor',
                  style: TextStyle(
                    fontSize: 18,
                    //fontWeight: FontWeight,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(medecin.imageUrl),
                  ),
                  title: Text('${medecin.prenom} ${medecin.nom}'),
                  subtitle: Text('${medecin.adress}, ${medecin.ville}'),
                  trailing: Text(medecin.nomCat),
                  onTap: () => Navigator.of(context).pushNamed('profilmedecin',
                      arguments: {'id': medecin.id}),
                ),
                Divider(
                  thickness: 0,
                  color: Colors.black,
                  height: 2,
                ),
                InfoRendezItem(
                  text: rendez!.note,
                  hintText: 'Note',
                  selectedRendezItem: _showModalBottomSheet,
                  afficheIconMode: true,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  void _showModalBottomSheet(
      BuildContext context, String hintText, String text) async {
    TextEditingController textEditingController =
        TextEditingController(text: text);
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 20,
            right: 10,
            left: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                hintText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                autofocus: true,
                enabled: true,
                controller: textEditingController,
                minLines: hintText == 'Note' ? 10 : 1,
                maxLines: hintText == 'Title' ? 1 : null,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      width: 2,
                      color: Colors.yellow.shade800,
                    ),
                  ),
                  hintText: hintText,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () =>
                    changer(textEditingController, context, hintText, text),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changer(TextEditingController textEditingController,
      BuildContext context, String hintText, String text) async {
    if (textEditingController.text.trim() == text) {
      Navigator.pop(context);
    } else {
      if (hintText == 'Title') {
        if (textEditingController.text.trim() != '') {
          if (!HomeScreen.afficheRendezTileList!.any((element) =>
              element.title == textEditingController.text.trim())) {
            await updateDataRendez(hintText, textEditingController);
            Navigator.pop(context);
          } else {
            ProfilMedecinScreen.titlePro(
                'you have an appointment with the same title "${textEditingController.text.trim()}" at ${DateFormat('dd/MM/yyyy - HH:mm').format(HomeScreen.afficheRendezTileList!.firstWhere((element) => element.title == textEditingController.text.trim()).dateRendez)}',
                context);
          }
        } else {
          ProfilMedecinScreen.titlePro('title must be no empty', context);
        }
      } else {
        await updateDataRendez(hintText, textEditingController);
        Navigator.pop(context);
      }
    }
  }

  Future updateDataRendez(
      String hintText, TextEditingController textEditingController) async {
    final event = await database
        .child('rendez')
        .orderByChild('ajouterTime')
        .equalTo(ajouterTime)
        .once();
    final data = event.snapshot.value as Map;
    final rendezRef = data.keys.first;
    await database
        .child('rendez')
        .child(rendezRef)
        .update({hintText.toLowerCase(): textEditingController.text.trim()});
    await refreshData();
  }
}
