import 'package:afterpay/homepage.dart';
import 'package:afterpay/pendingpayments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'loginpage.dart';

class NavDrawer extends StatelessWidget {

  NavDrawer(this.currentPage);
  LocalStorage storage = new LocalStorage("credentials");

  String currentPage;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
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
              if (currentPage == HomePage.tag) {
                //DO NOTHING
              } else {
                Navigator.of(context).pushReplacementNamed(HomePage.tag);
              }
            },
          ),
          new ListTile(
            title: Text("Pending Payments", style: TextStyle(fontSize: 20.0)),
            onTap: () {
              if (currentPage == PendingPaymentsPage.tag) {
                //DO NOTHING
              } else {
                Navigator.of(context).pushReplacementNamed(
                    PendingPaymentsPage.tag);
              }
            },
          ),
          new ListTile(
            title: Text("Sign Out", style: TextStyle(fontSize: 20.0)),
            onTap: () {
              if (currentPage == LoginPage.tag) {
                //DO NOTHING
              } else {
                storage.clear().then((onValue) {
                  Navigator.of(context).pushReplacementNamed(LoginPage.tag);
                });
              }
            },
          )
        ],
      ),
    );
  }

}