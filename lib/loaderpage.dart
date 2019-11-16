import 'dart:io';

import 'package:afterpay/mtnmobilemoney.dart';
import 'package:flutter/material.dart';
import 'loader.dart';

class ColorLoaderPage extends StatefulWidget {
  static final String tag = 'loader-page';

  @override
  State<StatefulWidget> createState() => _ColorLoaderPageState();

}

class _ColorLoaderPageState extends State<ColorLoaderPage> {

  @override
  Widget build(BuildContext context) {

    var body = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: FutureBuilder(
          future: MTNMobileMoney.checkTransactionStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data as HttpClientResponse;
              var status = data.statusCode;
              //TODO: Read response from transaction status and determine if transaction failed or succeeded, and present appropriate message
              print(MTNMobileMoney.getTransactionStatus());
              return TransactionStatusDialog(status);
            } else {
              return Stack(
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
              );
            }
          },
        )
    );

    return Scaffold(
      body: body,
    );
  }

}

class TransactionStatusDialog extends StatefulWidget {
  TransactionStatusDialog(this.status);

  final int status;

  @override
  State createState() => new TransactionStatusDialogState();
}

class TransactionStatusDialogState extends State<TransactionStatusDialog> {

  TransactionStatusDialogState();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {

    var titleText;
    var contentText;

    if (widget.status != 200) {
      titleText = "Error";
      contentText = "There was an error with the server. Kindly try again later.";
    } else {
      titleText = "Success";
      contentText = "Afterpay payment successful.";
    }

    return new AlertDialog(
      title: Text(titleText),
      content: Text(contentText),
      actions: <Widget>[
        FlatButton(
          child: Text("Done", style: TextStyle(color: Colors.black)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

}