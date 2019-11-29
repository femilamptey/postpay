import 'package:postpay/confirmpaymentpage.dart';
import 'package:postpay/database.dart';
import 'package:postpay/navDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePage extends StatefulWidget {
  static final String tag = 'home-page';

  LocalStorage storage = new LocalStorage("credentials");
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static final List<String> _currencies = ['EUR', 'GHS'];
  double creditBalance;
  double availableBalance;
  double accountBalance;
  String _currency;

  HomePage() {
    creditBalance =  storage.getItem("creditBalance");
    availableBalance =  storage.getItem("availableBalance");
    accountBalance = storage.getItem("accountBalance");
    _currency = storage.getItem("currency");
  }

  @override
  _HomePageState createState() => new _HomePageState();

}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

    bool _isCredit = true;

  @override
  Widget build(BuildContext context) {

    widget.creditBalance = widget.storage.getItem("creditBalance");
    widget.availableBalance = widget.storage.getItem("availableBalance");
    widget.accountBalance = widget.storage.getItem("accountBalance");

    final RefreshController _refreshController = RefreshController();

    final appBar = new AppBar(
      title: Text("Home", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final navDrawer = NavDrawer(HomePage.tag);

    switchText() {
      if (_isCredit) {
        return Text("Credit", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500));
      } else {
        return Text("Debit", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500));
      }
    }

    percent() {
      if (_isCredit) {
        return (widget.availableBalance)/widget.creditBalance;
      } else {
        return 1.0;
      }
    }
    
    accountText() {
      if (_isCredit) {
        return new Text(
          "Credit Balance: ${widget.creditBalance.toStringAsFixed(2)} ${widget._currency} \nAvailable Balance: ${widget.availableBalance.toStringAsFixed(2)} ${widget._currency}",
          style:
          new TextStyle(fontWeight: FontWeight.bold, fontSize: 21.0),
        );
      } else {
        return new Text(
          "Account Balance: ${widget.accountBalance.toStringAsFixed(2)} ${widget._currency}",
          style:
          new TextStyle(fontWeight: FontWeight.bold, fontSize: 21.0),
        );
      }
    }

    final modeSwitch = Container(
      child: SwitchListTile(
        value: _isCredit,
        title: switchText(),
        onChanged: (bool value) {
          setState(() {
            _isCredit = value;
          });
        },
        activeColor: Colors.red,
        activeTrackColor: Colors.redAccent,
        inactiveThumbColor: Colors.green,
        inactiveTrackColor: Colors.lightGreen,
      ),
      width: 5.0,
    );

    final logo = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(30.0),
          child: Image.asset('assets/heading.png')
      ),
    );

    final initiateTransferDialog = new InitiateTransferDialog(_isCredit);

    final makePaymentButton = Padding(
      padding: EdgeInsets.all(8.0),
      child: RaisedButton(
        color: Colors.black,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
        child: const Text('Make Payment', semanticsLabel: 'Make Payment'),
        onPressed: () {
          // Perform some action
          showDialog(context: context, builder: (context) => initiateTransferDialog, barrierDismissible: false);
        },
      ),
    );

    final circle = new CircularPercentIndicator(
      radius: 300.0,
      lineWidth: 27.0,
      animation: true,
      percent: percent(),
      center: makePaymentButton,
      footer: accountText(),
      circularStrokeCap: CircularStrokeCap.square,
      progressColor: Colors.green,
      backgroundColor: Colors.red,
    );

    final body = SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: () async {
        //TODO
        await Future.delayed(Duration(seconds: 2), () async{
          //await widget.storage.setItem("accountBalance", widget.accountBalance).then((onValue) async {
            //await widget.storage.setItem("availableBalance", widget.availableBalance);
         // });
          setState(() {
            //TODO: Refresh
            widget.creditBalance = widget.storage.getItem("creditBalance");
            widget.availableBalance = widget.storage.getItem("availableBalance");
            widget.accountBalance = widget.storage.getItem("accountBalance");
          });
        });
        _refreshController.refreshCompleted();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[logo, circle, modeSwitch],
        ),
      )
    );

    return Scaffold(
      appBar: appBar,
      drawer: navDrawer,
      body: body,
    );
  }

  void showMaterialDialog<T>({ BuildContext context, Widget child }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    )
        .then<void>((T value) { // The value passed to Navigator.pop() or null.
      if (value != null) {
        widget._scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
  }
}

class InitiateTransferDialog extends StatefulWidget {
  InitiateTransferDialog(this.isCredit, {this.onValueChange, this.initialValue});
  LocalStorage storage = new LocalStorage("credentials");
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isCredit;
  final String initialValue;
  final void Function(String) onValueChange;

  @override
  State createState() => new InitiateTransferDialogState();
}

class InitiateTransferDialogState extends State<InitiateTransferDialog> {
  String _currency = 'EUR';
  static final List<String> _currencies = ['EUR', 'GHS'];

  @override
  void initState() {
    widget.storage.ready.then((isReady) {
      print(isReady);
    });
    super.initState();
  }

  void _onDropDownChanged(String val) {
    setState(() {
      this._currency = val;
    });
  }

  Widget build(BuildContext context) {

    String payee;
    double amount;
    String message = '';
    String MOMOPin;

    switchText() {
      if (widget.isCredit) {
        return Text("Credit", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500));
      } else {
        return Text("Debit", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500));
      }
    }

    final payeeFieldController = TextEditingController();
    final amountFieldController = TextEditingController();
    final messageFieldController = TextEditingController();
    final MOMOPinFieldController = TextEditingController();

    return new AlertDialog(
      content: Container(
        height: 360.00,
        width:  200.00,
        child: ListView(
          children: <Widget>[
            new Container(child: SwitchListTile(
                value: widget.isCredit,
                title: switchText(),
                onChanged: (bool value) {
                  setState(() {
                    widget.isCredit = value;
                  });
                },
                activeColor: Colors.red,
                activeTrackColor: Colors.redAccent,
                inactiveThumbColor: Colors.green,
                inactiveTrackColor: Colors.lightGreen,
              ),
              width: 5.0,
            ),
            new Container(child: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                  labelText: "Recipient's number"
              ),
              onChanged: (text) {
                payee = text;
              },
              controller: payeeFieldController,
              ),
            ),
            new Container(child: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                  labelText: "Transfer amount"
              ),
              onChanged: (text) {
                amount = double.parse(text);
              },
              controller: amountFieldController,
            )),
            new Container(child:
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Currency',
                contentPadding: EdgeInsets.zero,
              ),
              isEmpty: _currency == null,
              child: DropdownButton<String>(
                value: _currency,
                onChanged: (String newValue) {
                  _onDropDownChanged(newValue);
                },
                items: _currencies.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            )
            ),
            new Container(child: new TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: new InputDecoration(
                  labelText: "MOMO PIN"
              ),
              onChanged: (text) {
                MOMOPin = text;
              },
              controller: MOMOPinFieldController,
            )),
            new Container(child: new TextField(
              decoration: new InputDecoration(
                labelText: "Reason/Message (Optional)",
              ),
              onChanged: (text) {
                message = text;
              },
              controller: messageFieldController,
            ))
          ],
          //mainAxisSize: MainAxisSize.min,
          padding: EdgeInsets.all(0.0),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel', style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.pop(context, 'cancel');
          },
        ),
        FlatButton(
          child: Text('Next', style: TextStyle(color: Colors.black)),
          onPressed: () {
            if (amount != null || payee != null || MOMOPin != null) {
              if (widget.storage.getItem("pin") == MOMOPin) {
                Navigator.pop(context, 'cancel');
                Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ConfirmPaymentPage(
                              payee, amount, _currency, message, MOMOPin, widget.isCredit),
                    ));
              } else {
                print(MOMOPin);
                showMaterialDialog<String>(
                  context: context,
                  child: AlertDialog(
                    title: const Text('Incorrect PIN'),
                    content: Text(
                      'Enter the MOMO PIN for this account',
                      style: Theme
                          .of(context)
                          .textTheme
                          .subhead
                          .copyWith(color: Theme
                          .of(context)
                          .textTheme
                          .caption
                          .color),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('OK', style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          Navigator.pop(context, 'discard');
                        },
                      ),
                    ],
                  ),
                );
              }
            } else {
              showMaterialDialog<String>(
                context: context,
                child: AlertDialog(
                  title: const Text('Empty fields'),
                  content: Text(
                    'Fill in all non-optional fields',
                    style: Theme
                        .of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Theme
                        .of(context)
                        .textTheme
                        .caption
                        .color),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: const Text('OK', style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.pop(context, 'discard');
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void showMaterialDialog<T>({ BuildContext context, Widget child }) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    )
        .then<void>((T value) { // The value passed to Navigator.pop() or null.
      if (value != null) {
        widget._scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
  }
}