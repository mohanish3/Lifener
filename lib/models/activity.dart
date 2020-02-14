import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

//Model for each Activity
class Activity {
  String id;
  String title;
  int timeAllocatedHours;
  int timeAllocatedMinutes;
  int timeLeftHours;
  int timeLeftMinutes;

  Activity(
      {@required this.title,
      @required this.timeAllocatedHours,
      @required this.timeAllocatedMinutes,
      @required this.timeLeftHours,
      @required this.timeLeftMinutes}) {
    var uuid = Uuid();
    this.id = uuid.v4(); // Gets unique ID for each activity
  }

  String get getId {
    return id;
  }

  int get getTimeLeftHours {
    return timeLeftHours;
  }

  int get getTimeLeftMinutes {
    return timeLeftMinutes;
  }

  int get getTimeAllocatedHours {
    return timeAllocatedHours;
  }

  int get getTimeAllocatedMinutes {
    return timeAllocatedMinutes;
  }

  //Converts Activity to Json format
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'timeAllocatedHours': timeAllocatedHours,
        'timeAllocatedMinutes': timeAllocatedMinutes,
        'timeLeftHours': timeLeftHours,
        'timeLeftMinutes': timeLeftMinutes,
      };

  //Converts to activity from Json format
  Activity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        timeAllocatedHours = json['timeAllocatedHours'],
        timeLeftHours = json['timeLeftHours'],
        timeAllocatedMinutes = json['timeAllocatedMinutes'],
        timeLeftMinutes = json['timeLeftMinutes'];

  //Changes parameters for an Activity object
  void changeTimeAllocated(int newTimeLeftHours, int newTimeLeftMinutes,
      int timeNewHours, int timeNewMinutes) {
    timeLeftHours = newTimeLeftHours;
    timeLeftMinutes = newTimeLeftMinutes;
    timeAllocatedHours = timeNewHours;
    timeAllocatedMinutes = timeNewMinutes;
  }
}
