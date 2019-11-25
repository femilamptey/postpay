import 'package:afterpay/loader.dart';
import 'package:afterpay/loaderpage.dart';
import 'package:afterpay/mtnmobilemoney.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmPaymentPage extends StatefulWidget {
  static final String tag = 'confirm-payment-page';

  final String _payee;
  final double _amount;
  final String _currency;
  final String _message;
  final String _MOMOPin;
  final bool isCredit; // 1 is credit, 0 is debit

  @override
  State createState() => new ConfirmPaymentPageState();

  ConfirmPaymentPage(this._payee, this._amount, this._currency, this._message, this._MOMOPin, this.isCredit);

}

class ConfirmPaymentPageState extends State<ConfirmPaymentPage> {

  ConfirmPaymentPageState();

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final half = (0.5 * widget._amount).toStringAsFixed(2);
    final halfWeeklyDebit = ((0.5 * widget._amount) / 6).toStringAsFixed(2);
    final credit8Weeks = (widget._amount / 8).toStringAsFixed(2);
    final quarter = (0.25 * widget._amount).toStringAsFixed(2);
    final quarterWeeklyDebit = ((0.75 * widget._amount) / 4).toStringAsFixed(2);
    final credit6Weeks = (widget._amount / 6).toStringAsFixed(2);
    final tenth = (0.10 * widget._amount).toStringAsFixed(2);
    final tenthWeeklyDebit = ((0.90 * widget._amount) / 2).toStringAsFixed(2);
    final credit4Weeks = (widget._amount / 4).toStringAsFixed(2);
    final five = (0.05 * widget._amount).toStringAsFixed(2);
    final trustedWeeklyDebit = ((0.95 * widget._amount) / 6).toStringAsFixed(2);
    final credit10Weeks = (widget._amount / 10).toStringAsFixed(2);

    final appBar = new AppBar(
      title: Text("Confirm Payment", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    List<Widget> generatePaymentOptions() {
      List<Widget> widgets = [];

      if (widget.isCredit) {
        widgets = [
          Container(
              padding: const EdgeInsets.all(8),
              child: MaterialButton(
                child: Text('8 Week Payoff\n\nPay $credit8Weeks weekly over 8 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                onPressed: () {
                  // Perform some action
                  showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.CREDIT8WEEKS, widget._amount, double.parse(credit8Weeks), widget._currency, widget._payee, context, message: widget._message,));
                },
                color: Colors.lightBlue,
              )
          ),
          Container(
              padding: const EdgeInsets.all(8),
              child: MaterialButton(
                child: Text('6 Week Payoff\n\nPay $credit6Weeks weekly over 6 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                onPressed: () {
                  // Perform some action
                  showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.CREDIT6WEEKS, double.parse(quarter), double.parse(credit6Weeks), widget._currency, widget._payee, context, message: widget._message,));
                },
                color: Colors.green,
              )
          ),
          Container(
              padding: const EdgeInsets.all(8),
              child: MaterialButton(
                child: Text('4 Week Payoff\n\nPay $credit4Weeks weekly over 4 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                onPressed: () {
                  // Perform some action
                  showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.CREDIT4WEEKS, double.parse(tenth), double.parse(credit4Weeks), widget._currency, widget._payee, context, message: widget._message,));
                },
                color: Colors.yellow,
              )        ),
          Container(
              padding: const EdgeInsets.all(8),
              child: MaterialButton(
                child: Text('10 Week Payoff\n\nPay $trustedWeeklyDebit weekly over 10 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                onPressed: () {
                  // Perform some action
                  showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.CREDIT10WEEKS, double.parse(five), double.parse(credit10Weeks), widget._currency, widget._payee, context, message: widget._message,));
                },
                color: Colors.red,
              )        ),
        ];
      } else {
        widgets = [
          Container(
              padding: const EdgeInsets.all(8),
              child: MaterialButton(
                child: Text('Half Weekly\n\nPay $half ${widget._currency} now\n\nPay $halfWeeklyDebit weekly over 6 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                onPressed: () {
                  // Perform some action
                  showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.DEBITHALFWEEKLY, widget._amount, double.parse(halfWeeklyDebit), widget._currency, widget._payee, context, message: widget._message, upFrontPaymentAmount: double.parse(half),));
                },
                color: Colors.lightBlue,
              )
          ),
          Container(
              padding: const EdgeInsets.all(8),
              child: MaterialButton(
                child: Text('Quarter Weekly\n\nPay $quarter ${widget._currency} now\n\nPay $quarterWeeklyDebit weekly over 4 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                onPressed: () {
                  // Perform some action
                  showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.DEBITQUARTERWEEKLY, double.parse(quarter), double.parse(quarterWeeklyDebit), widget._currency, widget._payee, context, message: widget._message, upFrontPaymentAmount: double.parse(quarter)));
                },
                color: Colors.green,
              )
          ),
          Container(
              padding: const EdgeInsets.all(8),
              child: MaterialButton(
                child: Text('Tenth Weekly\n\nPay $tenth ${widget._currency} now\n\nPay $tenthWeeklyDebit weekly over 2 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                onPressed: () {
                  // Perform some action
                  showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.DEBITTENTHWEEKLY, widget._amount, double.parse(tenthWeeklyDebit), widget._currency, widget._payee, context, message: widget._message, upFrontPaymentAmount: double.parse(tenth)));
                },
                color: Colors.yellow,
              )        ),
          Container(
              padding: const EdgeInsets.all(8),
              child: MaterialButton(
                child: Text('Trusted Weekly\n\nPay $five ${widget._currency} now\n\n Pay $trustedWeeklyDebit weekly over six weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                onPressed: () {
                  // Perform some action
                  showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.DEBITTRUSTEDWEEKLY, widget._amount, double.parse(trustedWeeklyDebit), widget._currency, widget._payee, context, message: widget._message, upFrontPaymentAmount: double.parse(five)));
                },
                color: Colors.red,
              )
          ),
        ];
      }

      return widgets;
    }

    final optionsGrid = GridView.count(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: generatePaymentOptions(),
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
  ConfirmationDialog(this.selectedPlan, this.amount, this.planPaymentAmount, this.currency, this.payee, this.contextOfPage, {this.message = '', this.upFrontPaymentAmount = 0.0});

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

  bool _isLoading = false;
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
        case PaymentPlan.CREDIT8WEEKS:
          return Text("Plan: Credit Purchase with 8 Week Payoff\n", textAlign: TextAlign.center);
          break;
        case PaymentPlan.CREDIT6WEEKS:
          return Text("Plan: Credit Purchase with 6 Week Payoff\n", textAlign: TextAlign.center);
          break;
        case PaymentPlan.CREDIT4WEEKS:
          return Text("Plan: Credit Purchase with 4 Week Payoff\n", textAlign: TextAlign.center);
          break;
        case PaymentPlan.CREDIT10WEEKS:
          return Text("Plan: Credit Purchase with 10 Week Payoff\n", textAlign: TextAlign.center);
          break;
        case PaymentPlan.DEBITHALFWEEKLY:
          return Text("Plan: Half Weekly on Debit\n");
          break;
        case PaymentPlan.DEBITQUARTERWEEKLY:
          return Text("Plan: Quarter Weekly on Debit\n");
          break;
        case PaymentPlan.DEBITTENTHWEEKLY:
          return Text("Plan: Tenth Weekly on Debit\n");
          break;
        case PaymentPlan.DEBITTRUSTEDWEEKLY:
          return Text("Plan: Trusted Weekly on Debit\n");
          break;

      }
    }
    
    List<Widget> getWidget() {
      if (_isLoading) {
        return [ColorLoader(), Text("\nInitiating payment...")];
      } else {
        return [
          getPlan(),
          Text("Paid to: ${widget.payee}"),
          widget.upFrontPaymentAmount != 0.0 ? Text("Upfront Payment: ${widget.upFrontPaymentAmount} ${widget.currency}\n"
              "Recurring charge: ${widget.planPaymentAmount} ${widget.currency}"): Text("Recurring charge: ${widget.planPaymentAmount} ${widget.currency}"),
        ];
      }
    }

    return new AlertDialog(
      content: new Column(
        children: getWidget(),
        mainAxisSize: MainAxisSize.min,
      ),
      actions: _isLoading ? null: <Widget>[
        FlatButton(
          child: Text('Cancel', style: TextStyle(color: _isClickedColor)),
          onPressed: () {
            if (!_isLoading) {
              Navigator.pop(context);
            }
          },
        ),
        FlatButton(
          child: Text('Pay', style: TextStyle(color: _isClickedColor)),
          onPressed: () async {
            if (!_isLoading) {
              setState(() {
                _isLoading = true;
                _isClickedColor = Colors.grey;
              });
              MTNMobileMoney.createAPIUser().then((response) {
                MTNMobileMoney.getAPIKey().then((response) {
                  MTNMobileMoney.getDisbursementToken().then((response) {
                    MTNMobileMoney.initiateAfterPayTransaction(
                        widget.upFrontPaymentAmount != 0.0 ? widget.upFrontPaymentAmount: widget.amount, widget.currency,
                        widget.payee, widget.message).then((response) {
                      Navigator.pop(context, 'cancel');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return ColorLoaderPage(widget.payee, widget.amount, widget.selectedPlan, widget.currency, widget.message, false);
                      }));
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



