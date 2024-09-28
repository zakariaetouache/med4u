import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../widgets/dis_medcin_item.dart';

class DisMedecinScreen extends StatelessWidget {
  const DisMedecinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeArgument = ModalRoute.of(context)?.settings.arguments as Map;
    final medId = routeArgument['id'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade600,
      ),
      body: GridView(
        padding: EdgeInsets.all(5),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3,
          mainAxisSpacing: 1,
          crossAxisSpacing: 2,
        ),
        children: [
          DisMedcinItem(text: '8:00 -> 8:30', col: true, periodId: '1',),
          DisMedcinItem(text: '8:30 -> 9:00', col: false, periodId: '2',),
          DisMedcinItem(text: '9:00 -> 9:30', col: false, periodId: '3',),
          DisMedcinItem(text: '9:30 -> 10:00', col: true, periodId: '4',),
          DisMedcinItem(text: '10:00 -> 10:30', col: true, periodId: '5',),
          DisMedcinItem(text: '10:30 -> 11:00', col: false, periodId: '6',),
          DisMedcinItem(text: '11:00 -> 11:30', col: true, periodId: '7',),
          DisMedcinItem(text: '11:30 -> 12:00', col: true, periodId: '8',),
        ],
      ),
    );
  }
}
