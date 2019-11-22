import 'package:afterpay/mtnmobilemoney.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {

  TransactionDetailsPage(this._transaction);

  final AfterPayTransaction _transaction;

  Text transactionDetails(AfterPayTransaction transaction) {
    String details = "Payment plan: ${transaction.planAsString()}\n"
        "Recurring charge: ${transaction.remainingTransactions.first.getAmount.toStringAsFixed(2)} "
        "${transaction.remainingTransactions.first.getCurrency}\n"
        "Number of remaining payments: ${transaction.remainingTransactions.length}\n"
        "Remaining difference: ${transaction.remainingAmount}"
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

    final initiateNextPaymentButton = Padding(
      padding: EdgeInsets.all(8.0),
      child: RaisedButton(
        child: Text('Complete Next Transaction'),
        color: Colors.black,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
        onPressed: () {
          // Perform some action
        },
      )
    );

    var body = ListView(
      children: <Widget>[
        Card(
          child: ListTile(
            title: Text("Transaction ${_transaction.financialTransactionID}", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Payee: ${_transaction.payee}", style: TextStyle(color: Colors.black, fontSize: 21.0), textAlign: TextAlign.center),
            subtitle: transactionDetails(_transaction),
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
