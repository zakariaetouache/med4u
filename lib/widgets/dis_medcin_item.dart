import 'package:flutter/material.dart';

class DisMedcinItem extends StatefulWidget {
  bool col;
  String text;
  String periodId;

  DisMedcinItem(
      {super.key,
      required this.text,
      required this.col,
      required this.periodId});

  @override
  State<DisMedcinItem> createState() => _DisMedcinItemState();
}

class _DisMedcinItemState extends State<DisMedcinItem> {
  late bool _colo = widget.col;

  void selectPeriodFree(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text(
            'Confirm this appointment ${widget.text}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Non'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.col = false;
                });
                print(widget.col);
                Navigator.of(context).pop();
              },
              child: Text(
                'Yes',
              ),
            ),
          ],
        );
      },
    );
  }

  void selectPeriodOcc(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('information message'),
          content: Text(
            'The period ${widget.text} is already confirmed',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.col) {
          selectPeriodFree(context);
        } else {
          selectPeriodOcc(context);
        }
      },
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade700,
          ),
        ),
        Center(
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.col ? Colors.white : Colors.yellow.shade800,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]),
    );
  }
}