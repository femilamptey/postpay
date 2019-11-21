import 'package:afterpay/mtnmobilemoney.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {

  TransactionDetailsPage(this._transaction);

  final AfterPayTransaction _transaction;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final appBar = new AppBar(
      title: Text("Transaction Details", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final initiateNextPaymentButton = RaisedButton(
      child: const Text('RAISED BUTTON', semanticsLabel: 'RAISED BUTTON 1'),
      onPressed: () {
        // Perform some action
      },
    );

    var body = ListView(
      children: <Widget>[

      ],
    );

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }

}
