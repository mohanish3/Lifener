import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

//Route for viewing the past widgets
class Report extends StatelessWidget {
  final List<String> reportList;

  Report({this.reportList});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('Reports'),
        ),
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height * 0.89,
                child: reportList.isEmpty
                    ? Center(
                        child: Column(
                        children: <Widget>[
                          Text(
                            'No reports yet!',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 25),
                          ),
                          Text(
                            'Please wait another ${Duration(days: (8-DateTime.now().weekday)).inDays} days',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 22),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                              height: 50,
                              child: Image.asset('assets/images/waiting.png',
                                  fit: BoxFit.cover)),
                        ],
                      ))
                    : ListView.builder(
                        itemCount: reportList.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> reportJson =
                              jsonDecode(reportList[index]);
                          return Card(
                              elevation: 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black87,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(children: <Widget>[
                                      Text(
                                        "${DateFormat("dd MMM yyyy").format(DateTime.parse(reportJson['startDate']))} - ${DateFormat("dd MMM yyyy").format(DateTime.parse(reportJson['startDate']).add(Duration(days: 7)))}",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      ListView.builder(
                                          itemCount:
                                              reportJson['activitiesData']
                                                  .length,
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          itemBuilder: (context, i) {
                                            var act = jsonDecode(
                                                reportJson['activitiesData']
                                                    [i]);
                                            return ListTile(
                                                leading: Text(
                                                  act['title'],
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                title: Container(
                                                  height: 5,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    Colors.grey,
                                                                width: 0.5),
                                                            color:
                                                                Color.fromRGBO(
                                                                    220,
                                                                    220,
                                                                    220,
                                                                    1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                      ),
                                                      FractionallySizedBox(
                                                        widthFactor: (act[
                                                                        'timeLeftHours'] *
                                                                    60 +
                                                                act[
                                                                    'timeLeftMinutes']) /
                                                            (act['timeAllocatedHours'] *
                                                                    60 +
                                                                act['timeAllocatedMinutes'] +
                                                                0.0001),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .buttonColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                subtitle: Center(
                                                  child: Text(
                                                      "${act['timeLeftHours']} hrs ${act['timeLeftMinutes']} mins / ${act['timeAllocatedHours']} hrs ${act['timeAllocatedMinutes']} mins"),
                                                ));
                                          })
                                    ]),
                                  )));
                        }))));
  }
}
