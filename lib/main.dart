import 'package:afterpay/confirmpaymentpage.dart';
import 'package:afterpay/loader.dart';
import 'package:afterpay/loaderpage.dart';
import 'package:afterpay/pendingpayments.dart';
import 'package:flutter/material.dart';
import 'package:afterpay/loginpage.dart';
import 'package:afterpay/homepage.dart';
import 'package:localstorage/localstorage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  LocalStorage storage = new LocalStorage("credentials");

  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    PendingPaymentsPage.tag: (context) => PendingPaymentsPage(),
  };

  @override
  _MyAppState createState() => new _MyAppState();

}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {

    var home = FutureBuilder(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: Stack(
            children: [
              new Opacity(
                opacity: 1.0,
                child: const ModalBarrier(
                    dismissible: false, color: Colors.white),
              ),
              new Center(
                child: ColorLoader(),
              ),
            ],
          ));
        } else {
          print(snapshot.data);
          return snapshot.data ? HomePage(): LoginPage();
        }
      }
    );

    //isLoggedIn() ? HomePage(): LoginPage();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: home,
      routes: widget.routes,
    );

  }

  Future<bool> isLoggedIn() async {
    await Future.delayed(Duration(seconds: 3));
    if (widget.storage.getItem("account") != null) {
        return true;
    } else { return false; }
  }

}