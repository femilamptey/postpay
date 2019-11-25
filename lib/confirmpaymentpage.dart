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
    final tenth = (0.10 * widget._amount).toStringAsFixed(2);
    final tenthWeekly = ((0.90 * widget._amount) / 2).toStringAsFixed(2);
    final five = (0.05 * widget._amount).toStringAsFixed(2);
    final trustedWeekly = ((0.95 * widget._amount) / 6).toStringAsFixed(2);

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
            child: Text('Half Weekly\n\nPay $half ${widget._currency} now\n\nPay $halfWeekly weekly over 6 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            onPressed: () {
              // Perform some action
              showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.HALFWEEKLY, widget._amount, double.parse(half), double.parse(halfWeekly), widget._currency, widget._payee, context, message: widget._message,));
            },
            color: Colors.lightBlue,
          )
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: MaterialButton(
            child: Text('Quarter Weekly\n\nPay $quarter ${widget._currency} now\n\nPay $quarterWeekly weekly over 4 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            onPressed: () {
              // Perform some action
              showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.QUARTERWEEKLY, widget._amount, double.parse(quarter), double.parse(quarterWeekly), widget._currency, widget._payee, context, message: widget._message,));
            },
            color: Colors.green,
          )
        ),
        Container(
          padding: const EdgeInsets.all(8),
            child: MaterialButton(
              child: Text('Tenth Weekly\n\nPay $tenth ${widget._currency} now\n\nPay $tenthWeekly weekly over 2 weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              onPressed: () {
                // Perform some action
                showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.TENTHWEEKLY, widget._amount, double.parse(tenth), double.parse(tenthWeekly), widget._currency, widget._payee, context, message: widget._message,));
              },
              color: Colors.yellow,
            )        ),
        Container(
          padding: const EdgeInsets.all(8),
            child: MaterialButton(
              child: Text('Trusted Weekly\n\nPay $five ${widget._currency} now\n\n Pay $trustedWeekly weekly over six weeks', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
              onPressed: () {
                // Perform some action
                showDialog(context: context, barrierDismissible: false, builder: (context) => new ConfirmationDialog(PaymentPlan.TRUSTEDWEEKLY, widget._amount, double.parse(five), double.parse(trustedWeekly), widget._currency, widget._payee, context, message: widget._message,));
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
        case PaymentPlan.HALFWEEKLY:
          return Text("Plan: Half Weekly");
          break;
        case PaymentPlan.QUARTERWEEKLY:
          return Text("Plan: Quarter Weekly");
          break;
        case PaymentPlan.TENTHWEEKLY:
          return Text("Plan: Tenth Weekly");
          break;
        case PaymentPlan.TRUSTEDWEEKLY:
          return Text("Plan: Trusted Weekly");
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
          Text("Upfront Payment: ${widget.upFrontPaymentAmount} ${widget.currency}"),
          Text("Recurring charge: ${widget.planPaymentAmount} ${widget.currency}")
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
                        widget.upFrontPaymentAmount, widget.currency,
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



