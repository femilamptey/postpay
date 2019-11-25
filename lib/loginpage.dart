import 'package:flutter/material.dart';
import 'package:afterpay/homepage.dart';
import 'package:afterpay/database.dart';
import 'package:localstorage/localstorage.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  LocalStorage storage = new LocalStorage("credentials");
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool bothFieldsFilled = false;

  TextEditingController accountFieldController = new TextEditingController();
  TextEditingController pinFieldController = new TextEditingController();

  login() async {
    await widget.storage.ready.then((isReady) async {
      await widget.storage.setItem("account", accountFieldController.text).then((onValue) async {
        await widget.storage.setItem("pin", pinFieldController.text).then((onValue) async {
          await widget.storage.setItem("accountBalance", 5000.00).then((onValue) async {
            await widget.storage.setItem("availableBalance", 4400.00).then((onValue) async {
              await widget.storage.setItem("currency", "EUR").then((onValue) async {
              });
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final logo = SizedBox(
      child: Hero(
        tag: 'hero',
        child: Image.asset('assets/heading.jpeg'),
        ),
    );

    final account = TextFormField(
      keyboardType: TextInputType.number,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Account number',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text) {
        if (accountFieldController.text == '') {
          setState(() {
            bothFieldsFilled = false;
          });
        } else if (pinFieldController.text != '' && accountFieldController.text != '') {
          setState(() {
            bothFieldsFilled = true;
          });
        }
      },
      controller: accountFieldController,
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'PIN',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onChanged: (text) {
        if (pinFieldController.text == '') {
          setState(() {
            bothFieldsFilled = false;
          });
        } else if (pinFieldController.text != '' && accountFieldController.text != '') {
          setState(() {
            bothFieldsFilled = true;
          });
        }
      },
      controller: pinFieldController,
    );

    //final errorMessageSnackbar = SnackBar(content: Text("Fill in both fields"));

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async {
          if (bothFieldsFilled) {
            if (accountFieldController.text == '' || pinFieldController.text == '') {
              //Scaffold.of(context).showSnackBar(errorMessageSnackbar);
            } else {
              await login();
              Navigator.of(context).pushReplacementNamed(HomePage.tag);
            }
          } else {
            //DO NOTHING
          }
        },
        padding: EdgeInsets.all(12),
        color: bothFieldsFilled ? Colors.black: Colors.grey,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 85.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            account,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton
          ],
        ),
      ),
    );
  }
}