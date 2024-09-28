import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med4u/screens/gestion_screen_admin.dart';
import 'package:med4u/screens/home_screen_admin.dart';
import 'package:med4u/screens/search_screen.dart';

import 'profil_medecin_screen.dart';

class TabScreenAdmin extends StatefulWidget {
  @override
  State<TabScreenAdmin> createState() => _TabScreenAdminState();
}

class _TabScreenAdminState extends State<TabScreenAdmin> {
  TextEditingController title = TextEditingController();

  final referenceRoot = FirebaseStorage.instance.ref();
  XFile? file;
  String? ImageUrl;
  final database = FirebaseDatabase.instance.ref();

  void _showModalBottomSheet() async {
    setState(() {
      ImageUrl = '';
      title = TextEditingController(text: '');
    });
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 20,
            right: 10,
            left: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add a speciality',
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
                autofocus: true,
                enabled: true,
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
                      color: Colors.yellow.shade800,
                    ),
                  ),
                  hintText: 'Title',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () => changeImage(),
                  child: ListTile(
                    leading: Icon(
                      Icons.image,
                      color: Colors.yellow.shade800,
                      size: 30,
                    ),
                    title: Text(
                      'Add a picture',
                      //textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              /*TextField(
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
                      color: Colors.yellow.shade800,
                    ),
                  ),
                  hintText: 'Note',
                ),
              ),*/
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  if (title.text.trim() == '') {
                    ProfilMedecinScreen.titlePro(
                        'title must be no empty', context);
                  } else {
                    if (ImageUrl == '') {
                      ProfilMedecinScreen.titlePro('Add a picture', context);
                    } else {
                      Navigator.of(context).pop();
                      await SearchScreen.setchage(); // Await after pop
                      await setCat();
                    }
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future changeImage() async {
    Completer completer = Completer<void>();
    ImagePicker imagePicker = ImagePicker();
    file = await imagePicker.pickImage(source: ImageSource.gallery);
    Reference referenceDirImage = await referenceRoot.child('medecinsImages');
    Reference referenceImageToUpload =
        await referenceDirImage.child(file!.name);
    await referenceImageToUpload.putFile(File(file!.path));
    ImageUrl = await referenceImageToUpload.getDownloadURL();
    //await setImage();
    completer.complete();
    return completer.future;
  }

  Future<void> setCat() async {
    final event = await database.child('categoryItem').push().set({
      'imageUrl': ImageUrl,
      'title': title.text.trim(),
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    });
    //ImageUrl = null;
    //await loadData();
  }

  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  int _selectedScreenIndex = 0;

  late List<Widget> _screens = [
    HomeScreenAdmin(),
    //SearchScreen(),
    SearchScreen(b: true,),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade600,
        actions: [
          if (_selectedScreenIndex == 1)
            IconButton(
              onPressed: _showModalBottomSheet,
              icon: Icon(
                size: 35,
                Icons.add_circle_outline_rounded,
                color: Colors.yellow.shade900,
              ),
            ),
          SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: Icon(
              size: 35,
              Icons.logout,
              color: Colors.yellow.shade900,
            ),
          ),
        ],
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
              Icons.build_circle_outlined,
            ),
            label: 'gestion',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
            label: 'profil',
          ),*/
        ],
      ),
    );
  }
}
