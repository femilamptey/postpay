import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:ffi';
import 'dart:io';

import 'package:afterpay/account.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:alt_http/alt_http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

class MTNMobileMoney {

  MTNMobileMoney._();
  static final MTNMobileMoney _mtnMOMO = MTNMobileMoney._();
  static String _apiKey = '';
  static String _accessToken = '';
  static String _referenceID = '';
  static String _transactionStatus = '';
  //static final _referenceID = 'cd0f4b28-3de1-4148-bf2e-aa3543dc5be2';
  static final _hostURL = 'sandbox.momodeveloper.mtn.com';
  static final _createAPIUserURL = '/v1_0/apiuser';
  static var _getAPIKeyURL = '/v1_0/apiuser/' + _referenceID + '/apikey';
  static final _getDisbursementTokenURL = '/disbursement/token/';
  static final _getAccountBalanceURL = '/disbursement/v1_0/account/balance';
  static final _transferMoneyURL = '/disbursement/v1_0/transfer';
  static var _checkTransferStatusURL = '/disbursement/v1_0/transfer/' + _referenceID;

  static final String _collectionsKey = 'df26565ecc4c4abe94ca3f0dae9bd5c9';
  static final String _disbursementKey = 'd89864081c2749c183c7457204ffb74a';

  static _setReferenceID(String value) {
    _referenceID = value;
  }

  static _setAPIKeyURL(String value) {
    _getAPIKeyURL = '/v1_0/apiuser/' + value + '/apikey';
  }

  static _setCheckTransferStatusURL(String value) {
    _checkTransferStatusURL = '/disbursement/v1_0/transfer/' + value;
  }

  static _setAPIKey(String value) {
    _apiKey = value;
  }

  static _setAccessToken(String value) {
    _accessToken = value;
  }

  static Future<HttpClientResponse> createAPIUser() async {

    _setReferenceID(Uuid().v4());
    _setAPIKeyURL(_referenceID);
    _setCheckTransferStatusURL(_referenceID);

    var client = AltHttpClient();

    var data = {
      'providerCallbackHost' : 'string'
    };

    HttpClientResponse response = await client.postUrl(Uri.https(_hostURL, _createAPIUserURL)).then((HttpClientRequest request) {
      request.headers.add('X-Reference-Id', _referenceID);
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      request.write(data);
      return request.close();
    }). then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _createAPIUserURL));
      print(response.statusCode);
      print(response.reasonPhrase);
      print(_referenceID);
      return response;
    });

    return response;
  }

  static Future<HttpClientResponse> getAPIKey() async {

      var client = AltHttpClient();
      var ap = '';

      HttpClientResponse response = await client.postUrl(Uri.https(_hostURL, _getAPIKeyURL,)).then((
          HttpClientRequest request) {
        request.headers.add('X-Reference-Id', _referenceID);
        request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
        request.headers.contentType = ContentType.json;
        return request.close();
      }).then((HttpClientResponse response) async {
        print(Uri.https(_hostURL, _getAPIKeyURL));
        print(response.statusCode);
        print(response.reasonPhrase);
        response.transform(utf8.decoder).listen((contents) {
          // handle data
          ap = json.decode(contents)['apiKey'];
          _setAPIKey(ap);
          print(_apiKey);
        }).onDone(() {

        });

        return response;
      });

      return response;
  }

  static Future<HttpClientResponse> getDisbursementToken() async {

    String credentials = '$_referenceID:$_apiKey';
    String basicCred = base64.encode(utf8.encode(credentials));

    var client = AltHttpClient();

    HttpClientResponse response = await client.postUrl(Uri.https(_hostURL, _getDisbursementTokenURL)).then((HttpClientRequest request) {
      request.headers.add('Authorization', 'Basic ${base64.encode(utf8.encode(credentials))}');
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      return request.close();
    }). then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _getDisbursementTokenURL));
      print(response.statusCode);
      print(response.reasonPhrase);
      print(credentials);
      response.transform(utf8.decoder).listen((contents) {
        // handle data
        var at = json.decode(contents)['access_token'];
        _setAccessToken(json.decode(contents)['access_token']);
        print(_accessToken);
      }).onDone(() {

      });
      return response;
    });

    return response;
  }

  static Future<List<String>> getAccountBalance() async {

    var availableBalance = '0.0';
    var currency = '';

    var client = AltHttpClient();

    var req = await client.getUrl(Uri.https(_hostURL, _getAccountBalanceURL)).then((HttpClientRequest request) {
      request.headers.add('Authorization', 'Bearer $_accessToken');
      request.headers.add('X-Reference-Id', _referenceID);
      request.headers.add('X-Target-Environment', 'sandbox');
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      return request.close();
    // ignore: missing_return
    }). then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _getAccountBalanceURL));
      print(response.statusCode);
      print(response.reasonPhrase);
      if (response.statusCode != 200) {
        return[3000.00, "GHS"];
      } else {
        response.transform(utf8.decoder).listen((contents) {
          // handle data
          availableBalance = json.decode(contents)['availableBalance'];
          print(availableBalance);
          currency = json.decode(contents)['currency'];
          print(currency);
        });
      }
    });

    return [availableBalance, currency];

  }

  static Future<HttpClientResponse> transferMoney(double amount, String currency, String payee, String message) async {

    var data = {
      "amount": "$amount",
      "currency": "$currency",
      "externalId": "12345",
      "payee": {
        "partyIdType": "MSISDN",
        "partyId": "$payee"
      },
      "payerMessage": "$message",
      "payeeNote": "test note"
    };

    var body = json.encode(data);

    print(body);

    var client = AltHttpClient();

    HttpClientResponse response = await client.postUrl(Uri.https(_hostURL, _transferMoneyURL)).then((HttpClientRequest request) {
      request.headers.add('Authorization', 'Bearer $_accessToken');
      request.headers.add('X-Reference-Id', _referenceID);
      request.headers.add('X-Target-Environment', 'sandbox');
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      request.write(body);
      return request.close();
    }). then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _transferMoneyURL));
      print(response.statusCode);
      print(response.reasonPhrase);
      response.transform(utf8.decoder).listen((contents) {
        // handle data
        print(json.decode(contents));
      });
      return response;
    });

    return response;
  }

  static Future<HttpClientResponse> checkTransactionStatus() async {

    var client = AltHttpClient();

    HttpClientResponse response = await client.getUrl(Uri.https(_hostURL, _checkTransferStatusURL)).then((HttpClientRequest request) {
      request.headers.add('Authorization', 'Bearer $_accessToken');
      request.headers.add('X-Reference-Id', _referenceID);
      request.headers.add('X-Target-Environment', 'sandbox');
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      return request.close();
    }). then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _checkTransferStatusURL));
      print(response.statusCode);
      print(response.reasonPhrase);
      response.transform(utf8.decoder).listen((contents) {
        // handle data
        //print(contents);
        _transactionStatus = contents;
      });
      return response;
    });

    return response;

  }

  static String getTransactionStatus() {
    var status = _transactionStatus;
    _transactionStatus = '';
    return status;
  }

}

enum PaymentPlan {
  HALF,
  QUARTER,
  TEN,
  FIVE
}

class MOMOTransaction {

  /*
  Might need to implement this later.
  final String financialTransactionID
  */
  final double _amount;
  final String _currency;
  final String _message;

  MOMOTransaction(this._amount, this._currency, this._message);

  double get getAmount { return this._amount; }

  String get getCurrency { return this._currency; }

  String get getMessage { return this._message; }

  Map<String, dynamic> jsonEncode() {
    return {
      "amount": getAmount,
      "currency": getCurrency,
      "message": getMessage
    };
  }

  factory MOMOTransaction.fromJSON(Map<String, dynamic> json) =>
      MOMOTransaction(json["amount"], json["currency"], json["message"]);

}

class AfterPayTransaction{

  final String _payee;
  final String _financialTransactionID;
  final double _totalAmount;
  final PaymentPlan _plan;
  double _initialPaymentAmount;
  Queue<MOMOTransaction> _transactions;
  Queue<MOMOTransaction> _completedTransactions;
  Queue<MOMOTransaction> _remainingTransactions;
  bool _completed;

  AfterPayTransaction(this._payee, this._financialTransactionID, this._totalAmount, this._plan, String currency, String message) {
    double remainder = 0.0;
    double recurringCharge = 0.0;
    _transactions = Queue<MOMOTransaction>();
    _completedTransactions = Queue<MOMOTransaction>();
    _remainingTransactions = Queue<MOMOTransaction>();

    switch (_plan) {
      case PaymentPlan.HALF:
        _initialPaymentAmount = _totalAmount * 0.5;
        remainder = _totalAmount * 0.5;
        recurringCharge = remainder / 6;
        _transactions.addFirst(MOMOTransaction(initialPayment, currency, message));
        _completedTransactions.add(MOMOTransaction(initialPayment, currency, message));
        for (var i = 0; i < 6; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        break;
      case PaymentPlan.QUARTER:
        _initialPaymentAmount = _totalAmount * 0.25;
        remainder = _totalAmount * 0.75;
        recurringCharge = remainder / 4;
        _transactions.addFirst(MOMOTransaction(initialPayment, currency, message));
        _completedTransactions.add(MOMOTransaction(initialPayment, currency, message));
        for (var i = 0; i < 4; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        break;
      case PaymentPlan.TEN:
        _initialPaymentAmount = _totalAmount * 0.10;
        remainder = _totalAmount * 0.90;
        recurringCharge = remainder / 2;
        _transactions.addFirst(MOMOTransaction(initialPayment, currency, message));
        _completedTransactions.add(MOMOTransaction(initialPayment, currency, message));
        for (var i = 0; i < 2; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        break;
      case PaymentPlan.FIVE:
        _initialPaymentAmount = _totalAmount * 0.05;
        remainder = _totalAmount * 0.95;
        recurringCharge = remainder / 7;
        _transactions.addFirst(MOMOTransaction(initialPayment, currency, message));
        _completedTransactions.add(MOMOTransaction(initialPayment, currency, message));
        for (var i = 0; i < 7; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
    }
    _completed = false;

    _deduct(initialPayment, _totalAmount);

  }

  _deduct(double initialPayment, double totalAmount) async {
    LocalStorage storage = new LocalStorage("credentials");

    var currentAccBal = storage.getItem("accountBalance");
    var currentAvailBal =  storage.getItem("availableBalance");

    await storage.setItem("accountBalance", currentAccBal - initialPayment);
    await storage.setItem("availableBalance", currentAvailBal - _totalAmount);
  }

  completeNextTransaction() {
    if (this.isCompleted == false) {
      var nextTransaction = _remainingTransactions.removeFirst();
      //TODO: Process the next transaction. If successful, add it to the _completedTransactions, if not, return it to the first of the _remainingTransactions
      if (_remainingTransactions.isEmpty) {
        _completed = true;
      }
      _completedTransactions.add(nextTransaction);
    } else {
      //TODO: Notify them that it's a completed transaction.
    }
  }

  double get initialPayment { return this._initialPaymentAmount; }

  String get payee { return this._payee; }

  Queue<MOMOTransaction> get allTransactions { return this._transactions; }

  Queue<MOMOTransaction> get remainingTransactions { return this._remainingTransactions; }

  Queue<MOMOTransaction> get completedTransactions { return this._completedTransactions; }

  PaymentPlan get paymentPlan { return this._plan; }

  bool get isCompleted { return this._completed; }

  factory AfterPayTransaction.fromJSON(Map<String, dynamic> json) {
    var transactions = Queue<MOMOTransaction>();
    var completedTransactions = Queue<MOMOTransaction>();
    var remainingTransactions = Queue<MOMOTransaction>();
    PaymentPlan plan;

    if (json["plan"] == "PaymentPlan.HALF") {
      plan = PaymentPlan.HALF;
    } else if (json["plan"] == "PaymentPlan.QUARTER") {
      plan = PaymentPlan.QUARTER;
    } else if (json["plan"] == "PaymentPlan.TEN") {
      plan = PaymentPlan.TEN;
    } else if (json["plan"] == "PaymentPlan.FIVE") {
      plan = PaymentPlan.FIVE;
    }

    var transaction = new AfterPayTransaction(json["payee"], json["financialTransactionID"], json["totalAmount"], plan, json["currency"], json["message"]);
    transaction._completed = json["completed"] == 1;
    transactions = _getTransactionsFromJSON(json, "transactions");
    completedTransactions = _getTransactionsFromJSON(json, "completedTransactions");
    remainingTransactions = _getTransactionsFromJSON(json, "remainingTransactions");

    transaction._transactions = transactions;
    transaction._completedTransactions = completedTransactions;
    transaction._remainingTransactions = remainingTransactions;

    return transaction;
  }

  static Queue<MOMOTransaction> _getTransactionsFromJSON(Map<String, dynamic> json, String object) {
    var transactions = Queue<MOMOTransaction>();
    for (var item in json[object]) {
      var momoTrans = MOMOTransaction.fromJSON(item);
      transactions.add(momoTrans);
    }

    return transactions;
  }

  List<Map<String, dynamic>> convertTransactionQueueToJSON(transactionQueue) {
    List<Map<String, dynamic>> list = new List<Map<String, dynamic>>();
    transactionQueue.forEach((transaction) {
      list.add(transaction.jsonEncode());
    });
    return list;
  }

  String toJSON() => jsonEncode({
    'payee': _payee,
    'financialTransactionID': _financialTransactionID,
    'totalAmount': _totalAmount,
    'plan': _plan.toString(),
    'initialPayment' : _initialPaymentAmount,
    'transactions' : this.convertTransactionQueueToJSON(_transactions),
    'completedTransactions' : this.convertTransactionQueueToJSON(_completedTransactions),
    'remainingTransactions' : this.convertTransactionQueueToJSON(_remainingTransactions),
    'completed' : _completed
  });

  Map<String, dynamic> toMap() {
    return { "afterpayID": _financialTransactionID, "afterpayJSON": this.toJSON() };
  }

  static Map<String, dynamic> fromMap(Map<String, dynamic> dbRecord) {
    var res = json.decode(dbRecord["afterpayJSON"]);
    return res;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "payee: ${this.payee}, financial transaction id: ${this._financialTransactionID}, total amount: ${this._totalAmount}, payment plan: ${this.paymentPlan}, initial payment: ${this.initialPayment}, completed: ${this.isCompleted}";
  }

}