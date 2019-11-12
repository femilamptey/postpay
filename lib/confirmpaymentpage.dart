import 'package:afterpay/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmPaymentPage extends StatefulWidget {
  static final String tag = 'confirm-payment-page';

  final String _payee;
  final double _amount;
  final String _currency;
  final String _message;
  final int _MOMOPin;

  @override
  State createState() => new ConfirmPaymentPageState(_payee, _amount, _currency, _message, _MOMOPin);

  ConfirmPaymentPage(this._payee, this._amount, this._currency, this._message, this._MOMOPin);

}

class ConfirmPaymentPageState extends State<ConfirmPaymentPage> {

  ConfirmPaymentPageState(this._payee, this._amount, this._currency, this._message, this._MOMOPin);

  final String _payee;
  final double _amount;
  final String _currency;
  final String _message;
  final int _MOMOPin;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final half = (0.5 * _amount).toStringAsFixed(2);
    final halfWeekly = ((0.5 * _amount) / 6).toStringAsFixed(2);
    final quarter = (0.25 * _amount).toStringAsFixed(2);
    final quarterWeekly = ((0.75 * _amount) / 4).toStringAsFixed(2);
    final ten = (0.10 * _amount).toStringAsFixed(2);
    final tenWeekly = ((0.90 * _amount) / 2).toStringAsFixed(2);
    final five = (0.05 * _amount).toStringAsFixed(2);
    final fiveDaily = ((0.95 * _amount) / 7).toStringAsFixed(2);

    final appBar = new AppBar(
      title: Text("Confirm Payment", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final optionsGrid = GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          child: MaterialButton(
            child: Text('50%\n\nPay $_currency $half now\n\nPay $halfWeekly weekly over 6 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            onPressed: () {
              // Perform some action
              setState(() {
                isLoading = true;
              });
              showDialog(context: context, builder: (context) => new ConfirmationDialog("6 Weeks", half, halfWeekly, _currency, _payee, context));
            },
            color: Colors.lightBlue,
          )
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: MaterialButton(
            child: Text('25%\n\nPay $_currency $quarter now\n\nPay $quarterWeekly weekly over 4 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            onPressed: () {
              // Perform some action
              showDialog(context: context, builder: (context) => new ConfirmationDialog("4 Weeks", quarter, quarterWeekly, _currency, _payee, context));
            },
            color: Colors.green,
          )
        ),
        Container(
          padding: const EdgeInsets.all(8),
            child: MaterialButton(
              child: Text('10%\n\nPay $_currency $ten now\n\nPay $tenWeekly weekly over 2 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              onPressed: () {
                // Perform some action
                showDialog(context: context, builder: (context) => new ConfirmationDialog("2 Weeks", ten, tenWeekly, _currency, _payee, context));
              },
              color: Colors.yellow,
            )        ),
        Container(
          padding: const EdgeInsets.all(8),
            child: MaterialButton(
              child: Text('5%\n\nPay $_currency $five now\n\n Pay $fiveDaily daily over one week', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              onPressed: () {
                // Perform some action
                showDialog(context: context, builder: (context) => new ConfirmationDialog("7 Days", five, fiveDaily, _currency, _payee, context));
              },
              color: Colors.red,
            )        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
        child: optionsGrid,
      ),
    );
  }

}


class ConfirmationDialog extends StatefulWidget {
  ConfirmationDialog(this.selectedPlan, this.upFrontPaymentAmount, this.planPaymentAmount, this.currency, this.payee, this.contextOfPage);

  final String selectedPlan;
  final String upFrontPaymentAmount;
  final String planPaymentAmount;
  final String currency;
  final String payee;
  final BuildContext contextOfPage;

  @override
  State createState() => new ConfirmationDialogState(selectedPlan, upFrontPaymentAmount, planPaymentAmount, currency, payee, contextOfPage);
}

class ConfirmationDialogState extends State<ConfirmationDialog> {

  ConfirmationDialogState(this.selectedPlan, this.upFrontPaymentAmount, this.planPaymentAmount, this.currency, this.payee, this.contextOfPage);

  final String selectedPlan;
  final String upFrontPaymentAmount;
  final String planPaymentAmount;
  final String currency;
  final String payee;
  final BuildContext contextOfPage;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {

    return new AlertDialog(
      content: new Column(
        children: <Widget>[
          Text("Plan: $selectedPlan"),
          Text("Paid to: $payee"),
          Text("Upfront Payment: $upFrontPaymentAmount $currency"),
          Text("Recurring charge: $planPaymentAmount $currency")
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: const Text('Pay'),
          onPressed: () async {
            Navigator.pop(context, 'cancel');
            Navigator.pushReplacementNamed(context, ColorLoader.tag);
          },
        ),
      ],
    );
  }

}

