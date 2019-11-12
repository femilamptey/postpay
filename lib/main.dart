import 'package:afterpay/confirmpaymentpage.dart';
import 'package:afterpay/loader.dart';
import 'package:afterpay/pendingpayments.dart';
import 'package:flutter/material.dart';
import 'package:afterpay/loginpage.dart';
import 'package:afterpay/homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    PendingPaymentsPage.tag: (context) => PendingPaymentsPage(),
    ColorLoader.tag: (context) => ColorLoader(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}