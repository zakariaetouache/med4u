import 'package:flutter/material.dart';
import 'package:med4u/models/medecin.dart';
import 'package:med4u/screens/home_screen.dart';

class AfficheRendezTile extends StatelessWidget {
  final String title;
  final DateTime dateRendez;
  final int ajouterTime;
  final Medecin medecin;
  bool? press;

  AfficheRendezTile(
      {required this.title,
      required this.dateRendez,
      required this.ajouterTime,
      required this.medecin,
      this.press = true});

  void _selectRendez(BuildContext context) async {
    Navigator.of(context).pushNamed('rendezDataScreen',
        arguments: {'ajouterTime': ajouterTime, 'medecin': medecin});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: press!
          ? DateTime.now().add(Duration(hours: 24)).isAfter(dateRendez)
              ? Colors.yellow.shade900
              : Colors.white
          : null,
      elevation: 6,
      shadowColor: Colors.grey.shade400,
      child: ListTile(
        textColor: press!
            ? DateTime.now().add(Duration(hours: 24)).isAfter(dateRendez)
                ? Colors.white
                : Colors.black
            : null,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(medecin.imageUrl),
          radius: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        subtitle: Text(
          '${medecin.prenom} ${medecin.nom}',
        ),
        trailing: Text(
          '${dateRendez.day.toString().padLeft(2, '0')}/${dateRendez.month.toString().padLeft(2, '0')}/${dateRendez.year}-${dateRendez.hour.toString().padLeft(2, '0')}:${dateRendez.minute.toString().padLeft(2, '0')}',
        ),
        onTap: press! ? () => _selectRendez(context) : null,
      ),
    );
  }
}
