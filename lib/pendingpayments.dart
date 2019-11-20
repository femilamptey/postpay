import 'package:afterpay/database.dart';
import 'package:afterpay/mtnmobilemoney.dart';
import 'package:afterpay/navDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'homepage.dart';
import 'loginpage.dart';

class PendingPaymentsPage extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static String tag = 'pending-payments-page';

  @override
  _PendingPaymentsPageState createState() => new _PendingPaymentsPageState();

}

class _PendingPaymentsPageState extends State<PendingPaymentsPage> {

  Future<List<AfterPayTransaction>> _getTransactions() async {
    var transactions = [];
    await DBProvider.getAllTransactions().then((transactionsList) {
      for (var transaction in transactionsList) {
        print(transaction.toString());
        var json = AfterPayTransaction.fromMap(transaction);
        transactions.add(AfterPayTransaction.fromJSON(json));
      }
    });
    print(transactions);
    return transactions;
  }

  List<Widget> _generateTransactionTiles() {
    //TODO: ADD CODE TO GENERATE LIST TILES FOR EACH TRANSACTION
    return [];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _getTransactions();

    final RefreshController _refreshController = RefreshController();

    final appBar = new AppBar(
      title: Text("Pending Payments", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final navDrawer = NavDrawer(PendingPaymentsPage.tag);

    final list = new ListView(
      physics: ScrollPhysics(),
      padding: EdgeInsets.zero,
      children: _generateTransactionTiles(),
    );

    final body = SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: () async {
          //TODO
          await Future.delayed(Duration(seconds: 3));
          _refreshController.refreshCompleted();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(14.0),
          decoration: BoxDecoration(
              color: Colors.white
          ),
          child: list,
        )
    );

    return Scaffold(
      appBar: appBar,
      drawer: navDrawer,
      body: body,
    );

  }

}