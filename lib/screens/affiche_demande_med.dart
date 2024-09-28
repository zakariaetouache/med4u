import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:med4u/screens/home_screen_admin.dart';
import 'package:med4u/widgets/info_rendez_item.dart';

import '../models/medecin.dart';

class AfficheDemandeMedecin extends StatelessWidget {
  late Medecin medecin;
  final database = FirebaseDatabase.instance.ref();
  var refMed;
  var med;

  Future<void> deletDemande(BuildContext context) async {
    await getRef();
    await database.child('demandeMedecins').child(refMed).remove();
    Navigator.of(context).pop();
    await HomeScreenAdmin.setCahget();
  }

  Future<void> getRef() async {
    final event = await database
        .child('demandeMedecins')
        .orderByChild('id')
        .equalTo(medecin.id)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      refMed = data.keys.first;
    }
  }

  Future<void> accepteMedecin(BuildContext context) async {
    final event = await database
        .child('demandeMedecins')
        .orderByChild('id')
        .equalTo(medecin.id)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      med = data.values.first;
      await database.child('medecinsUsers').push().set(med);
    }
    deletDemande(context);
  }

  @override
  Widget build(BuildContext context) {
    medecin = ModalRoute.of(context)!.settings.arguments as Medecin;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        title: Text('${medecin.prenom} ${medecin.nom}'),
        actions: [
          IconButton(
            iconSize: 40,
            onPressed: () => accepteMedecin(context),
            icon: Icon(
              Icons.how_to_reg_sharp,
              color: Colors.yellow.shade900,
            ),
          ),
          IconButton(
            iconSize: 40,
            onPressed: () => deletDemande(context),
            icon: Icon(
              Icons.close,
              color: Colors.yellow.shade900,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                child: Image(
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  image: NetworkImage(medecin.imageUrlId!),
                ),
              ),
              Card(
                child: Image(
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  image: NetworkImage(medecin.imageUrl),
                ),
              ),
              InfoRendezItem(hintText: 'Fist name', text: medecin.prenom),
              InfoRendezItem(hintText: 'Second name', text: medecin.nom),
              InfoRendezItem(hintText: 'Adress', text: medecin.adress),
              InfoRendezItem(hintText: 'City', text: medecin.ville),
              InfoRendezItem(hintText: 'Phone number', text: medecin.tel),
              InfoRendezItem(hintText: 'e_mail', text: medecin.e_mail),
            ],
          ),
        ),
      ),
    );
  }
}
