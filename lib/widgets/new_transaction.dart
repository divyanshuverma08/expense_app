import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class NewTransaction extends StatefulWidget {
  final Function addNewTraction;

  NewTransaction({this.addNewTraction});

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  // String titleInput;
  final titleController = TextEditingController();

  final amountController = TextEditingController();

  DateTime _selectDate;

  void _submitData() {
    final amount = double.parse(amountController.text);
    final title = titleController.text;
    if (title.isEmpty ||
        amount <= 0 ||
        title.trim().isEmpty ||
        _selectDate == null) {
      return;
    }
    widget.addNewTraction(title.trim(), amount, _selectDate);

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then((date) {
      if (date == null) {
        return;
      } else {
        setState(() {
          _selectDate = date;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0))),
      elevation: 5,
      child: Container(
        // padding: EdgeInsets.only(
        //   top: 10,
        //   left: 10,
        //   right: 10,
        //   bottom: MediaQuery.of(context).viewInsets.bottom + 10
        // ),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Title",
              ),
              controller: titleController,
              onSubmitted: (_) => _submitData(),
              // onChanged: (value) {
              //   titleInput = value;
              // },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "Amount",
              ),
              controller: amountController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submitData(),
              // onChanged: (value) {
              //   amountInput = value;
              // },
            ),
            Container(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectDate == null
                        ? "No Date Chosen!"
                        : DateFormat.yMd().format(_selectDate),
                    style: TextStyle(fontSize: 18),
                  ),
                  Platform.isIOS
                      ? CupertinoButton(
                          child: Text(
                            "Choose Date",
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .merge(TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                          ),
                          onPressed: _presentDatePicker,
                        )
                      : FlatButton(
                          child: Text(
                            "Choose Date",
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .merge(TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                          ),
                          onPressed: _presentDatePicker,
                        )
                ],
              ),
            ),
            RaisedButton(
              child: Text("Add Transaction"),
              color: Theme.of(context).primaryColor,
              onPressed: _submitData,
              textColor: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
