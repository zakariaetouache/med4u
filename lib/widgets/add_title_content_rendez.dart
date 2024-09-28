import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:med4u/screens/profil_medecin_screen.dart';

class addTitleContentRendez extends StatefulWidget {
  @override
  State<addTitleContentRendez> createState() => _addTitleContentRendezState();
}

class _addTitleContentRendezState extends State<addTitleContentRendez> {
  var title = TextEditingController();
  var note = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    title.dispose();
    note.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'add details of your appointment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: title,
              minLines: 1,
              maxLines: 1,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                  borderSide: BorderSide(
                    style: BorderStyle.solid,
                    width: 2,
                    color: Colors.indigo,
                  ),
                ),
                hintText: 'Title',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: note,
              minLines: 5,
              maxLines: 15,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                  borderSide: BorderSide(
                    style: BorderStyle.solid,
                    width: 2,
                    color: Colors.indigo,
                  ),
                ),
                hintText: 'Note',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
              ),
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
