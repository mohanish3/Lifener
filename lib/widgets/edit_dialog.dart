import 'package:flutter/material.dart';

class EditDialog extends StatefulWidget {
  final Function updateItem;
  final int index;
  final dynamic item;
  final dynamic freeTime;

  EditDialog({this.updateItem, this.index, this.item, this.freeTime});

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  bool _switchState = false;
  bool _exceeded = false;
  double _sliderValue = 0;
  int _enteredValue = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black87),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Text('Ok'),
                onPressed: () {
                  widget.updateItem(_switchState, _exceeded, widget.index, _enteredValue);
                  Navigator.pop(context);
                },
                color: Theme.of(context).buttonColor,
              ),
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Container(
                height: _switchState ? 230 : 280,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Edit Activity',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.item['title'],
                      style:
                      TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Remaining'),
                        Switch(
                          activeColor: Theme.of(context).buttonColor,
                          onChanged: (value) {
                            setState(() {
                              _switchState = value;
                              _exceeded = false;
                              _sliderValue = 0;
                              _enteredValue = 0;
                            });
                          },
                          value: _switchState,
                        ),
                        Text('Allocated'),
                      ],
                    ),
                    _switchState
                        ? Container()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                                Checkbox(
                                  value: _exceeded,
                                  activeColor: Theme.of(context).buttonColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _exceeded = value;
                                      _sliderValue = 0;
                                      _enteredValue = 0;
                                    });
                                  },
                                ),
                                Text(
                                  'Exceeded?',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '0 hrs 0 mins',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(_exceeded
                                      ? '${widget.freeTime['timeAllocatedHours']} hrs ${widget.freeTime['timeAllocatedMinutes']} mins'
                                      : _switchState ? '${widget.item['timeAllocatedHours'] + widget.freeTime['timeAllocatedHours'] + ((widget.item['timeAllocatedMinutes'] + widget.freeTime['timeAllocatedMinutes']) / 60).floor()} hrs ${(widget.item['timeAllocatedMinutes'] + widget.freeTime['timeAllocatedMinutes']) % 60} mins' : '${widget.item['timeAllocatedHours']} hrs ${widget.item['timeAllocatedMinutes']} mins',
                              style: TextStyle(fontSize: 12))
                        ]),
                    Slider(
                      activeColor: Theme.of(context).buttonColor,
                      value: _sliderValue,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                          if (_exceeded)
                            _enteredValue = (_sliderValue *
                                    (widget.freeTime['timeAllocatedHours'] * 60 +
                                        widget.freeTime['timeAllocatedMinutes']))
                                .floor();
                          else {
                            if(_switchState)
                              _enteredValue = (_sliderValue *
                                  (widget.freeTime['timeAllocatedHours'] * 60 +
                                      widget.freeTime['timeAllocatedMinutes'] + widget.item['timeAllocatedHours'] * 60 + widget.item['timeAllocatedMinutes']))
                                  .floor();
                            else
                            _enteredValue = (_sliderValue *
                                (widget.item['timeAllocatedHours'] * 60 +
                                    widget.item['timeAllocatedMinutes']))
                                .floor();
                          }
                        });
                      },
                    ),
                    Text('New time:'),
                    Text(
                        '${(_enteredValue / 60).floor()} hrs ${_enteredValue % 60} mins',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w400))
                  ],
                )));
  }
}
