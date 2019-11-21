import 'package:afterpay/database.dart';
import 'package:afterpay/loader.dart';
import 'package:afterpay/mtnmobilemoney.dart';
import 'package:afterpay/navDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PendingPaymentsPage extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static String tag = 'pending-payments-page';

  @override
  _PendingPaymentsPageState createState() => new _PendingPaymentsPageState();

}

class _PendingPaymentsPageState extends State<PendingPaymentsPage> {

  CircularPercentIndicator _createIndicator(AfterPayTransaction transaction) {

    return CircularPercentIndicator(
      radius: 35.0,
      lineWidth: 6.0,
      animation: true,
      percent: (transaction.totalAmount - transaction.remainingAmount)/transaction.totalAmount,
      circularStrokeCap: CircularStrokeCap.butt,
      progressColor: Colors.green,
      backgroundColor: Colors.red,
    );
  }

  Future<List<AfterPayTransaction>> _getTransactions() async {
    List<AfterPayTransaction> transactions = [];
    var dbTransactions = List<Map<String, dynamic>>();

    dbTransactions = await DBProvider.getPendingTransactions().then((transactionsList) {
      print(transactionsList[0]);
      return transactionsList;
    });

    for (var transaction in dbTransactions) {
      print(transaction.toString());
      var json = AfterPayTransaction.fromMap(transaction);
      transactions.add(AfterPayTransaction.fromJSON(json));
    }

    print(transactions);
    return transactions;
  }

  List<Card> _generateTransactionTiles(List<AfterPayTransaction> transactions) {
    //TODO: ADD CODE TO GENERATE LIST TILES FOR EACH TRANSACTION
    var transactionTiles = List<Card>();

    for (var transaction in transactions) {
      transactionTiles.add(Card(
        child: ListTile(
          leading: _createIndicator(transaction),
          title: Text("Transaction ${transaction.financialTransactionID}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          subtitle: Text("Plan: ${transaction.planAsString()}\nPaid to: ${transaction.payee}\nTotal amount: ${transaction.totalAmount}\nRemaining amount: ${transaction.remainingAmount}"),
          contentPadding: EdgeInsets.all(10.0),
          onTap: () {

          },
        ),
      ));
    }

    return transactionTiles;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    //DBProvider.deleteTransactionTable();

    final RefreshController _refreshController = RefreshController();

    final appBar = new AppBar(
      title: Text("Pending Payments", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final navDrawer = NavDrawer(PendingPaymentsPage.tag);

    final list = FutureBuilder<List<AfterPayTransaction>>(
      future: _getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            physics: ScrollPhysics(),
            padding: EdgeInsets.zero,
            children: _generateTransactionTiles(snapshot.data),
          );
        } else {
          return Center(child: Text("No pending payments", style: TextStyle(fontSize: 22.0)));
        }
        return Center(child: ColorLoader());
      },
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