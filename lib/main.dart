import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifener/widgets/current_card.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifener/widgets/activities_list.dart';
import 'package:lifener/widgets/add_activity.dart';

import 'package:lifener/models/activity.dart';
import 'package:lifener/report.dart';
import 'package:lifener/utilities/time_functions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return MaterialApp(
      title: 'Lifener',
      theme: ThemeData(
        primaryColor: Colors.white,
        bottomAppBarColor: Colors.white,
        accentColor: Colors.grey,
        errorColor: Colors.deepPurple[900],
        buttonColor: Colors.deepOrange,
        fontFamily: 'Quicksand',
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Map<String, dynamic> _current; //Stores id and use times of running activity

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //Used for snackbars

  SharedPreferences prefs;

  Map<String, dynamic>
      _currentInfoString; //Activity details about running activity

  String _weekStartDate; //Date converted string for the week startDate

  List<String>
      _activitiesList; //Stores list of jsons of activities in string format
  List<String> _reportList; //Stores list of past activities in string format

  _HomePageState() {
    _current = {
      "id": "",
      "startTime": DateTime.now().toIso8601String(),
      "updateTime": DateTime.now().toIso8601String(),
    };
    _weekStartDate = DateTime.now().toIso8601String();
    _currentInfoString = {
      'title': "",
      'timeLeftHours': 0,
      'timeAllocatedHours': 0,
      'timeLeftMinutes': 0,
      'timeAllocatedMinutes': 0
    };
    _activitiesList = [];
    _reportList = [];
    getSharedPrefs();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    updateTimeLeft(DateTime.now());
  }

  //Initializes local storage and checks for first time initialization
  void getSharedPrefs() async {
    this.prefs = await SharedPreferences.getInstance();
    String currentJson = prefs.getString("_current");
    _weekStartDate = prefs.getString("_weekStartDate");

    if (currentJson == null) {
      var freeActivity = Activity(
        title: 'Free Time',
        timeAllocatedHours: 168,
        timeAllocatedMinutes: 0,
        timeLeftHours: 168,
        timeLeftMinutes: 0,
      );

      setState(() {
        _activitiesList.add(jsonEncode(freeActivity));
      });

      _current = {
        "id": freeActivity.getId,
        "startTime": DateTime.now().toIso8601String(),
        "updateTime": DateTime.now().toIso8601String(),
      };

      DateTime firstMonday =
          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      firstMonday = new DateTime(
          firstMonday.year, firstMonday.month, firstMonday.day, 0, 0, 0, 0, 0);
      _weekStartDate = firstMonday.toIso8601String();

      prefs.setString("_current", jsonEncode(_current));
      prefs.setStringList("activities", _activitiesList);
      prefs.setStringList("reportList", _reportList);
      prefs.setString("_weekStartDate", _weekStartDate);
    } else {
      setState(() {
        _activitiesList = prefs.getStringList("activities");
        _reportList = prefs.getStringList("reportList");
      });
      _current = jsonDecode(currentJson);
    }
    setState(() {
      getCurrentInfo();
    });
    updateTimeLeft(DateTime.now());
  }

  void _displayTimeSnackbar(BuildContext context, String text) {
    final snackbar = SnackBar(content: Text(text));
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  //Stores data in local storage
  void activityListPreferences() async {
    prefs.setString("_current", jsonEncode(_current));
    prefs.setStringList("activities", _activitiesList);
    prefs.setStringList("reportList", _reportList);
  }

  //gets info about the current activity in currentInfoString
  void getCurrentInfo() {
    Activity currentActivity;
    for (int i = 0; i < _activitiesList.length; i++) {
      if (_current['id'] == jsonDecode(_activitiesList[i])['id']) {
        currentActivity = Activity.fromJson(jsonDecode(_activitiesList[i]));
        break;
      }
    }

    _currentInfoString = {
      'title': currentActivity.title,
      'timeLeftHours': currentActivity.timeLeftHours,
      'timeLeftMinutes': currentActivity.timeLeftMinutes,
      'timeAllocatedHours': currentActivity.timeAllocatedHours,
      'timeAllocatedMinutes': currentActivity.timeAllocatedMinutes,
    };
  }

  //Opens up the ModalBottomSheet for input
  void _startAddNewActivity(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return Wrap(
            children: <Widget>[
              GestureDetector(
                child: AddActivity(addActivity: _addNewActivity),
                onTap: () {},
                behavior: HitTestBehavior.opaque,
              ),
            ],
          );
        });
  }

  //Adds new activity after a few checks
  void _addNewActivity(String acTitle, int acTimeHours, int acTimeMinutes) {
    Activity freeActivity;
    int index;
    for (int i = 0; i < _activitiesList.length; i++) {
      if (jsonDecode(_activitiesList[i])['title'] == 'Free Time') {
        freeActivity = Activity.fromJson(jsonDecode(_activitiesList[i]));
        index = i;
      }
    }
    int timeUnallocatedHours = freeActivity.getTimeAllocatedHours;
    int timeUnallocatedMinutes = freeActivity.getTimeAllocatedMinutes;
    int timeLeftHours = freeActivity.getTimeLeftHours;
    int timeLeftMinutes = freeActivity.getTimeLeftMinutes;

    //Insufficient time check
    if (acTimeHours > timeUnallocatedHours ||
        (acTimeHours == timeUnallocatedHours &&
            acTimeMinutes > timeUnallocatedMinutes)) {
      _displayTimeSnackbar(context, "Insufficient time available");
      return;
    }

    int acTimeLeftHours;
    int acTimeLeftMinutes;
    if (acTimeHours > timeLeftHours ||
        (acTimeHours == timeLeftHours && acTimeMinutes > timeLeftMinutes)) {
      acTimeLeftHours = timeLeftHours;
      acTimeLeftMinutes = timeLeftMinutes;
      timeLeftHours = 0;
      timeLeftMinutes = 0;
    } else {
      acTimeLeftHours = acTimeHours;
      acTimeLeftMinutes = acTimeMinutes;
      var newTime = TimeFunctions.subtractTime(
          timeLeftHours, timeLeftMinutes, acTimeHours, acTimeMinutes);
      timeLeftHours = newTime['hours'];
      timeLeftMinutes = newTime['minutes'];
    }

    final Activity newActivity = Activity(
        title: acTitle,
        timeAllocatedHours: acTimeHours,
        timeAllocatedMinutes: acTimeMinutes,
        timeLeftHours: acTimeLeftHours,
        timeLeftMinutes: acTimeLeftMinutes);

    Map<String, dynamic> newTime;

    setState(() {
      _activitiesList.removeAt(index);
      newTime = TimeFunctions.subtractTime(timeUnallocatedHours,
          timeUnallocatedMinutes, acTimeHours, acTimeMinutes);
      freeActivity.changeTimeAllocated(
          timeLeftHours, timeLeftMinutes, newTime['hours'], newTime['minutes']);

      _activitiesList.add(jsonEncode(newActivity));
      _activitiesList.add(jsonEncode(freeActivity));
      timeUnallocatedHours = newTime['hours'];
      timeUnallocatedMinutes = newTime['minutes'];
      timeLeftHours = timeLeftHours;
      timeLeftMinutes = timeLeftMinutes;
      getCurrentInfo();
    });
    activityListPreferences();
  }

  //Deletes an activity after the delete button is pressed
  void _deleteActivity(int index) {
    int acTimeHours = jsonDecode(_activitiesList[index])['timeAllocatedHours'];
    int acTimeMinutes =
        jsonDecode(_activitiesList[index])['timeAllocatedMinutes'];
    Activity freeActivity;
    int acTimeLeftHours = jsonDecode(_activitiesList[index])['timeLeftHours'];
    int acTimeLeftMinutes =
        jsonDecode(_activitiesList[index])['timeLeftMinutes'];
    String idDeleted = jsonDecode(_activitiesList[index])['id'];
    _activitiesList.removeAt(index);
    int loc;
    for (int i = 0; i < _activitiesList.length; i++) {
      if (jsonDecode(_activitiesList[i])['title'] == 'Free Time') {
        freeActivity = Activity.fromJson(jsonDecode(_activitiesList[i]));
        loc = i;
        if (idDeleted == _current['id']) {
          _setCurrent(loc);
        }
        break;
      }
    }
    int timeUnallocatedHours = freeActivity.getTimeAllocatedHours;
    int timeUnallocatedMinutes = freeActivity.getTimeAllocatedMinutes;
    int timeLeftHours = freeActivity.getTimeLeftHours;
    int timeLeftMinutes = freeActivity.getTimeLeftMinutes;

    Map<String, dynamic> newTime = TimeFunctions.addTime(timeUnallocatedHours,
        timeUnallocatedMinutes, acTimeHours, acTimeMinutes);
    var newTimeLeft = TimeFunctions.addTime(
        timeLeftHours, timeLeftMinutes, acTimeLeftHours, acTimeLeftMinutes);
    timeLeftHours = newTimeLeft['hours'];
    timeLeftMinutes = newTimeLeft['minutes'];
    setState(() {
      timeUnallocatedHours = newTime['hours'];
      timeUnallocatedMinutes = newTime['minutes'];
      freeActivity.changeTimeAllocated(timeLeftHours, timeLeftMinutes,
          timeUnallocatedHours, timeUnallocatedMinutes);
      if (freeActivity == null)
        freeActivity = Activity(
          title: 'Free Time',
          timeAllocatedHours: acTimeHours,
          timeAllocatedMinutes: acTimeMinutes,
          timeLeftHours: acTimeHours,
          timeLeftMinutes: acTimeMinutes,
        );
      _activitiesList.removeAt(loc);
      _activitiesList.add(jsonEncode(freeActivity));
      getCurrentInfo();
    });
    activityListPreferences();
  }

  //Changes te time left of the running activity
  void changeCurrentTimeLeft(int hours, int minutes) {
    for (int i = 0; i < _activitiesList.length; i++) {
      if (_current['id'] == jsonDecode(_activitiesList[i])['id']) {
        Map<String, dynamic> act;
        act = jsonDecode(_activitiesList[i]);
        setState(() {
          act['timeLeftHours'] = hours;
          act['timeLeftMinutes'] = minutes;
          _activitiesList[i] = jsonEncode(act);
        });
      }
    }
    getCurrentInfo();
  }

  //Prepares weekly report for all activities and resets the variables for the new week
  void prepareReportAndReset(DateTime start) {
    Map<String, dynamic> reportObject = {
      'startDate': start.toIso8601String(),
      'activitiesData': _activitiesList,
    };
    _reportList.add(jsonEncode(reportObject));

    for (int i = 0; i < _activitiesList.length; i++) {
      Map<String, dynamic> act = jsonDecode(_activitiesList[i]);
      act['timeLeftHours'] = act['timeAllocatedHours'];
      act['timeLeftMinutes'] = act['timeAllocatedMinutes'];
      _activitiesList[i] = jsonEncode(act);
    }

    int timeElapsed =
        DateTime.now().difference(start.add(Duration(days: 7))).inMinutes;
    Map<String, dynamic> newTime = TimeFunctions.subtractTime(
        _currentInfoString['timeAllocatedHours'],
        _currentInfoString['timeAllocatedMinutes'],
        (timeElapsed / 60).floor(),
        timeElapsed % 60);
    changeCurrentTimeLeft(newTime['hours'], newTime['minutes']);
    activityListPreferences();
  }

  //Reloads the running activity time left and checks for weekly report
  //This function runs on every state change
  void updateTimeLeft(DateTime currentTime) {
    Duration weeklyDuration =
        currentTime.difference(DateTime.parse(_weekStartDate));
    while (weeklyDuration.inDays >= 7) {
      prepareReportAndReset(DateTime.parse(_weekStartDate));
      _current['startTime'] = DateTime.parse(_weekStartDate)
          .add(Duration(days: 7))
          .toIso8601String();
      _current['updateTime'] = _current['startTime'];
    }

    DateTime previousTime = DateTime.parse(_current['updateTime']);
    Duration difference = currentTime.difference(previousTime);
    int subMins, subHours;
    if (difference.inMinutes >= 60)
      subHours = (difference.inMinutes / 60).floor();
    else
      subHours = 0;
    subMins = difference.inMinutes % 60;

    Map<String, dynamic> newTimeLeft = TimeFunctions.subtractTime(
        _currentInfoString['timeLeftHours'],
        _currentInfoString['timeLeftMinutes'],
        subHours,
        subMins);

    if (subHours > 0 || subMins > 0) {
      _current['updateTime'] = currentTime.toIso8601String();
      changeCurrentTimeLeft(newTimeLeft['hours'], newTimeLeft['minutes']);
    }
    activityListPreferences();
  }

  //Changes the current state on pressing the activate button
  void _setCurrent(int index) {
    DateTime currentTime = DateTime.now();

    if (_current['id'] != jsonDecode(_activitiesList[index])['id']) {
      setState(() {
        _current['id'] = jsonDecode(_activitiesList[index])['id'];
        if (currentTime
                .difference(DateTime.parse(_current['startTime']))
                .inMinutes >
            0) _current['startTime'] = currentTime.toIso8601String();
        _current['updateTime'] = currentTime.toIso8601String();
        getCurrentInfo();
      });
    }

    updateTimeLeft(currentTime);
    activityListPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromARGB(248, 255, 255, 255),
      appBar: AppBar(
        title: Row(children: <Widget>[
          Container(
            height: 25,
            child: Image.asset('assets/images/lifener.png', fit: BoxFit.cover),
          ),
          Text(
            'ifener',
            style: TextStyle(color: Colors.black87, fontSize: 22),
          ),
        ]),
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.timeline,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => Report(reportList: _reportList))),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.black87,
            ),
            onPressed: () => _startAddNewActivity(context),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
            onPressed: () => updateTimeLeft(DateTime.now()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            CurrentCard(
              current: _current,
              currentInfoString: _currentInfoString,
              weekStartDate: _weekStartDate,
            ),
            SizedBox(
              height: 5,
            ),
            ActivitiesList(
              activitiesList: _activitiesList,
              deleteItem: _deleteActivity,
              setCurrent: _setCurrent,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () => _startAddNewActivity(context),
        backgroundColor: Theme.of(context).buttonColor,
        elevation: 5,
      ),
    );
  }
}
