import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:med4u/models/medecin.dart';
import 'package:med4u/widgets/affiche_demande_med_tile.dart';

class HomeScreenAdmin extends StatefulWidget {
  const HomeScreenAdmin({Key? key}) : super(key: key);

  static State<StatefulWidget>? currentState;

  static Future<void> setCahget() async {
    final _HomeScreenAdminState adminState =
        currentState as _HomeScreenAdminState;
    await adminState.LoadData();
  }

  @override
  State<HomeScreenAdmin> createState() {
    final state = _HomeScreenAdminState();
    currentState = state;
    return state;
  }
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
  final database = FirebaseDatabase.instance.ref();
  List<AfficheDemandeMedTile>? listMedecinTile;

  @override
  void initState() {
    super.initState();
    HomeScreenAdmin.currentState = this;
    LoadData();
  }

  Future<void> LoadData() async {
    final event = await database.child('demandeMedecins').once();
    List<AfficheDemandeMedTile> list = [];
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      list = data.values
          .map(
            (e) => AfficheDemandeMedTile(
              medecin: Medecin(
                dur: e['dur'],
                id: e['id'],
                nom: e['nom'],
                prenom: e['prenom'],
                adress: e['adress'],
                ville: e['ville'],
                imageUrl: e['imageUrl'],
                e_mail: e['e_mail'],
                tel: e['tel'],
                nomCat: e['nomCat'],
                imageUrlId: e['imageUrlId'],
              ),
            ),
          )
          .toList();
    }
    setState(() {
      listMedecinTile = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (listMedecinTile == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      if (listMedecinTile!.isEmpty) {
        return Scaffold(
          body: Center(
            child: Text('There are no invitations'),
          ),
        );
      } else {
        return Scaffold(
          body: ListView(
            children: listMedecinTile!,
          ),
        );
      }
    }
  }
}
