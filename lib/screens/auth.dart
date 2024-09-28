import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:med4u/models/medecin.dart';
import 'package:med4u/screens/login_screen.dart';
import 'package:med4u/screens/tab_screen_admin.dart';
import 'package:med4u/screens/tab_screen_med.dart';
import 'package:med4u/screens/tabs_screen.dart';
import 'home_screen.dart';

class Auth extends StatefulWidget {
  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  User? user = FirebaseAuth.instance.currentUser;

  final database = FirebaseDatabase.instance.ref();

  Medecin? medecin;

  int utilisateur = 0;
  bool tt = false, kk = false;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await _utilisateur();
    await admin();
  }

  Future<void> _utilisateur() async {
    Completer<void> completer = Completer<void>();
    final event = await database
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(user!.uid)
        .once();
    if (event.snapshot.value != null) {
      final dd = event.snapshot.value as Map;
      final data = dd.values.first;
      medecin = Medecin(
        dur: data['dur'],
        id: data['id'],
        nom: data['nom'],
        prenom: data['prenom'],
        adress: data['adress'],
        ville: data['ville'],
        imageUrl: data['imageUrl'],
        e_mail: data['e_mail'],
        tel: data['tel'],
        nomCat: data['nomCat'],
      );

      setState(() {
        utilisateur = 1;
        tt = true;
      });
      completer.complete();
      return completer.future;
    }else{
      setState(() {
        tt = true;
      });
    }
  }

  Future<void> admin() async {
    final event = await database
        .child('adminsUsers')
        .orderByChild('idAdmin')
        .equalTo(user!.uid)
        .once();
    if (event.snapshot.value != null) {
      setState(() {
        utilisateur = 2;
        kk = true;
      });
    } else {
      setState(() {
        kk = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            if (tt && kk) {
              //_utilisateur();
              if (utilisateur == 1) {
                return TabScreenMed(
                  medecin: medecin!,
                );
              } else {
                if (utilisateur == 2) {
                  return TabScreenAdmin();
                } else {
                  return TabsScreen();
                }
              }
            } else {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          } else {
            return LoginScreen();
          }
        }),
      ),
    );
  }
}
