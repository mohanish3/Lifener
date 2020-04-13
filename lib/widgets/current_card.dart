import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

//Widget that shows the current running activity
class CurrentCard extends StatelessWidget {
  final Map<String, dynamic> current;
  final Map<String, dynamic> currentInfoString;
  final String weekStartDate;

  CurrentCard({this.current, this.currentInfoString, this.weekStartDate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Tooltip(
        message:
        "Started : ${DateFormat("dd MMM yyyy - hh:mm a").format(DateTime.parse(current['startTime']))}\nWeek start :  ${DateFormat("dd MMM yyyy").format(DateTime.parse(weekStartDate))}",
        verticalOffset: 30,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1, color: Colors.black87),
            borderRadius: BorderRadius.circular(20)),
        textStyle: TextStyle(
            color: Colors.black,
            backgroundColor: Colors.white,
            fontWeight: FontWeight.w400),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(7),
            child: Column(
              children: <Widget>[
                Text(
                  currentInfoString['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                SizedBox(
                  height: 15,
                  child: (currentInfoString['timeLeftMinutes'] < 0 ||
                      currentInfoString['timeLeftHours'] < 0)
                      ?  Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 0.5),
                            color: Theme.of(context).errorColor,
                            borderRadius:
                            BorderRadius.circular(20)),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Exceeded by ${-currentInfoString['timeLeftHours']} hrs ${-currentInfoString['timeLeftMinutes']} mins',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                      : (currentInfoString['timeLeftHours'] > currentInfoString['timeAllocatedHours'] ||
                      (currentInfoString['timeLeftHours'] == currentInfoString['timeAllocatedHours'] && currentInfoString['timeLeftMinutes'] > currentInfoString['timeAllocatedMinutes'])) ? Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 0.5),
                            color: Colors.red,
                            borderRadius:
                            BorderRadius.circular(20)),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Excess: ${currentInfoString['timeLeftHours']} hrs ${currentInfoString['timeLeftMinutes']} mins / ${currentInfoString['timeAllocatedHours']} hrs ${currentInfoString['timeAllocatedMinutes']} mins',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ) : Container(
                    height: 5,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey, width: 0.5),
                              color: Color.fromRGBO(
                                  220, 220, 220, 1),
                              borderRadius:
                              BorderRadius.circular(20)),
                        ),
                        FractionallySizedBox(
                          widthFactor: (currentInfoString[
                          'timeLeftHours'] *
                              60 +
                              currentInfoString[
                              'timeLeftMinutes']) /
                              (currentInfoString[
                              'timeAllocatedHours'] *
                                  60 +
                                  currentInfoString[
                                  'timeAllocatedMinutes'] +
                                  0.00001),
                          // For divide by zero error
                          child: Container(
                            decoration: BoxDecoration(
                                color:
                                Theme.of(context).buttonColor,
                                borderRadius:
                                BorderRadius.circular(20)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${currentInfoString['timeLeftHours']} hrs ${currentInfoString['timeLeftMinutes']} mins / ${currentInfoString['timeAllocatedHours']} hrs ${currentInfoString['timeAllocatedMinutes']} mins',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
