import 'package:flutter/material.dart';

enum Jours { Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday }

class Medecin {
  final String nomCat;
  //final String categoryId;
  final String id;
  final String nom;
  final String prenom;
  final String adress;
  final String ville;
  final String imageUrl;
  final String e_mail;
  final String tel;
  final int dur;
  String? imageUrlId;

  Medecin({
    //required this.categoryId,
    required this.dur,
    required this.id,
    required this.nom,
    required this.prenom,
    required this.adress,
    required this.ville,
    required this.imageUrl,
    required this.e_mail,
    required this.tel,
    required this.nomCat,
    this.imageUrlId,
  });
}
