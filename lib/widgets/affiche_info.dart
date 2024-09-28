import 'package:flutter/material.dart';

class AfficheInfo extends StatelessWidget {
  final String val;
  final IconData ico;

  const AfficheInfo({super.key, required this.val, required this.ico});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      /*shadowColor: Colors.yellow.shade800,
      elevation: ,*/
      child: ListTile(
        leading: Icon(
          ico,
          color: Colors.yellow.shade800,
        ),
        title: Text(
          val,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}