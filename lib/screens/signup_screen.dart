import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:med4u/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:med4u/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final database = FirebaseDatabase.instance.ref();
  final referenceRoot = FirebaseStorage.instance.ref();
  bool signUpMedecin = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ConfirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _telController = TextEditingController();
  final _adressController = TextEditingController();
  final _villeControler = TextEditingController();
  bool checkedMonday = false;
  bool checkedTuesday = false;
  bool checkedWednesday = false;
  bool checkedThursday = false;
  bool checkedFriday = false;
  bool checkedSaturday = false;
  bool checkedSunday = false;
  final _timesOfMondayController = TextEditingController();
  final _timesOfTuesdayController = TextEditingController();
  final _timesOfWednesdayController = TextEditingController();
  final _timesOfThursdayController = TextEditingController();
  final _timesOfFridayController = TextEditingController();
  final _timesOfSaturdayController = TextEditingController();
  final _timesOfSundayController = TextEditingController();
  List? specialites;
  List? timesOfMonday,
      timesOfTuesday,
      timesOfWednesday,
      timesOfThursday,
      timesOfFriday,
      timesOfSaturday,
      timesOfSunday;
  final List listDuration = [
    '5 minutes',
    '10 minutes',
    '15 minutes',
    '20 minutes',
    '25 minutes',
    '30 minutes',
    '35 minutes',
    '40 minutes',
    '45 minutes',
    '50 minutes',
    '60 minutes'
  ];
  late String chooseDur = listDuration[0];
  late var choosedCategory = specialites![0];
  XFile? file, file2;
  final Map<String, int> daysConventient = {
    'checkedMonday': 1,
    'checkedTuesday': 2,
    'checkedWednesday': 3,
    'checkedThursday': 4,
    'checkedFriday': 5,
    'checkedSaturday': 6,
    'checkedSunday': 7,
  };
  late final String idMedecin;
  late final ImageUrl, imageUrlId;

  @override
  void initState() {
    super.initState();
    listSpecialite();
  }

  Future<void> listSpecialite() async {
    final event = await database.child('categoryItem').once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      specialites = data.values.map((e) => e).toList();
    } else {
      specialites = [];
    }
  }

  Future signUp() async {
    if (!signUpMedecin) {
      if (passwordConfirmed() &&
          _firstNameController.text.trim() != '' &&
          _secondNameController.text.trim() != '' &&
          _telController.text.trim() != '') {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final uid = userCredential.user!.uid;
        await database.child('patientsUsers').push().set({
          'prenom': _firstNameController.text.trim(),
          'nom': _secondNameController.text.trim(),
          'tel': _telController.text.trim(),
          'email': _emailController.text.trim(),
          'idPatient': uid,
        });
        Navigator.of(context).pushReplacementNamed('/');
      }
    } else {
      if (passwordConfirmed() &&
          allChampNoImpty() &&
          minDay() &&
          timeOfDayNotEmpty() &&
          file != null &&
          file2 != null) {
        loadListes();
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        String uid = userCredential.user!.uid;
        final Map<dynamic, dynamic> days_work = {};
        addDays_work(days_work);
        await putImage();
        final Map<String, dynamic> medecin = {
          'nom': _secondNameController.text.trim(),
          'prenom': _firstNameController.text.trim(),
          'tel': _telController.text.trim(),
          'ville': _villeControler.text.trim(),
          'nomCat': choosedCategory['title'],
          'categoryId': choosedCategory['id'],
          'imageUrl': ImageUrl,
          'imageUrlId': imageUrlId,
          'id': uid,
          'e_mail': _emailController.text.trim(),
          'dur': int.parse(chooseDur.substring(0, chooseDur.length - 8)),
          'adress': _adressController.text.trim(),
          'days_work': days_work,
        };
        await database.child('demandeMedecins').push().set(medecin);
        Navigator.of(context).pushReplacementNamed('loginScreen');
      }
    }
  }

  Future putImage() async {
    Completer completer = Completer<void>();
    Reference referenceDirImage = await referenceRoot.child('medecinsImages');
    Reference referenceImageToUpload =
        await referenceDirImage.child(file!.name);
    await referenceImageToUpload.putFile(File(file!.path));
    ImageUrl = await referenceImageToUpload.getDownloadURL();

    Reference referenceDirImageId = await referenceRoot.child('medecinsImages');
    Reference referenceImageToUploadId =
        await referenceDirImageId.child(file2!.name);
    await referenceImageToUploadId.putFile(File(file2!.path));
    imageUrlId = await referenceImageToUploadId.getDownloadURL();
    completer.complete();
    return completer.future;
  }

  void addDays_work(Map<dynamic, dynamic> days_work) {
    Map tt = {};
    if (checkedMonday) {
      timesOfMonday!
          .forEach((element) => tt.addAll({'$element': int.parse(element)}));
      days_work.addAll({
        'jour1': {
          'jour': 1,
          'time_work': tt,
        }
      });
      tt = {};
    }
    if (checkedTuesday) {
      timesOfTuesday!
          .forEach((element) => tt.addAll({'$element': int.parse(element)}));
      days_work.addAll({
        'jour2': {
          'jour': 2,
          'time_work': tt,
        }
      });
      tt = {};
    }
    if (checkedWednesday) {
      timesOfWednesday!
          .forEach((element) => tt.addAll({'$element': int.parse(element)}));
      days_work.addAll({
        'jour3': {
          'jour': 3,
          'time_work': tt,
        }
      });
      tt = {};
    }
    if (checkedThursday) {
      timesOfThursday!
          .forEach((element) => tt.addAll({'$element': int.parse(element)}));
      days_work.addAll({
        'jour4': {
          'jour': 4,
          'time_work': tt,
        }
      });
      tt = {};
    }
    if (checkedFriday) {
      timesOfFriday!
          .forEach((element) => tt.addAll({'$element': int.parse(element)}));
      days_work.addAll({
        'jour5': {
          'jour': 5,
          'time_work': tt,
        }
      });
      tt = {};
    }
    if (checkedSaturday) {
      timesOfSaturday!
          .forEach((element) => tt.addAll({'$element': int.parse(element)}));
      days_work.addAll({
        'jour6': {
          'jour': 6,
          'time_work': tt,
        }
      });
      tt = {};
    }
    if (checkedSunday) {
      timesOfSunday!
          .forEach((element) => tt.addAll({'$element': int.parse(element)}));
      days_work.addAll({
        'jour7': {
          'jour': 7,
          'time_work': tt,
        }
      });
      tt = {};
    }
  }

  void loadListes() {
    timesOfMonday = _timesOfMondayController.text.trim().split('-');
    timesOfTuesday = _timesOfTuesdayController.text.trim().split('-');
    timesOfWednesday = _timesOfWednesdayController.text.trim().split('-');
    timesOfThursday = _timesOfThursdayController.text.trim().split('-');
    timesOfFriday = _timesOfFridayController.text.trim().split('-');
    timesOfSaturday = _timesOfSaturdayController.text.trim().split('-');
    timesOfSunday = _timesOfSundayController.text.trim().split('-');
  }

  bool ChampNoImpty(TextEditingController txt) {
    if (txt.text.trim() != '') {
      return true;
    }
    return false;
  }

  bool allChampNoImpty() {
    if (ChampNoImpty(_firstNameController) &&
        ChampNoImpty(_secondNameController) &&
        ChampNoImpty(_telController) &&
        ChampNoImpty(_adressController) &&
        ChampNoImpty(_villeControler)) {
      return true;
    }
    return false;
  }

  bool minDay() {
    if (checkedSunday ||
        checkedSaturday ||
        checkedFriday ||
        checkedThursday ||
        checkedWednesday ||
        checkedTuesday ||
        checkedMonday) {
      return true;
    }
    return false;
  }

  bool timeOfDayNotEmpty() {
    if (checkedMonday) {
      if (!ChampNoImpty(_timesOfMondayController)) return false;
    }
    if (checkedTuesday) {
      if (!ChampNoImpty(_timesOfTuesdayController)) return false;
    }
    if (checkedWednesday) {
      if (!ChampNoImpty(_timesOfWednesdayController)) return false;
    }
    if (checkedThursday) {
      if (!ChampNoImpty(_timesOfThursdayController)) return false;
    }
    if (checkedFriday) {
      if (!ChampNoImpty(_timesOfFridayController)) return false;
    }
    if (checkedSaturday) {
      if (!ChampNoImpty(_timesOfSaturdayController)) return false;
    }
    if (checkedSunday) {
      if (!ChampNoImpty(_timesOfSundayController)) return false;
    }
    return true;
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _ConfirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  void openSigninScreen() {
    Navigator.of(context).pushNamed('/');
  }

  void singUpMedecin() {
    setState(() {
      signUpMedecin = !signUpMedecin;
    });
  }

  void checkedMondayState(bool? checkboxState) {
    setState(() {
      checkedMonday = checkboxState!;
    });
  }

  void checkedTuesdayState(bool? checkboxState) {
    setState(() {
      checkedTuesday = checkboxState!;
    });
  }

  void checkedWednesdayState(bool? checkboxState) {
    setState(() {
      checkedWednesday = checkboxState!;
    });
  }

  void checkedThursdayState(bool? checkboxState) {
    setState(() {
      checkedThursday = checkboxState!;
    });
  }

  void checkedFridayState(bool? checkboxState) {
    setState(() {
      checkedFriday = checkboxState!;
    });
  }

  void checkedSaturdayState(bool? checkboxState) {
    setState(() {
      checkedSaturday = checkboxState!;
    });
  }

  void checkedSundayState(bool? checkboxState) {
    setState(() {
      checkedSunday = checkboxState!;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ConfirmPasswordController.dispose();
    _villeControler.dispose();
    _adressController.dispose();
    _telController.dispose();
    _secondNameController.dispose();
    _firstNameController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade500,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/coeur.webp',
                  height: 130,
                  //width: ,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'SIGN UP',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  'welcome, Here you can sing up',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                inputContainer(
                    hintText: 'First Name', input: _firstNameController),
                inputContainer(
                    hintText: 'Second Name', input: _secondNameController),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                      ),
                    ),
                  ),
                ),
                inputContainer(hintText: 'Phone Number', input: _telController),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _ConfirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Confirm Password',
                      ),
                    ),
                  ),
                ),
                if (signUpMedecin)
                  Container(
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        inputContainer(
                            hintText: 'Adress', input: _adressController),
                        inputContainer(
                            hintText: 'City', input: _villeControler),
                        RowDivider(
                          dividerText: 'Days and houres',
                        ),
                        rowDayOfWeek(
                          day: 'Monday',
                          checkedDay: checkedMonday,
                          checkboxCallback: checkedMondayState,
                          timesOfDay: _timesOfMondayController,
                        ),
                        rowDayOfWeek(
                          day: 'Tuesday',
                          checkedDay: checkedTuesday,
                          checkboxCallback: checkedTuesdayState,
                          timesOfDay: _timesOfTuesdayController,
                        ),
                        rowDayOfWeek(
                          day: 'Wednesday',
                          checkedDay: checkedWednesday,
                          checkboxCallback: checkedWednesdayState,
                          timesOfDay: _timesOfWednesdayController,
                        ),
                        rowDayOfWeek(
                          day: 'Thursday',
                          checkedDay: checkedThursday,
                          checkboxCallback: checkedThursdayState,
                          timesOfDay: _timesOfThursdayController,
                        ),
                        rowDayOfWeek(
                          day: 'Friday',
                          checkedDay: checkedFriday,
                          checkboxCallback: checkedFridayState,
                          timesOfDay: _timesOfFridayController,
                        ),
                        rowDayOfWeek(
                          day: 'Saturday',
                          checkedDay: checkedSaturday,
                          checkboxCallback: checkedSaturdayState,
                          timesOfDay: _timesOfSaturdayController,
                        ),
                        rowDayOfWeek(
                          day: 'Sunday',
                          checkedDay: checkedSunday,
                          checkboxCallback: checkedSundayState,
                          timesOfDay: _timesOfSundayController,
                        ),
                        RowDivider(dividerText: 'Choose your specialty'),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 20, left: 20, top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButton<dynamic>(
                              isExpanded: true,
                              value: choosedCategory,
                              onChanged: (value) {
                                setState(() {
                                  choosedCategory = value!;
                                });
                              },
                              items: specialites!.map((e) {
                                return DropdownMenuItem<dynamic>(
                                  value: e,
                                  child: Text(e['title']),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        RowDivider(dividerText: 'Choose duration'),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 20, left: 20, top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: chooseDur,
                              onChanged: (value) {
                                setState(() {
                                  chooseDur = value as String;
                                });
                              },
                              items: listDuration.map((e) {
                                return DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            onTap: () async {
                              ImagePicker imagePicker = ImagePicker();
                              file = await imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              setState(() {});
                            },
                            child: ListTile(
                              leading: Icon(
                                Icons.image,
                                color: Colors.yellow.shade800,
                                size: 30,
                              ),
                              title: Text(
                                'Add your picture',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: InkWell(
                            onTap: () async {
                              ImagePicker imagePicker = ImagePicker();
                              file2 = await imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              setState(() {});
                            },
                            child: ListTile(
                              leading: Icon(
                                Icons.image,
                                color: Colors.yellow.shade800,
                                size: 30,
                              ),
                              title: Text(
                                'Add your identification',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member? ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: openSigninScreen,
                      child: Text(
                        'Sign in Here',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (!signUpMedecin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('You\'re a doctor Sign Up'),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: singUpMedecin,
                        child: Text(
                          'her',
                          style: TextStyle(color: Colors.yellow.shade800),
                        ),
                      ),
                    ],
                  ),
                if (signUpMedecin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('You\'re a patient Sign Up'),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: singUpMedecin,
                        child: Text(
                          'her',
                          style: TextStyle(color: Colors.yellow.shade800),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RowDivider extends StatelessWidget {
  final String dividerText;

  const RowDivider({super.key, required this.dividerText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 2,
            color: Colors.white,
            width: 70,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            dividerText,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            height: 2,
            color: Colors.white,
            width: 70,
          ),
        ],
      ),
    );
  }
}

class inputContainer extends StatelessWidget {
  final String hintText;
  final TextEditingController input;

  inputContainer({required this.hintText, required this.input});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 25, left: 25, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: input,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          focusColor: Colors.white,
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class rowDayOfWeek extends StatelessWidget {
  final String day;
  final bool checkedDay;
  final Function(bool?) checkboxCallback;
  final TextEditingController timesOfDay;

  const rowDayOfWeek({
    required this.day,
    required this.checkedDay,
    required this.checkboxCallback,
    required this.timesOfDay,
  });

  @override
  Row build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 179,
          child: CheckboxListTile(
            title: Text(day),
            controlAffinity: ListTileControlAffinity.leading,
            value: checkedDay,
            activeColor: Colors.yellow.shade800,
            onChanged: checkboxCallback,
          ),
        ),
        if (checkedDay)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            width: 200,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: TextField(
              autofocus: true,
              controller: timesOfDay,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: 'Houres',
                helperText: 'Example 8-9-10-14-15-16',
              ),
            ),
          ),
      ],
    );
  }
}
