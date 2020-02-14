import 'package:flutter/material.dart';

//Bottom modal sheet widget
class AddActivity extends StatefulWidget {
  final Function addActivity;

  AddActivity({this.addActivity});

  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  final titleController = TextEditingController();
  final timeAllocatedHoursController = TextEditingController();
  final timeAllocatedMinutesController = TextEditingController();

  //Check input TextFields
  //Passes input to addActivity() if valid
  void addData() {
    final String enteredTitle = titleController.text;
    final String enteredAmountHours = timeAllocatedHoursController.text;
    final String enteredAmountMinutes = timeAllocatedMinutesController.text;

    if (enteredTitle.isEmpty ||
        (enteredAmountHours.isEmpty && enteredAmountMinutes.isEmpty)) return;

    int hours, minutes;
    if (enteredAmountHours.isEmpty) {
      if (int.tryParse(enteredAmountMinutes) == null ||
          int.tryParse(enteredAmountMinutes) <= 0) return;
      minutes = int.parse(enteredAmountMinutes);
      hours = 0;
    } else if (enteredAmountMinutes.isEmpty) {
      if (int.tryParse(enteredAmountHours) == null ||
          int.tryParse(enteredAmountHours) <= 0) return;
      hours = int.parse(enteredAmountHours);
      minutes = 0;
    } else {
      if (int.tryParse(enteredAmountMinutes) == null ||
          int.tryParse(enteredAmountHours) == null ||
          int.tryParse(enteredAmountMinutes) < 0 ||
          int.tryParse(enteredAmountHours) < 0) return;
      hours = int.parse(enteredAmountHours);
      minutes = int.parse(enteredAmountMinutes);
    }

    if (minutes >= 60) {
      hours += (minutes / 60).floor();
      minutes %= 60;
    }

    widget.addActivity(enteredTitle, hours, minutes);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(border: Border.all()),
        padding: EdgeInsets.all(5),
        child: Padding(
          padding: MediaQuery
              .of(context)
              .viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Add New Activity',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Activity name'),
                controller: titleController,
                onSubmitted: (_) => addData,
              ),
              Text(
                'Time: ',
                style: TextStyle(fontSize: 20),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Hours'),
                controller: timeAllocatedHoursController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => addData,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Minutes'),
                controller: timeAllocatedMinutesController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => addData,
              ),
              FlatButton(
                color: Theme
                    .of(context)
                    .buttonColor,
                textColor: Colors.white,
                child: Text('Add new'),
                onPressed: addData,
              )
            ],
          ),
        ),
      ),
    );
  }
}
