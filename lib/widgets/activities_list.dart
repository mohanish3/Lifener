import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifener/widgets/edit_dialog.dart';

//Gets the ListView for each activity running
class ActivitiesList extends StatelessWidget {
  final List<String> activitiesList;
  final Function deleteItem;
  final Function setCurrent;
  final Function updateItem;

  ActivitiesList(
      {this.activitiesList, this.deleteItem, this.setCurrent, this.updateItem});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.80,
        child: activitiesList.isEmpty
            ? Column(
                children: <Widget>[
                  Text(
                    'No Activities added yet!',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      height: 100,
                      child: Image.asset('assets/images/waiting.png',
                          fit: BoxFit.cover)),
                ],
              )
            : ListView.builder(
                itemCount: activitiesList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> actJson =
                      jsonDecode(activitiesList[index]);
                  return Tooltip(
                    message: (actJson['timeLeftHours'] >= 0 &&
                            actJson["timeLeftMinutes"] >= 0)
                        ? "Time remaining: ${actJson['timeLeftHours']} hrs ${actJson['timeLeftMinutes']} mins"
                        : "Time exceeded: ${-actJson['timeLeftHours']} hrs ${-actJson['timeLeftMinutes']} mins",
                    verticalOffset: 30,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: Colors.black87),
                        borderRadius: BorderRadius.circular(20)),
                    textStyle: TextStyle(
                        color: Colors.black, backgroundColor: Colors.white),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        onTap: () {
                          if (index != activitiesList.length - 1)
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return EditDialog(
                                      updateItem: updateItem,
                                      index: index,
                                      item: actJson,
                                      freeTime: jsonDecode(activitiesList[
                                          activitiesList.length - 1]));
                                });
                        },
                        title: Text(
                          actJson['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87),
                          overflow: TextOverflow.fade,
                        ),
                        contentPadding: EdgeInsets.all(1),
                        subtitle: Container(
                          height: 5,
                          child: (actJson['timeLeftHours'] < 0 ||
                                  actJson['timeLeftMinutes'] < 0)
                              ? Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5),
                                      color: Theme.of(context).errorColor,
                                      borderRadius: BorderRadius.circular(20)),
                                )
                              : (actJson['timeLeftHours'] > actJson['timeAllocatedHours'] ||
                              (actJson['timeLeftHours'] == actJson['timeAllocatedHours'] && actJson['timeLeftMinutes'] > actJson['timeAllocatedMinutes'])) ? Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey, width: 0.5),
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20)),
                          ) : Stack(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 0.5),
                                          color:
                                              Color.fromRGBO(220, 220, 220, 1),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: (actJson['timeLeftHours'] *
                                                  60 +
                                              actJson['timeLeftMinutes']) /
                                          (actJson['timeAllocatedHours'] * 60 +
                                              actJson['timeAllocatedMinutes'] +
                                              0.0001),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).buttonColor,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        leading: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(style: BorderStyle.solid)),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: Text(
                            '${actJson['timeAllocatedHours']} hrs ${actJson['timeAllocatedMinutes']} mins',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.grey[800],
                              ),
                              onPressed: () => setCurrent(index),
                            ),
                            actJson['title'] != "Free Time"
                                ? IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.grey[800]),
                                    onPressed: () => deleteItem(index),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ));
  }
}
