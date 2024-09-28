import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

class AfficheRendezTileMed extends StatelessWidget {
  final String prenom;
  final String nom;
  final String tel;
  final DateTime dateTime;

  const AfficheRendezTileMed(
      {required this.prenom,
      required this.nom,
      required this.tel,
      required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          '$prenom $nom',
        ),
        subtitle: Text(
          tel,
        ),
        trailing: Text(DateFormat('dd/MM/yyyy - HH:mm').format(dateTime)),
      ),
    );
  }
}
