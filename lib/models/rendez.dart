import 'medecin.dart';

class Rendez {
  final int ajouterTime;
  final String title;
  final String note;
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int dur;
  final String idPatient;
  final String idMedecin;
  final Medecin medecin;

  late DateTime dateTimeRendez;
  late DateTime dateTimeRendezCreation;
  late DateTime dateTimeRendezFin;

  Rendez(
    this.ajouterTime,
    this.title,
    this.note,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.dur,
    this.idPatient,
    this.idMedecin,
    this.medecin,
  ) {
    dateTimeRendez = DateTime(year, month, day, hour, minute);
    final dd = DateTime.now();
    dateTimeRendezCreation =
        DateTime.fromMillisecondsSinceEpoch(ajouterTime ~/ 1000);
    dateTimeRendezFin = dateTimeRendez.add(Duration(minutes: dur));
  }
  String afficheTimeRest() {
    Duration duration = dateTimeRendez.difference(DateTime.now());
    return '${duration.inDays} days : ${duration.inHours - (duration.inDays) * 24} hours : ${duration.inMinutes - (duration.inHours) * 60} minutes : ${duration.inSeconds - (duration.inMinutes) * 60} seconds';
  }
}
