import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:med4u/models/medecin.dart';
import 'package:med4u/screens/tabs_screen.dart';
import 'package:med4u/widgets/add_title_content_rendez.dart';
import 'package:time_picker_widget/time_picker_widget.dart';
import 'dart:async';
import '../models/notification_api.dart';
import '../widgets/affiche_info.dart';
import 'package:intl/intl.dart';

class ProfilMedecinScreen extends StatefulWidget {
  @override
  State<ProfilMedecinScreen> createState() => _ProfilMedecinScreenState();
  static void titlePro(String text, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('information message'),
          content: Text(
            text,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfilMedecinScreenState extends State<ProfilMedecinScreen> {
  final Map<int, String> dayWeek = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  final Map<String, int> weekDay = {
    'Text("Monday")': 1,
    'Text("Tuesday")': 2,
    'Text("Wednesday")': 3,
    'Text("Thursday")': 4,
    'Text("Friday")': 5,
    'Text("Saturday")': 6,
    'Text("Sunday")': 7,
  };
  final database = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;
  late final String id;
  late bool b;
  List<Medecin>? medecin;
  String? str;
  List<int>? enabledDays;
  late DateTime newDateTime;
  List principaleTime = [];
  List? heurreserv = [],
      enabledTime = [],
      timeWork = [],
      enableTimeAffiche = [];
  List? listRendezConflues, rendezSameTitle;
  List<ListTileAfficher>? listDaysTimeWork;
  List<NewCard>? listRendezMedecinPatient;
  Map? rendezSameDaySameMedecin;
  bool is24 = true;
  var title = TextEditingController();
  var note = TextEditingController();
  /////////////////////////////////

  Future<void> deleMed() async {
    final event = await database
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(medecin![0].id)
        .once();
    final data = event.snapshot.value as Map;
    final refMed = data.keys.first;
    await database.child('medecinsUsers').child(refMed).remove();
    final ev = await database
        .child('rendez')
        .orderByChild('idMedecin')
        .equalTo(medecin![0].id)
        .once();
    final dat = ev.snapshot.value as Map;

    // Supprimer chaque rendez-vous associé au médecin
    dat.forEach((key, value) async {
      await database.child('rendez').child(key).remove();
    });
    Navigator.of(context).pop();
  }

  void selectDec() async {
    title.text = '';
    note.text = '';
    DateTime? newDate = await showEnabledDays();
    if (newDate == null) {
      setState(() {
        enabledDays = [];
      });
      return;
    } else {
      await _enabledTime(newDate);
      await desebletedTime(newDate);
      if (!enabledTime!.isEmpty) {
        TimeOfDay? tim;
        await showCustomTimePicker(
                context: context,
                onFailValidation: (context) => print('Unavailable selection'),
                initialTime: enabledTime![0],
                selectableTimePredicate: (time) => _isTimeEnabled(time))
            .then((time) async {
          tim = time;
          if (tim == null) {
            setState(() {
              principaleTime = [];
              enabledDays = [];
              timeWork = [];
              heurreserv = [];
              enabledTime = [];
              enableTimeAffiche = [];
              enableTimeAffiche = [];
            });
            selectDec();
            return;
          } else {
            newDateTime = DateTime(
              newDate.year,
              newDate.month,
              newDate.day,
              tim!.hour,
              tim!.minute,
            );
            listRendezConflues = await _enableDateTimePatient(
                newDateTime, medecin![0].dur); ////////
            rendezSameDaySameMedecin =
                await _rendezSameDaySameMedecin(newDateTime) as Map;
            if (_verifierPeriode(newDateTime)) {
              if (enabledTime!.contains(TimeOfDay(
                  hour: newDateTime.hour, minute: newDateTime.minute))) {
                if (rendezSameDaySameMedecin!.isEmpty) {
                  if (listRendezConflues!.isEmpty) {
                    _showModalBottomSheet();
                  } else {
                    String listNomAppointementsCombined = '';
                    for (int i = 0; i < listRendezConflues!.length; i++) {
                      listNomAppointementsCombined +=
                          ' "${listRendezConflues![i]['title']}",';
                    }
                    selectedDayOcc(context,
                        'you have ${listRendezConflues!.length} appointments : $listNomAppointementsCombined combined with time ${newDate.day.toString().padLeft(2, '0')}/${newDate.month.toString().padLeft(2, '0')}/${newDate.year.toString().padLeft(2, '0')}-${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}');
                  }
                } else {
                  selectedDayOcc(context,
                      'you have an appointments with this doctor on ${rendezSameDaySameMedecin![0]['day'].toString().padLeft(2, '0')}/${rendezSameDaySameMedecin![0]['month'].toString().padLeft(2, '0')}/${rendezSameDaySameMedecin![0]['year'].toString().padLeft(2, '0')}-${rendezSameDaySameMedecin![0]['hour'].toString().padLeft(2, '0')}:${rendezSameDaySameMedecin![0]['minute'].toString().padLeft(2, '0')}');
                }
              } else {
                selectedDayOcc(context,
                    '${newDate.day.toString().padLeft(2, '0')}/${newDate.month.toString().padLeft(2, '0')}/${newDate.year.toString().padLeft(2, '0')}-${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')} This date has been confirmed');
              }
            } else {
              selectedDayOcc(context,
                  '${newDate.day.toString().padLeft(2, '0')}/${newDate.month.toString().padLeft(2, '0')}/${newDate.year.toString().padLeft(2, '0')}-${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')} This date has been passed');
            }
          }
        });
      } else {
        selectedDayOcc(context,
            'The day ${newDate.day.toString().padLeft(2, '0')}/${newDate.month.toString().padLeft(2, '0')}/${newDate.year.toString().padLeft(2, '0')} all période has been confirmed or passed for now');
      }
    }
  }

/////////////////////////////////
  ///
  ///
//////////////////////////////////
  void dispose() {
    super.dispose();
    title.dispose();
    note.dispose();
  }

  void _showModalBottomSheet() async {
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
                'add details of your appointment',
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
              TextField(
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
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  NotifiactionApi.showNotification(
                    title: 'zakariae',
                    body: 'hello world!', /*payload: 'add'*/
                  );
                  if (title.text.trim() == '') {
                    ProfilMedecinScreen.titlePro(
                        'title must be no empty', context);
                  } else {
                    rendezSameTitle = await _redezSameTitle(title.text.trim());
                    if (!rendezSameTitle!.isEmpty) {
                      ProfilMedecinScreen.titlePro(
                          'you have an appointment with the same title "${title.text.trim()}" at ${rendezSameTitle![0]['day'].toString().padLeft(2, '0')}/${rendezSameTitle![0]['month'].toString().padLeft(2, '0')}/${rendezSameTitle![0]['year']}-${rendezSameTitle![0]['hour'].toString().padLeft(2, '0')}:${rendezSameTitle![0]['minute'].toString().padLeft(2, '0')}',
                          context);
                    } else {
                      Navigator.pop(context);
                      if (_verifierPeriode(newDateTime)) {
                        if (enabledTime!.contains(TimeOfDay(
                            hour: newDateTime.hour,
                            minute: newDateTime.minute))) {
                          await _setAppointment(newDateTime);

                          setState(() {
                            note.text = '';
                            title.text = '';
                            principaleTime = [];
                            enabledDays = [];
                            timeWork = [];
                            heurreserv = [];
                            enabledTime = [];
                            enableTimeAffiche = [];
                            listRendezConflues = [];
                          });
                        } else {
                          selectedDayOcc(context,
                              '${newDateTime.day.toString().padLeft(2, '0')}/${newDateTime.month.toString().padLeft(2, '0')}/${newDateTime.year.toString().padLeft(2, '0')}-${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')} This date has been confirmed');
                        }
                      } else {
                        selectedDayOcc(context,
                            '${newDateTime.day.toString().padLeft(2, '0')}/${newDateTime.month.toString().padLeft(2, '0')}/${newDateTime.year.toString().padLeft(2, '0')}-${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')} This date has been passed');
                      }
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
    if (title.text.trim() == '') {
      setState(() {
        note.text = '';
        title.text = '';
        principaleTime = [];
        enabledDays = [];
        timeWork = [];
        heurreserv = [];
        enabledTime = [];
        enableTimeAffiche = [];
        listRendezConflues = [];
      });
      selectDec();
    }
  }

//////////////////////////////////////////////////////////////////
  ///
  ///
  ///
  ///
  ///
//////////////////////////////////////////

  Future<List> _redezSameTitle(String title) async {
    List rendezSameTitle = [];
    final event = await database
        .child('rendez')
        .orderByChild('title')
        .equalTo(title)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      rendezSameTitle = data.values.map((e) => e).toList();
    }
    return rendezSameTitle;
  }

  Future<Map> _rendezSameDaySameMedecin(DateTime newDateTime) async {
    Map rendezSameDaySameMedecin = {};
    final event = await database
        .child('rendez')
        .orderByChild('idPatient')
        .equalTo(user!.uid)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      rendezSameDaySameMedecin = data.values
          .map((e) => e)
          .where((element) =>
              element['idMedecin'] == medecin![0].id &&
              DateTime(element['year'], element['month'], element['day']) ==
                  DateTime(
                      newDateTime.year, newDateTime.month, newDateTime.day) &&
              DateTime(element['year'], element['month'], element['day'],
                      element['hour'], element['minute'])
                  .isAfter(DateTime.now()))
          .toList()
          .asMap();
    }
    return rendezSameDaySameMedecin;
  }

  Future<List<Map<String, dynamic>>> _enableDateTimePatient(
      DateTime newDateTime, int dur) async {
    List<Map<String, dynamic>> listRendezConflues = [];

    final event = await database
        .child('rendez')
        .orderByChild('idPatient')
        .equalTo(user!.uid)
        .once();

    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      listRendezConflues = data.values
          .map((e) => {
                'idMedecin': e['idMedecin'],
                'dateTime': DateTime(
                  e['year'],
                  e['month'],
                  e['day'],
                  e['hour'],
                  e['minute'],
                ),
                'dur': e['dur'],
                'title': e['title'],
              })
          .where((element) =>
              (element['dateTime']
                      .add(Duration(minutes: element['dur']))
                      .isAfter(newDateTime)) &&
                  newDateTime.isAfter(element['dateTime']) ||
              (newDateTime
                      .add(Duration(minutes: dur))
                      .isAfter(element['dateTime']) &&
                  newDateTime.isBefore(element['dateTime'])) ||
              element['dateTime'] == newDateTime)
          .toList();
    }
    return listRendezConflues;
  }

  Future<void> _setAppointment(DateTime newDateTime) {
    Completer<void> completer = Completer<void>();
    database.child('rendez').push().set({
      'title': title.text.trim(),
      'note': note.text.trim(),
      'idMedecin': medecin![0].id,
      'year': newDateTime.year,
      'month': newDateTime.month,
      'day': newDateTime.day,
      'hour': newDateTime.hour,
      'minute': newDateTime.minute,
      'idPatient': user!.uid,
      'dur': medecin![0].dur,
      'ajouterTime': DateTime.now().microsecondsSinceEpoch,
    });
    completer.complete();
    return completer.future;
  }

  Future<DateTime?> showEnabledDays() async {
    await _enebledDays();
    DateTime date = DateTime.now();
    while (!enabledDays!.contains(date.weekday)) {
      date = date.add(Duration(days: 1));
    }
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: date,
      lastDate: DateTime(2030),
      selectableDayPredicate: (DateTime day) {
        return _isDayEnabled(day);
      },
    );
    return newDate;
  }

  Future<void> _enebledDays() {
    Completer<void> completer = Completer<void>();
    database
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(medecin![0].id)
        .onValue
        .listen((event) {
      final dd = event.snapshot.value as Map;
      final data = dd.values.first;
      final daysWork = data['days_work'] as Map;
      enabledDays = daysWork.values.map((e) => e['jour'] as int).toList();
      completer.complete();
    });
    return completer.future;
  }

  Future<void> _enabledTime(DateTime newDate) {
    Completer<void> completer = Completer<void>();
    database
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(medecin![0].id)
        .onValue
        .listen((event) {
      final dd = event.snapshot.value as Map;
      final data = dd.values.first;
      final time_work =
          data['days_work']['jour${newDate.weekday}']['time_work'] as Map;
      timeWork = time_work.values.map((e) => e).toList();
      for (int i = 0; i < timeWork!.length; i++) {
        for (int j = 0; j < 60; j += medecin![0].dur) {
          principaleTime.add(TimeOfDay(hour: timeWork![i], minute: j));
        }
      }
      completer.complete();
    });
    return completer.future;
    /*database
        .child(
            'medecinsUsers/medecinUser1/days_work/jour${newDate.weekday}/time_work')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map;
      timeWork = data.values.map((e) => e).toList();
      for (int i = 0; i < timeWork!.length; i++) {
        for (int j = 0; j < 60; j += medecin![0].dur) {
          principaleTime.add(TimeOfDay(hour: timeWork![i], minute: j));
        }
      }*/
    //completer.complete();
    //});
    //return completer.future;
  }

  Future<void> desebletedTime(DateTime newDateTime) {
    Completer<void> completer = Completer<void>();
    List heurreserv = [];
    database
        .child('rendez')
        .orderByChild('idMedecin')
        .equalTo('${medecin![0].id}')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final heur = event.snapshot.value as Map;
        heurreserv = heur.values
            .map((e) => DateTime(
                e['year'], e['month'], e['day'], e['hour'], e['minute']))
            .where((element) =>
                element.year == newDateTime.year &&
                element.month == newDateTime.month &&
                element.day == newDateTime.day)
            .toList();
      } else {}
      enabledTime = principaleTime
          .where((element) =>
              !heurreserv.any((time) => (time.hour == element.hour &&
                  time.minute == element.minute)) &&
              (DateTime(newDateTime.year, newDateTime.month, newDateTime.day,
                      element.hour, element.minute)
                  .isAfter(DateTime.now())))
          .toList();
      enabledTime!.sort((a, b) => a.toString().compareTo(b.toString()));
      for (int i = 0; i < enabledTime!.length; i++) {
        enableTimeAffiche!.add(enabledTime![i]);
        enableTimeAffiche!.add(
          TimeOfDay(hour: enabledTime![i].hour, minute: 0),
        );
        enableTimeAffiche!.toSet();
      }
      completer.complete();
    });
    return completer.future;
  }

  void selectedDayOcc(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('information message'),
          content: Text(
            text,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  selectDec();
                });
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  bool _isDayEnabled(DateTime day) {
    return enabledDays!.contains(day.weekday);
  }

  bool _isTimeEnabled(TimeOfDay? time) {
    return enableTimeAffiche!.contains(time);
  }

  bool _verifierPeriode(DateTime newDateTime) {
    return (DateTime.now().isBefore(newDateTime));
  }

  //late final String categoryId;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final routeArgument =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    id = routeArgument['id'] as String;
    b = routeArgument['b'];
    //categoryId = routeArgument['categoryId'];
    _activateListeners();
    await _listDateTimeWork();
    await _listRendezMedecinPatient();
  }

  @override
  void _activateListeners() async {
    final event = await database
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(id)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      medecin = data.values
          .map((e) => Medecin(
                nomCat: e['nomCat'],
                //categoryId: categoryId,
                id: e['id'],
                nom: e['nom'],
                prenom: e['prenom'],
                adress: e['adress'],
                ville: e['ville'],
                imageUrl: e['imageUrl'],
                e_mail: e['e_mail'],
                tel: e['tel'],
                dur: e['dur'],
              ))
          .toList();
    } else {
      medecin = [];
    }
    setState(() {});
  }

  Future<void> _listDateTimeWork() async {
    //Completer<void> completer = Completer<void>();
    final event = await database
        .child('medecinsUsers')
        .orderByChild('id')
        .equalTo(id)
        .once();
    if (event.snapshot.value != null) {
      final data = event.snapshot.value as Map;
      final medecinData = data.values.first;
      final daysWorkData = medecinData['days_work'] as Map;
      listDaysTimeWork = daysWorkData.values.map((dayData) {
        final dt = dayData['time_work'] as Map;
        final daysTime = dt.values.map((e) => e).toList();
        daysTime.toSet();
        daysTime.sort((a, b) => a.compareTo(b));
        final jour = dayData['jour'];
        //final dd = daysTime.toString().replaceAll(', ', ' - ');
        //final str = dd.substring(1, dd.length - 1);
        //TimeOfDay
        return ListTileAfficher(
            dayWeek: dayWeek, jour: jour, dd: afficherHeures(daysTime));
      }).toList();
      listDaysTimeWork!.sort(((a, b) => a.jour.compareTo(b.jour)));
    } else {
      listDaysTimeWork = [];
    }
    setState(() {});
    //completer.complete();
    //return completer.future;*/
  }

  String afficherHeures(List daysTime) {
    String str = '';
    int inn = daysTime[0], c = 0, n = 1;
    bool k = true;
    for (int i = 1; i < daysTime.length; i++) {
      if ((inn + n) != (daysTime[i])) {
        str += ' ; [${inn.toString().padLeft(2, '0')} : 00 - ';
        str += '${(daysTime[i - 1] + 1).toString().padLeft(2, '0')} : 00]';
        inn = daysTime[i];
        c = i;
        n = 1;
        if (i == daysTime.length - 1) {
          k = false;
        }
      } else {
        n++;
      }
    }
    if (k) {
      str += ' , [${inn.toString().padLeft(2, '0')} : 00 - ';
      str +=
          '${(daysTime[daysTime.length - 1] + 1).toString().padLeft(2, '0')} : 00]';
    }
    return str.substring(3);
  }

  Future<void> _listRendezMedecinPatient() async {
    Completer<void> completer = Completer<void>();
    database
        .child('rendez')
        .orderByChild('idPatient')
        .equalTo(user!.uid)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        final rr = data.values
            .map((e) => {
                  'idMedecin': e['idMedecin'],
                  'title': e['title'],
                  'dateTime': DateTime(
                    e['year'],
                    e['month'],
                    e['day'],
                    e['hour'],
                    e['minute'],
                  ),
                  'ajouterTime': e['ajouterTime'],
                })
            .where((element) =>
                element['idMedecin'] == id &&
                element['dateTime'].isAfter(DateTime.now()))
            .toList();
        rr.sort((a, b) =>
            a['dateTime'].toString().compareTo(b['dateTime'].toString()));
        listRendezMedecinPatient = rr
            .map((e) => NewCard(
                title: e['title'],
                dateTime: e['dateTime'],
                ajouterTime: e['ajouterTime'],
                medecin: medecin![0]))
            .toList();
      } else {
        listRendezMedecinPatient = [];
      }
      setState(() {});
      completer.complete();
    });

    return completer.future;
  }

  Widget build(BuildContext context) {
    if (medecin == null ||
        listDaysTimeWork == null ||
        listRendezMedecinPatient == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          actions: [
            if (b)
              IconButton(
                iconSize: 35,
                onPressed: () => deleMed(),
                icon: Icon(
                  Icons.delete,
                  color: Colors.yellow.shade900,
                ),
              ),
          ],
          backgroundColor: Colors.grey.shade600,
          title: Text(
            '${medecin![0].prenom} ${medecin![0].nom}',
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  child: Column(
                    children: [
                      Card(
                        shadowColor: Colors.yellow.shade800,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.network(
                              medecin![0].imageUrl,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            //padding:
                            //EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            height: 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0),
                                  Colors.black.withOpacity(0.8)
                                ],
                                stops: [
                                  0.7,
                                  1,
                                ],
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                '${medecin![0].prenom} ${medecin![0].nom}',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: Text(
                                medecin![0].nomCat,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 20),
                                  child: Text(
                                    '${medecin![0].prenom} ${medecin![0].nom}',
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                /*SizedBox(
                                      width: ,
                                    ),*/
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 5, bottom: 0),
                                  child: Text(
                                    medecin![0].nomCat,
                                    overflow: TextOverflow.v,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),*/
                          ),
                        ]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      AfficheInfo(val: medecin![0].adress, ico: Icons.room),
                      AfficheInfo(val: medecin![0].tel, ico: Icons.call),
                      AfficheInfo(val: medecin![0].e_mail, ico: Icons.email),
                      Divider(
                        //height: 2,
                        color: Colors.black,
                      ),
                      Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Days',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  //color: Colors.yellow.shade800,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Houres',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      //color: Colors.yellow.shade800,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.alarm,
                                    color: Colors.yellow.shade800,
                                  ),
                                ],
                              ),
                            ]),
                      ),
                      Column(
                        children: listDaysTimeWork!,
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Text(
                        'Your apointement with this doctor',
                        style: TextStyle(fontSize: 20),
                      ),
                      Column(
                        children: listRendezMedecinPatient!,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          //foregroundColor: Colors.white,
          backgroundColor: Colors.grey.shade300.withOpacity(0.8),
          elevation: 0,
          onPressed: selectDec,
          /*style: TextButton.styleFrom(
                    padding: EdgeInsets.all(20),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(200),
                      ),
                    ),
                  ),*/
          child: Container(
            child: Icon(
              Icons.calendar_month,
              color: Colors.yellow.shade800,
              size: 50,
            ),
          ),
        ),
      );
    }
  }
}

class NewCard extends StatelessWidget {
  String title;
  DateTime dateTime;
  int ajouterTime;
  Medecin medecin;

  NewCard(
      {required this.title,
      required this.dateTime,
      required this.ajouterTime,
      required this.medecin});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: DateTime.now().add(Duration(hours: 24)).isAfter(dateTime)
          ? Colors.yellow.shade900
          : Colors.white,
      child: ListTile(
        textColor: DateTime.now().add(Duration(hours: 24)).isAfter(dateTime)
            ? Colors.white
            : Colors.black,
        title: Text(title),
        trailing: Text(
          DateFormat('dd/MM/yyyy-HH:mm').format(dateTime),
        ),
        onTap: () => Navigator.of(context).pushNamed('rendezDataScreen',
            arguments: {'ajouterTime': ajouterTime, 'medecin': medecin}),
      ),
    );
  }
}

class ListTileAfficher extends StatelessWidget {
  ListTileAfficher({
    required this.dayWeek,
    required this.jour,
    required this.dd,
  });

  final Map<int, String> dayWeek;
  var jour;
  final String dd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Container(
          width: 115,
          child: Text(
            dayWeek[jour]!,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dd,
            ),
          ],
        ));
  }
}
