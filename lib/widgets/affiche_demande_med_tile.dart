import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../models/medecin.dart';

class AfficheDemandeMedTile extends StatelessWidget {
  final Medecin medecin;

  const AfficheDemandeMedTile({required this.medecin});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: ()=> Navigator.of(context).pushNamed('afficheDemandeMed',arguments: medecin),
        leading: Image(
          image: NetworkImage(
            medecin.imageUrl,
          ),
        ),
        title: Text('${medecin.prenom} ${medecin.nom}'),
        subtitle: Text('${medecin.adress}, ${medecin.ville}'),
        trailing: Text('${medecin.nomCat}'),
      ),
    );
  }
}
