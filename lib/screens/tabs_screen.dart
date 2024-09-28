import 'package:flutter/material.dart';
import 'package:med4u/screens/home_screen.dart';
import 'package:med4u/screens/profil_screen.dart';
import 'package:med4u/screens/search_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  int _selectedScreenIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    ProfilScreen(),
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
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'search',
          ),
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
/*class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height = 56.0;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("med4u"),
      backgroundColor: Colors.grey.shade600,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: SearchBar());
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class SearchBar extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [      IconButton(        icon: Icon(Icons.clear),        onPressed: () {          query = '';        },      )    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: Implement search logic and display results.
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: Implement search suggestions.
    throw UnimplementedError();
  }
}*/
