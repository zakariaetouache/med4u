import 'package:flutter/material.dart';
import 'package:med4u/screens/affiche_demande_med.dart';
import 'package:med4u/screens/category_medecins_screen.dart';
import 'package:med4u/screens/doctors_appointment%20_screen.dart';
import 'package:med4u/screens/home_screen.dart';
import 'package:med4u/screens/past_appointments_screen.dart';
import 'package:med4u/screens/profil_medecin_screen.dart';
import 'package:med4u/screens/signup_screen.dart';
import './screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/appointements_passed_med.dart';
import 'screens/auth.dart';
import 'screens/dis_medecin_screen.dart';
import 'screens/rendez_data_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.yellow.shade900,
      ),
      //home: const Auth(),
      routes: {
        '/': (context) => Auth(),
        'homeScreen': (context) => HomeScreen(),
        'signupScreen': (context) => SignupScreen(),
        'loginScreen': (context) => LoginScreen(),
        'categorymedecinscreen': (context) => CategoryMedecinsScreen(),
        'profilmedecin': (context) => ProfilMedecinScreen(),
        'dismedecin': (context) => DisMedecinScreen(),
        'rendezDataScreen': (context) => RendezDataScreen(),
        'pastAppointmentScreen': (context) => PastAppointementsScreen(),
        'doctorsAppointmentScreen': (context) => DoctorsAppointmentScreen(),
        'appointementsPassedMed': (context) => AppointementsPassedMed(),
        'afficheDemandeMed': (context) => AfficheDemandeMedecin(),
      },
    );
  }
}
