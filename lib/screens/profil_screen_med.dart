import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med4u/models/medecin.dart';
import 'package:med4u/widgets/info_rendez_item.dart';

import 'profil_medecin_screen.dart';

class ProfilScreenMed extends StatefulWidget {
  Medecin medecin;

  ProfilScreenMed({required this.medecin});

  @override
  State<ProfilScreenMed> createState() => _ProfilScreenMedState();
}

class _ProfilScreenMedState extends State<ProfilScreenMed> {
  final referenceRoot = FirebaseStorage.instance.ref();
  XFile? file;
  String? ImageUrl;
  Medecin? medecin;
  final database = FirebaseDatabase.instance.ref();
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final event = await database
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(widget.medecin.id)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      final med = data.values.first;
      medecin = Medecin(
          dur: med['dur'],
          id: med['id'],
          nom: med['nom'],
          prenom: med['prenom'],
          adress: med['adress'],
          ville: med['ville'],
          imageUrl: med['imageUrl'],
          e_mail: med['e_mail'],
          tel: med['tel'],
          nomCat: med['nomCat']);
      setState(() {});
    }
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
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(medecin!.id)
        .once();
    final data = event.snapshot.value as Map;
    final medecinRef = data.keys.first;
    await database
        .child('medecinsUsers')
        .child(medecinRef)
        .update(hintText == 'First name'
            ? {'prenom': textEditingController.text.trim()}
            : hintText == 'Second name'
                ? {'nom': textEditingController.text.trim()}
                : {hintText.toLowerCase(): textEditingController.text.trim()});
    await loadData();
    //await refreshData();
    //refreche();
  }

  /*void refreche() {
    Navigator.of(context).pushReplacementNamed('/');
  }*/

  /*Future<void> refreshData() async {
    await loadData();
  }*/

  Future changeImage() async {
    Completer completer = Completer<void>();
    ImagePicker imagePicker = ImagePicker();
    file = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      ImageUrl = '';
    });
    Reference referenceDirImage = await referenceRoot.child('medecinsImages');
    Reference referenceImageToUpload =
        await referenceDirImage.child(file!.name);
    await referenceImageToUpload.putFile(File(file!.path));
    ImageUrl = await referenceImageToUpload.getDownloadURL();
    await setImage();
    completer.complete();
    return completer.future;
  }

  Future<void> setImage() async {
    final event = await database
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(medecin!.id)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      final medRef = data.keys.first;
      await database
          .child('medecinsUsers')
          .child(medRef)
          .update({'imageUrl': ImageUrl});
    }
    //ImageUrl = null;
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (medecin == null || ImageUrl == '') {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
          backgroundColor: Colors.grey.shade300,
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => changeImage(),
                      child: Stack(children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            medecin!.imageUrl,
                          ),
                          radius: 80,
                          /*child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image(
                              height: 200,
                              fit: BoxFit.fitHeight,
                              image: NetworkImage(
                                medecin!.imageUrl,
                              ),
                            ),
                          ),*/
                        ),
                        Positioned(
                          bottom: 0,
                          right: 10,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                            ),
                            child: Icon(
                              size: 24,
                              Icons.edit_outlined,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ]),
                    ),
                    InfoRendezItem(
                        hintText: 'First name',
                        text: medecin!.prenom,
                        selectedRendezItem: _showModalBottomSheet,
                        afficheIconMode: true),
                    InfoRendezItem(
                        hintText: 'Second name',
                        text: medecin!.nom,
                        selectedRendezItem: _showModalBottomSheet,
                        afficheIconMode: true),
                    InfoRendezItem(
                        hintText: 'Adress',
                        text: medecin!.adress,
                        selectedRendezItem: _showModalBottomSheet,
                        afficheIconMode: true),
                    InfoRendezItem(
                        hintText: 'City',
                        text: medecin!.ville,
                        selectedRendezItem: _showModalBottomSheet,
                        afficheIconMode: true),
                    InfoRendezItem(
                        hintText: 'Phone number',
                        text: medecin!.tel,
                        selectedRendezItem: _showModalBottomSheet,
                        afficheIconMode: true),
                    InfoRendezItem(hintText: 'e_mail', text: medecin!.e_mail),
                    Card(
                      child: ListTile(
                        onTap: () => Navigator.of(context)
                            .pushNamed('appointementsPassedMed'),
                        leading: Icon(
                          Icons.history,
                          size: 30,
                          color: Colors.yellow.shade800,
                        ),
                        title: Text('Passed appointments'),
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
            ),
          ));
    }
  }
}
