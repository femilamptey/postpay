import 'package:afterpay/loader.dart';
import 'package:afterpay/mtnmobilemoney.dart';
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
  State createState() => new ConfirmPaymentPageState();

  ConfirmPaymentPage(this._payee, this._amount, this._currency, this._message, this._MOMOPin);

}

class ConfirmPaymentPageState extends State<ConfirmPaymentPage> {

  ConfirmPaymentPageState();

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final half = (0.5 * widget._amount).toStringAsFixed(2);
    final halfWeekly = ((0.5 * widget._amount) / 6).toStringAsFixed(2);
    final quarter = (0.25 * widget._amount).toStringAsFixed(2);
    final quarterWeekly = ((0.75 * widget._amount) / 4).toStringAsFixed(2);
    final ten = (0.10 * widget._amount).toStringAsFixed(2);
    final tenWeekly = ((0.90 * widget._amount) / 2).toStringAsFixed(2);
    final five = (0.05 * widget._amount).toStringAsFixed(2);
    final fiveDaily = ((0.95 * widget._amount) / 7).toStringAsFixed(2);

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
            child: Text('50%\n\nPay $half ${widget._currency}vnow\n\nPay $halfWeekly weekly over 6 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            onPressed: () {
              // Perform some action
              showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.HALF, widget._amount, double.parse(half), double.parse(halfWeekly), widget._currency, widget._payee, context));
            },
            color: Colors.lightBlue,
          )
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: MaterialButton(
            child: Text('25%\n\nPay $quarter ${widget._currency} now\n\nPay $quarterWeekly weekly over 4 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            onPressed: () {
              // Perform some action
              showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.QUARTER, widget._amount, double.parse(quarter), double.parse(quarterWeekly), widget._currency, widget._payee, context));
            },
            color: Colors.green,
          )
        ),
        Container(
          padding: const EdgeInsets.all(8),
            child: MaterialButton(
              child: Text('10%\n\nPay $ten ${widget._currency} now\n\nPay $tenWeekly weekly over 2 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              onPressed: () {
                // Perform some action
                showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.TEN, widget._amount, double.parse(ten), double.parse(tenWeekly), widget._currency, widget._payee, context));
              },
              color: Colors.yellow,
            )        ),
        Container(
          padding: const EdgeInsets.all(8),
            child: MaterialButton(
              child: Text('5%\n\nPay $five ${widget._currency} now\n\n Pay $fiveDaily daily over one week', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              onPressed: () {
                // Perform some action
                showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.FIVE, widget._amount, double.parse(five), double.parse(fiveDaily), widget._currency, widget._payee, context));
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
  ConfirmationDialog(this.selectedPlan, this.amount, this.upFrontPaymentAmount, this.planPaymentAmount, this.currency, this.payee, this.contextOfPage, {this.message = ''});

  final PaymentPlan selectedPlan;
  final double amount;
  final double upFrontPaymentAmount;
  final double planPaymentAmount;
  final String currency;
  final String payee;
  final String message;
  final BuildContext contextOfPage;

  @override
  State createState() => new ConfirmationDialogState();
}

class ConfirmationDialogState extends State<ConfirmationDialog> {

  bool _isButtonDisabled = false;
  Color _isClickedColor = Colors.black;

  ConfirmationDialogState();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {

    // ignore: missing_return
    Text getPlan() {
      switch (widget.selectedPlan) {
        case PaymentPlan.HALF:
          return Text("Plan: Half");
          break;
        case PaymentPlan.QUARTER:
          return Text("Plan: Quarter");
          break;
        case PaymentPlan.TEN:
          return Text("Plan: Ten");
          break;
        case PaymentPlan.FIVE:
          return Text("Plan: Five");
          break;
      }
    }

      return new AlertDialog(
        content: new Column(
          children: <Widget>[
            getPlan(),
            Text("Paid to: ${widget.payee}"),
            Text("Upfront Payment: ${widget.upFrontPaymentAmount} ${widget.currency}"),
            Text("Recurring charge: ${widget.planPaymentAmount} ${widget.currency}")
          ],
          mainAxisSize: MainAxisSize.min,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel', style: TextStyle(color: _isClickedColor)),
            onPressed: () {
              if (!_isButtonDisabled) {
                Navigator.pop(context);
              }
            },
          ),
          FlatButton(
            child: Text('Pay', style: TextStyle(color: _isClickedColor)),
            onPressed: () async {
              if (!_isButtonDisabled) {
                setState(() {
                  _isButtonDisabled = true;
                  _isClickedColor = Colors.grey;
                });
                print(AfterPayTransaction(widget.payee, widget.amount, widget.selectedPlan, widget.currency, widget.message).toString());
                MTNMobileMoney.createAPIUser().then((response) {
                  MTNMobileMoney.getAPIKey().then((response) {
                    MTNMobileMoney.getDisbursementToken().then((response) {
                      MTNMobileMoney.transferMoney(
                          widget.upFrontPaymentAmount, widget.currency,
                          widget.payee, widget.message).then((response) {
                        Navigator.pop(context, 'cancel');
                        Navigator.pushReplacementNamed(context, ColorLoader.tag);
                      });
                    });
                  });
                });
              } else {

              }
            },
          ),
        ],
      );
    }
}



