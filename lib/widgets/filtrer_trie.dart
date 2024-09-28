import 'package:flutter/material.dart';

class FiltrerTrier extends StatefulWidget {
  TextEditingController? textController;
  Function(String)? textFieldFunction;
  Function(String?)? ch;
  List listType;
  String dropDownTitle;
  IconData? dropDownIcon;
  String? hintTextTextController;
  Color? color;

  FiltrerTrier({
    required this.hintTextTextController,
    required this.textController,
    required this.textFieldFunction,
    required this.dropDownTitle,
    required this.dropDownIcon,
    required this.listType,
    required this.ch,
    required this.color,
  });
  @override
  State<FiltrerTrier> createState() => _FiltrerTrierState();
}

class _FiltrerTrierState extends State<FiltrerTrier> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                          width: 2,
                          color: Colors.yellow.shade800,
                        )),
                    hintText: widget.hintTextTextController,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                  ),
                  onChanged: (value) => widget.textFieldFunction!(value),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Drop(
              items: widget.listType,
              dropDownTitle: widget.dropDownTitle,
              dropDownIcon: widget.dropDownIcon,
              choosed: widget.ch,
            ),
          ],
        ),
      ),
    );
  }
}

class Drop extends StatefulWidget {
  List items;
  final Function(String)? choosed;
  String dropDownTitle;
  IconData? dropDownIcon;
  Drop({
    required this.items,
    required this.dropDownTitle,
    required this.dropDownIcon,
    required this.choosed,
  });

  @override
  State<Drop> createState() => _DropState();
}

class _DropState extends State<Drop> {
  late var val = widget.items[0];

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.white,
      child: DropdownButton(
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.yellow.shade900,
        ),
        icon: Icon(
          widget.dropDownIcon,
          color: Colors.yellow.shade900,
          size: 30,
        ),
        /*hint: Text(
          widget.dropDownTitle,
          style: TextStyle(
            fontSize: 18,
            color: Colors.yellow.shade900,
          ),
        ),*/
        value: val,
        items: widget.items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) {
          widget.choosed!(value as String);
          setState(() {
            val = value as String;
          });
        },
      ),
    );
  }
}
