import 'package:flutter/material.dart';

class InfoRendezItem extends StatelessWidget {
  String text;
  String hintText;
  Function(BuildContext context, String hintText, String text)?
      selectedRendezItem;
  bool afficheIconMode;

  InfoRendezItem({
    required this.hintText,
    required this.text,
    this.selectedRendezItem,
    this.afficheIconMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => selectedRendezItem!(context, hintText, text),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 5,
            ),
            Text(
              hintText,
              style: TextStyle(
                fontSize: 18,
                //fontWeight: FontWeight,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                if (afficheIconMode)
                  Icon(
                    Icons.mode,
                    color: Colors.yellow.shade900,
                  )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              thickness: 0,
              color: Colors.black,
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}
