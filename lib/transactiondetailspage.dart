import 'dart:io';

import 'package:postpay/mtnmobilemoney.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'loader.dart';
import 'loaderpage.dart';

// ignore: must_be_immutable
class TransactionDetailsPage extends StatefulWidget {

  TransactionDetailsPage(this._transaction) {
    this._nextTransaction = this._transaction.remainingTransactions.first;
  }

  final PostPayTransaction _transaction;
  MOMOTransaction _nextTransaction;

  @override
  _TransactionDetailsPageState createState() => _TransactionDetailsPageState();

}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {

  Text transactionDetails(PostPayTransaction transaction, MOMOTransaction nextTransaction) {
    String details = "Payment plan: ${transaction.planAsString()}\n"
        "Recurring charge: ${nextTransaction.getAmount.toStringAsFixed(2)} "
        "${nextTransaction.getCurrency}\n"
        "Number of remaining payments: ${transaction.remainingTransactions.length}\n"
        "Total charge: ${transaction.totalAmount.toStringAsFixed(2)} "
        "${nextTransaction.getCurrency}\n"
        "Remaining difference: ${transaction.remainingAmount.toStringAsFixed(2)} "
        "${nextTransaction.getCurrency}"
    ;

    return Text(details, style: TextStyle(color: Colors.black, fontSize: 21.0), textAlign: TextAlign.center);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final appBar = new AppBar(
      title: Text("Transaction Details", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final alertDialog =  AlertDialog(
        content: new Column(
          children: [ColorLoader(), Text("\nInitiating payment...")],
          mainAxisSize: MainAxisSize.min,
        )
    );

    final initiateNextPaymentButton = Padding(
        padding: EdgeInsets.all(8.0),
        child: RaisedButton(
          child: Text('Complete Next Transaction'),
          color: Colors.black,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
          onPressed: () {
            // Perform some action
            showDialog(context: context, barrierDismissible: false, builder: (context) => alertDialog);
            MTNMobileMoney.createAPIUser().then((onValue) {
              MTNMobileMoney.getAPIKey().then((onValue) {
                MTNMobileMoney.getDisbursementToken().then((onValue) {
                  MTNMobileMoney.payNextPostPayTransaction(widget._nextTransaction.getAmount, widget._nextTransaction.getCurrency, widget._transaction.payee, widget._nextTransaction.getMessage)
                  .then((onValue) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                      return ColorLoaderPage(widget._transaction.payee, widget._nextTransaction.getAmount, widget._transaction.paymentPlan, widget._nextTransaction.getCurrency, widget._nextTransaction.getMessage, true, continuingTransaction: this.widget._transaction);
                    }));
                  });
                });
              });
            });
          },
        )
    );

    var body = ListView(
      children: <Widget>[
        Card(
          child: ListTile(
            title: Text("Transaction ${widget._transaction.financialTransactionID}", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Payee: ${widget._transaction.payee}", style: TextStyle(color: Colors.black, fontSize: 21.0), textAlign: TextAlign.center),
            subtitle: transactionDetails(widget._transaction, widget._nextTransaction),
          ),
        ),
        initiateNextPaymentButton
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }

}