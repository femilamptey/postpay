import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static String tag = 'home-page';
  String accountBalance = '5000';
  String availableBalance = '4400';
  String currency = 'EUR';

  @override
  Widget build(BuildContext context) {

    final appBar = new AppBar(
      title: Text("Home", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final navDrawer = new Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
              accountName: Text("Options", style: TextStyle(color: Colors.white, fontSize: 38.0)),
              decoration: BoxDecoration(color: Colors.black)),
          new ListTile(
            title: Text("Pending Payments", style: TextStyle(fontSize: 20.0)),
            onTap: () {
              //TODO
            },
          ),
          new ListTile(
            title: Text("Sign Out", style: TextStyle(fontSize: 20.0)),
            onTap: () {
              //TODO
            },
          )
        ],
      ),
    );

    final logo = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(0.0),
          child: Image.asset('assets/heading.jpeg')
      ),
    );

    final welcome = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Welcome Alucard',
        style: TextStyle(fontSize: 28.0, color: Colors.black),
      ),
    );

    final initiateTransferDialog =
      AlertDialog(
        content: new Column(
          children: <Widget>[
            new Container(child: new TextField(
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                  labelText: "Recipient's number"
                ),
              ),
            ),
            new Container(child: new TextField(
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                labelText: "Transfer amount"
              ),
            )),
            new Container(child: new TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: new InputDecoration(
                labelText: "MOMO PIN"
              ),
            )),
            new Container(child: new TextField(
              decoration: new InputDecoration(
                labelText: "Optional: Reason",
              ),
            ),)
          ],
        mainAxisSize: MainAxisSize.min,
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, 'cancel');
            },
          ),
          FlatButton(
            child: const Text('Pay'),
            onPressed: () {
              Navigator.pop(context, 'discard');
            },
          ),
        ],
      );

    final makePaymentButton = Padding(
      padding: EdgeInsets.all(8.0),
      child: RaisedButton(
        color: Colors.black,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
        child: const Text('Make Payment', semanticsLabel: 'Make Payment'),
        onPressed: () {
          // Perform some action
          showDialog(context: context, builder: (context) => initiateTransferDialog);
        },
      ),
    );

    final circle = new CircularPercentIndicator(
      radius: 300.0,
      lineWidth: 27.0,
      animation: true,
      percent: double.parse(availableBalance)/double.parse(accountBalance),
      center: makePaymentButton,
      footer: new Text(
        "Account Balance: " + accountBalance + " " + currency + "\nAvailable Balance: " + availableBalance + " " + currency,
        style:
        new TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
      ),
      circularStrokeCap: CircularStrokeCap.square,
      progressColor: Colors.green,
      backgroundColor: Colors.red,
    );

    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: ListView(
        children: <Widget>[logo, circle],
      ),
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
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
  }
}