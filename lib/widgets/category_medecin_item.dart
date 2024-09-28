import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CategoryMedecinItem extends StatelessWidget {
  final database = FirebaseDatabase.instance.ref();
  //final String categoryId;
  final String id;
  final String nom;
  final String prenom;
  final String imageUrl;
  final String adress;
  final String ville;
  final String? nomCat;
  bool? b;
  CategoryMedecinItem(
      {
      //required this.categoryId,
      required this.id,
      required this.nom,
      required this.prenom,
      required this.imageUrl,
      required this.adress,
      required this.ville,
      this.nomCat,
      this.b = false});

  void selecteMedecin(context) {
    Navigator.of(context).pushNamed('profilmedecin', arguments: {
      //'categoryId':categoryId,
      'id': id,
      'b': b,
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selecteMedecin(context),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text('$prenom $nom'),
          subtitle: Text('$adress, $ville'),
          trailing: nomCat != null ? Text(nomCat!) : null,
        ),
      ),
    );
  }
}
