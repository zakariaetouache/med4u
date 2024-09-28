import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:med4u/screens/home_screen.dart';
import 'package:med4u/screens/profil_medecin_screen.dart';
import 'package:med4u/widgets/info_rendez_item.dart';

import '../models/patient.dart';

class ProfilScreen extends StatefulWidget {
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  //const ProfilScreen({super.key});
  final user = FirebaseAuth.instance.currentUser!;
  final database = FirebaseDatabase.instance.ref();
  Patient? pateint;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    final event = await database
        .child('patientsUsers')
        .orderByChild('idPatient')
        .equalTo(user.uid)
        .once();
    final pat = event.snapshot.value as Map;
    final dataPatient = pat.values.first;
    pateint = Patient(
      prenom: dataPatient['prenom'],
      nom: dataPatient['nom'],
      tel: dataPatient['tel'],
      email: dataPatient['email'],
      idPatient: dataPatient['idPatient'],
    );
    setState(() {});
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
                //minLines: 1,
                maxLines: 5,
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
      if (textEditingController.text.trim() == '') {
        ProfilMedecinScreen.titlePro('$hintText must be no empty', context);
      } else {
        await updateDataRendez(hintText, textEditingController);
        Navigator.pop(context);
      }
    }
  }

  Future updateDataRendez(
      String hintText, TextEditingController textEditingController) async {
    final event = await database
        .child('patientsUsers')
        .orderByChild('idPatient')
        .equalTo(pateint!.idPatient)
        .once();
    final data = event.snapshot.value as Map;
    final rendezRef = data.keys.first;
    await database
        .child('patientsUsers')
        .child(rendezRef)
        .update(hintText == 'First name'
            ? {'prenom': textEditingController.text.trim()}
            : hintText == 'Second name'
                ? {'nom': textEditingController.text.trim()}
                : {'tel': textEditingController.text.trim()});
    await refreshData();
  }

  Future<void> refreshData() async {
    await loadData();
  }

  Widget build(BuildContext context) {
    if (pateint == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 15),
                //height: 30,
                child: Center(
                  child: Text(
                    'Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Card(
                //shadowColor: Colors.yellow.shade90,
                elevation: 20,
                //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                color: Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      InfoRendezItem(
                        hintText: 'First name',
                        text: pateint!.prenom,
                        afficheIconMode: true,
                        selectedRendezItem: _showModalBottomSheet,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InfoRendezItem(
                        hintText: 'Second name',
                        text: pateint!.nom,
                        afficheIconMode: true,
                        selectedRendezItem: _showModalBottomSheet,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InfoRendezItem(
                        hintText: 'Phone number',
                        text: pateint!.tel,
                        afficheIconMode: true,
                        selectedRendezItem: _showModalBottomSheet,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InfoRendezItem(hintText: 'e_mail', text: pateint!.email),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Card(
                child: ListTile(
                  onTap: () =>
                      Navigator.of(context).pushNamed('pastAppointmentScreen'),
                  leading: Icon(
                    Icons.history,
                    size: 30,
                    color: Colors.yellow.shade800,
                  ),
                  title: Text(
                    'Past appointments',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: () => Navigator.of(context)
                      .pushNamed('doctorsAppointmentScreen'),
                  leading: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.yellow.shade800,
                  ),
                  title: Text(
                    'Doctors you have with them an appointment',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: () => FirebaseAuth.instance.signOut(),
                  leading: Icon(
                    Icons.logout,
                    size: 30,
                    color: Colors.yellow.shade800,
                  ),
                  title: Text(
                    'sign out',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    /*return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'hello, Your\'re signed in',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            Text(
              user.email!,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              color: Colors.amber[800],
              child: Container(
                width: 200,
                child: Center(
                  child: Text(
                    'sign out',
                    style: TextStyle(
                      fontSize: 20,
                      //fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );*/
  }
}