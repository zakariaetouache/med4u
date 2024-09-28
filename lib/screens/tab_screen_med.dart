import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:med4u/models/medecin.dart';
import 'package:med4u/screens/home_screen_med.dart';
import 'package:med4u/screens/profil_screen_med.dart';

class TabScreenMed extends StatefulWidget {

  Medecin medecin;

  TabScreenMed({required this.medecin});
  @override
  State<TabScreenMed> createState() => _TabScreenMedState();
}

class _TabScreenMedState extends State<TabScreenMed> {
  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  int _selectedScreenIndex = 0;

  late List<Widget> _screens = [
    HomeScreenMed(medecin: widget.medecin),
    //SearchScreen(),
    ProfilScreenMed(medecin: widget.medecin,),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade600,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0),
              radius: 30,
              child: Image(
                image: AssetImage('images/coeur.webp'),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'med4u',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: _screens[_selectedScreenIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectScreen,
        backgroundColor: Colors.grey.shade600,
        selectedItemColor: Colors.yellow.shade900,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedScreenIndex,
        selectedFontSize: 16,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'acceil',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'search',
          ),*/
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
            label: 'profil',
          ),
        ],
      ),
    );
  }
}
