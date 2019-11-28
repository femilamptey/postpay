import 'package:postpay/database.dart';
import 'package:postpay/loader.dart';
import 'package:postpay/mtnmobilemoney.dart';
import 'package:postpay/navDrawer.dart';
import 'package:postpay/pendingpayments.dart';
import 'package:postpay/transactiondetailspage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CompletedPaymentsPage extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static String tag = 'completed-payments-page';

  @override
  _CompletedPaymentsPageState createState() => new _CompletedPaymentsPageState();

}

class _CompletedPaymentsPageState extends State<CompletedPaymentsPage> {

  CircularPercentIndicator _createIndicator(PostPayTransaction transaction) {

    return CircularPercentIndicator(
      radius: 35.0,
      lineWidth: 6.0,
      animation: true,
      percent: 1.0,
      circularStrokeCap: CircularStrokeCap.butt,
      progressColor: Colors.green,
      backgroundColor: Colors.red,
    );

  }

  Future<List<PostPayTransaction>> _getTransactions() async {
    List<PostPayTransaction> transactions = [];
    var dbTransactions = List<Map<String, dynamic>>();

    dbTransactions = await DBProvider.getCompletedTransactions().then((transactionsList) {
      print(transactionsList[0]);
      return transactionsList;
    });

    for (var transaction in dbTransactions) {
      print(transaction.toString());
      var json = PostPayTransaction.fromMap(transaction);
      transactions.add(PostPayTransaction.fromJSON(json));
    }

    print(transactions);
    return transactions;
  }

  List<Card> _generateTransactionTiles(List<PostPayTransaction> transactions) {
    //TODO: ADD CODE TO GENERATE LIST TILES FOR EACH TRANSACTION
    var transactionTiles = List<Card>();

    for (var transaction in transactions) {
      transactionTiles.add(Card(
        child: ListTile(
          leading: _createIndicator(transaction),
          title: Text("Transaction ${transaction.financialTransactionID}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          subtitle: Text("Plan: ${transaction.planAsString()}\nPaid to: ${transaction.payee}\nTotal amount: ${transaction.totalAmount.toStringAsFixed(2)} ${transaction.allTransactions.first.getCurrency}\nRemaining amount: ${transaction.remainingAmount.toStringAsFixed(2)} ${transaction.allTransactions.first.getCurrency}"),
          contentPadding: EdgeInsets.all(10.0),
          onTap: () {
            /*Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TransactionDetailsPage(transaction);
            }));*/
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
      title: Text("Completed Payments", style: TextStyle(color: Colors.white, fontSize: 26.0)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white, size: 26.0),
    );

    final navDrawer = NavDrawer(CompletedPaymentsPage.tag);

    final list = FutureBuilder<List<PostPayTransaction>>(
      future: _getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ListView(
              physics: ScrollPhysics(),
              padding: EdgeInsets.zero,
              children: _generateTransactionTiles(snapshot.data),
            );
          } else {
            return Center(child: Text("No completed payments", style: TextStyle(fontSize: 22.0)));
          }
        } else {
          return Center(child: ColorLoader());
        }
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