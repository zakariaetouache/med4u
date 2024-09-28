import 'package:flutter/material.dart';
import 'package:med4u/screens/category_medecins_screen.dart';

class CategoryItem extends StatelessWidget {
  bool? b;
  final String id;
  final String title;
  final String imageUrl;

  CategoryItem({required this.id, required this.title, required this.imageUrl,this.b});

  void selectCategory(BuildContext context) {
    Navigator.of(context).pushNamed('categorymedecinscreen', arguments: {
      'id': id,
      'title': title,
      'b' : b,
    });
    /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryMedecinsScreen(id: id),
      ),
    );
    print('kkkkkkkkkkkkk$id');*/
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectCategory(context),
      splashColor: Colors.yellow.shade900,
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imageUrl,
              height: 250,
              //width: 250,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black.withOpacity(0.4),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
