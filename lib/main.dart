import 'package:afterpay/confirmpaymentpage.dart';
import 'package:afterpay/loader.dart';
import 'package:afterpay/loaderpage.dart';
import 'package:afterpay/pendingpayments.dart';
import 'package:flutter/material.dart';
import 'package:afterpay/loginpage.dart';
import 'package:afterpay/homepage.dart';
import 'package:localstorage/localstorage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  LocalStorage storage = new LocalStorage("credentials");

  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    PendingPaymentsPage.tag: (context) => PendingPaymentsPage(),
    ColorLoaderPage.tag: (context) => ColorLoaderPage(),
  };

  @override
  Widget build(BuildContext context) {

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          fontFamily: 'Nunito',
        ),
        home: isLoggedIn() ? HomePage(): LoginPage(),
        routes: routes,
      );

  }

  bool isLoggedIn() {
    if (storage.getItem("account") != null) {
      return true;
    }
      else { return false; }
  }
}