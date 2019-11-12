import 'package:afterpay/confirmpaymentpage.dart';
import 'package:afterpay/loginpage.dart';
import 'package:afterpay/mtnmobilemoney.dart';
import 'package:afterpay/pendingpayments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePage extends StatefulWidget {
  static final String tag = 'home-page';

  @override
  _HomePageState createState() => new _HomePageState();

}

class _HomePageState extends State<HomePage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static final List<String> _currencies = ['EUR', 'GHS'];
  double accountBalance = 5000.00;
  double availableBalance = 4400.00;
  String _currency = 'EUR';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //MTNMobileMoney.createAPIUser();
    MTNMobileMoney.getAPIKey();
    MTNMobileMoney.getDisbursementToken();

    //TODO: Handle Negative and 0 values
    var results = MTNMobileMoney.getAccountBalance().then((array) {
      accountBalance = array[0];
      accountBalance +=  200.0;
      availableBalance = accountBalance - 25;
      print(availableBalance/accountBalance);
      _currency = array[1];
    });

    //MTNMobileMoney.transferMoney();

    final RefreshController _refreshController = RefreshController();

    final appBar = new AppBar(
      title: Text("Home", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final navDrawer = new Drawer(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
              accountName: Text("Options", style: TextStyle(color: Colors.white, fontSize: 38.0)),
              accountEmail: null,
              decoration: BoxDecoration(color: Colors.black)),
          new ListTile(
            title: Text("Home", style: TextStyle(fontSize: 20.0)),
            onTap: () {
              //DO NOTHING
            },
          ),
          new ListTile(
            title: Text("Pending Payments", style: TextStyle(fontSize: 20.0)),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(PendingPaymentsPage.tag);
            },
          ),
          new ListTile(
            title: Text("Sign Out", style: TextStyle(fontSize: 20.0)),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(LoginPage.tag);
            },
          )
        ],
      ),
    );

    final logo = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(30.0),
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

    final initiateTransferDialog = new InitiateTransferDialog();

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
      percent: availableBalance/accountBalance,
      center: makePaymentButton,
      footer: new Text(
        "Account Balance: $accountBalance  " + _currency + "\nAvailable Balance: $availableBalance " + _currency,
        style:
        new TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
      ),
      circularStrokeCap: CircularStrokeCap.square,
      progressColor: Colors.green,
      backgroundColor: Colors.red,
    );

    final body = SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: () async {
        //TODO
        await Future.delayed(Duration(seconds: 3));
        setState(() {
          //TODO: DELETE LATER, THIS IS JUST A TEST
          availableBalance -= 200;
          accountBalance -= 100;
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
          children: <Widget>[logo, circle],
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
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
  }
}

class InitiateTransferDialog extends StatefulWidget {
  const InitiateTransferDialog({this.onValueChange, this.initialValue});

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
    int MOMOPin;

    final payeeFieldController = TextEditingController();
    final amountFieldController = TextEditingController();
    final messageFieldController = TextEditingController();
    final MOMOPinFieldController = TextEditingController();

    return new AlertDialog(
      content: new Column(
        children: <Widget>[
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
              MOMOPin = int.parse(text);
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
          child: const Text('Next'),
          onPressed: () {
            if (amount != null || payee != null || MOMOPin != null) {
              Navigator.pop(context, 'cancel');
              Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ConfirmPaymentPage(
                            payee, amount, _currency, message, MOMOPin),
                  ));
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Please fill required fields."),
              ));
            }
          },
        ),
      ],
    );
  }
}