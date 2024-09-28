import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class GestionScreenAdmin extends StatefulWidget {
  const GestionScreenAdmin({super.key});

  @override
  State<GestionScreenAdmin> createState() => _GestionScreenAdminState();
}

class _GestionScreenAdminState extends State<GestionScreenAdmin> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'hello admin gestion',
        ),
      ),
    );
  }
}
