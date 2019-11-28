import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:alt_http/alt_http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uuid/uuid.dart';

class MTNMobileMoney {

  MTNMobileMoney._();
  // ignore: unused_field
  static final MTNMobileMoney _mtnMOMO = MTNMobileMoney._();
  static String _apiKey = '';
  static String _accessToken = '';
  static String _referenceID = '';
  static String _transactionStatus = '';
  static final _hostURL = 'sandbox.momodeveloper.mtn.com';
  static final _createAPIUserURL = '/v1_0/apiuser';
  static var _getAPIKeyURL = '/v1_0/apiuser/' + _referenceID + '/apikey';
  static final _getDisbursementTokenURL = '/disbursement/token/';
  static final _getAccountBalanceURL = '/disbursement/v1_0/account/balance';
  static final _transferMoneyURL = '/disbursement/v1_0/transfer';
  static var _checkTransferStatusURL = '/disbursement/v1_0/transfer/' + _referenceID;

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
        _setAccessToken(json.decode(contents)['access_token']);
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

    await client.getUrl(Uri.https(_hostURL, _getAccountBalanceURL)).then((HttpClientRequest request) {
      request.headers.add('Authorization', 'Bearer $_accessToken');
      request.headers.add('X-Reference-Id', _referenceID);
      request.headers.add('X-Target-Environment', 'sandbox');
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      return request.close();
    // ignore: missing_return
    }).then((HttpClientResponse response) {
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

  static Future<HttpClientResponse> initiatePostPayTransaction(double amount, String currency, String payee, String message) async {

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

  static Future<HttpClientResponse> payNextPostPayTransaction(double amount, String currency, String payee, String message) async {

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

enum PaymentType {
  CREDIT,
  DEBIT
}

enum PaymentPlan {
  //TODO: Improve the plans and make them more descriptive.
  CREDIT8WEEKS,
  CREDIT6WEEKS,
  CREDIT4WEEKS,
  CREDIT10WEEKS,
  DEBITHALFWEEKLY,
  DEBITQUARTERWEEKLY,
  DEBITTENTHWEEKLY,
  DEBITTRUSTEDWEEKLY
}

class MOMOTransaction {

  /*
  Might need to implement this later.
  final String financialTransactionID
  */
  //TODO: Date and time! How could I forget?
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

class PostPayTransaction {

  //TODO: Date and time! How could I forget?
  final String _payee;
  final String _financialTransactionID;
  final double _totalAmount;
  final PaymentPlan _plan;
  double _initialPaymentAmount;
  double _remainingAmount;
  Queue<MOMOTransaction> _transactions;
  Queue<MOMOTransaction> _completedTransactions;
  Queue<MOMOTransaction> _remainingTransactions;
  bool _completed;

  PostPayTransaction(this._payee, this._financialTransactionID, this._totalAmount, this._plan, String currency, String message, bool shouldDeduct) {

    double remainder = 0.0;
    double recurringCharge = 0.0;
    _transactions = Queue<MOMOTransaction>();
    _completedTransactions = Queue<MOMOTransaction>();
    _remainingTransactions = Queue<MOMOTransaction>();

    switch (_plan) {
      case PaymentPlan.CREDIT8WEEKS:
        _initialPaymentAmount = 0;
        _remainingAmount = _totalAmount;
        recurringCharge = _totalAmount / 8;
        for (var i = 0; i < 8; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        break;
      case PaymentPlan.CREDIT6WEEKS:
        _initialPaymentAmount = 0;
        _remainingAmount = _totalAmount;
        recurringCharge = _totalAmount / 6;
        for (var i = 0; i < 6; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        break;
      case PaymentPlan.CREDIT4WEEKS:
        _initialPaymentAmount = 0;
        _remainingAmount = _totalAmount;
        recurringCharge = _totalAmount / 4;
        for (var i = 0; i < 4; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        break;
      case PaymentPlan.CREDIT10WEEKS:
        _initialPaymentAmount = 0;
        _remainingAmount = _totalAmount;
        recurringCharge = _totalAmount / 10;
        for (var i = 0; i < 10; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        break;
      case PaymentPlan.DEBITHALFWEEKLY:
        _initialPaymentAmount = _totalAmount * 0.5;
        remainder = _totalAmount * 0.5;
        recurringCharge = remainder / 6;
        _transactions.addFirst(MOMOTransaction(initialPayment, currency, message));
        _completedTransactions.add(MOMOTransaction(initialPayment, currency, message));
        for (var i = 0; i < 6; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        _remainingAmount = _totalAmount - _initialPaymentAmount;
        break;
      case PaymentPlan.DEBITQUARTERWEEKLY:
        _initialPaymentAmount = _totalAmount * 0.25;
        remainder = _totalAmount * 0.75;
        recurringCharge = remainder / 4;
        _transactions.addFirst(MOMOTransaction(initialPayment, currency, message));
        _completedTransactions.add(MOMOTransaction(initialPayment, currency, message));
        for (var i = 0; i < 4; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        _remainingAmount = _totalAmount - _initialPaymentAmount;
        break;
      case PaymentPlan.DEBITTENTHWEEKLY:
        _initialPaymentAmount = _totalAmount * 0.10;
        remainder = _totalAmount * 0.90;
        recurringCharge = remainder / 2;
        _transactions.addFirst(MOMOTransaction(initialPayment, currency, message));
        _completedTransactions.add(MOMOTransaction(initialPayment, currency, message));
        for (var i = 0; i < 2; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        _remainingAmount = _totalAmount - _initialPaymentAmount;
        break;
      case PaymentPlan.DEBITTRUSTEDWEEKLY:
        _initialPaymentAmount = _totalAmount * 0.05;
        remainder = _totalAmount * 0.95;
        recurringCharge = remainder / 6;
        _transactions.addFirst(MOMOTransaction(initialPayment, currency, message));
        _completedTransactions.add(MOMOTransaction(initialPayment, currency, message));
        for (var i = 0; i < 6; i++) {
          _transactions.add(MOMOTransaction(recurringCharge, currency, message));
          _remainingTransactions.add(MOMOTransaction(recurringCharge, currency, message));
        }
        _remainingAmount = _totalAmount - _initialPaymentAmount;
        break;

    }
    _completed = false;

    if (shouldDeduct) {
      _deductWhenCreatingTransaction(initialPayment, _totalAmount);
    }

  }

  _deductWhenCreatingTransaction(double initialPayment, double totalAmount) async {

    LocalStorage storage = new LocalStorage("credentials");

    if (this.paymentPlan.toString().contains("DEBIT")) {

      var currentAccountBal = storage.getItem("accountBalance");
      await storage.setItem("accountBalance", currentAccountBal - initialPayment);

    } else if (this.paymentPlan.toString().contains("CREDIT")) {

      var currentAvailBal =  storage.getItem("availableBalance");
      await storage.setItem("availableBalance", currentAvailBal - _totalAmount);

    }

  }

  _deductWhenCompletingNextTransaction(double amount) async {

    LocalStorage storage = new LocalStorage("credentials");

    if (this.paymentPlan.toString().contains("DEBIT")) {

      var currentAccountBalance = storage.getItem("accountBalance");
      await storage.setItem("accountBalance", currentAccountBalance - amount);

    } else if (this.paymentPlan.toString().contains("CREDIT")) {

      var currentAvailableBal = storage.getItem("availableBalance");
      var currentAccountBalance = storage.getItem("accountBalance");

      await storage.setItem("availableBalance", currentAvailableBal + amount);
      await storage.setItem("accountBalance", currentAccountBalance - amount);

    }

  }

  completeNextTransaction() {

    if (this.isCompleted == false) {

      var completedTransaction = _remainingTransactions.removeFirst();

      print("${_remainingTransactions.length} lovely");

      if (_remainingTransactions.length == 0) {
        this.completed = true;
      }

      this.remainingAmount -= completedTransaction.getAmount;
      _deductWhenCompletingNextTransaction(completedTransaction.getAmount);

      _completedTransactions.add(completedTransaction);
    }

  }

  String get financialTransactionID => _financialTransactionID;

  double get initialPayment { return this._initialPaymentAmount; }

  double get totalAmount => _totalAmount;

  String get payee { return this._payee; }

  Queue<MOMOTransaction> get allTransactions { return this._transactions; }

  Queue<MOMOTransaction> get remainingTransactions { return this._remainingTransactions; }

  Queue<MOMOTransaction> get completedTransactions { return this._completedTransactions; }

  PaymentPlan get paymentPlan { return this._plan; }

  bool get isCompleted { return this._completed; }

  double get remainingAmount => _remainingAmount;

  set remainingAmount(double value) { _remainingAmount = value; }

  set completed(bool value) { _completed = value; }

  factory PostPayTransaction.fromJSON(Map<String, dynamic> json) {
    var transactions = Queue<MOMOTransaction>();
    var completedTransactions = Queue<MOMOTransaction>();
    var remainingTransactions = Queue<MOMOTransaction>();
    var remainingAmount = 0.0;
    PaymentPlan plan;

    if (json["plan"] == PaymentPlan.DEBITHALFWEEKLY.toString()) {
      plan = PaymentPlan.DEBITHALFWEEKLY;
    } else if (json["plan"] == PaymentPlan.DEBITQUARTERWEEKLY.toString()) {
      plan = PaymentPlan.DEBITQUARTERWEEKLY;
    } else if (json["plan"] == PaymentPlan.DEBITTENTHWEEKLY.toString()) {
      plan = PaymentPlan.DEBITTENTHWEEKLY;
    } else if (json["plan"] == PaymentPlan.DEBITTRUSTEDWEEKLY.toString()) {
      plan = PaymentPlan.DEBITTRUSTEDWEEKLY;
    } else if (json["plan"] == PaymentPlan.CREDIT8WEEKS.toString()) {
      plan = PaymentPlan.CREDIT8WEEKS;
    } else if (json["plan"] == PaymentPlan.CREDIT6WEEKS.toString()) {
      plan = PaymentPlan.CREDIT6WEEKS;
    } else if (json["plan"] == PaymentPlan.CREDIT4WEEKS.toString()) {
      plan = PaymentPlan.CREDIT4WEEKS;
    } else if (json["plan"] == PaymentPlan.CREDIT10WEEKS.toString()) {
      plan = PaymentPlan.CREDIT10WEEKS;
    }

    var transaction = new PostPayTransaction(json["payee"], json["financialTransactionID"], json["totalAmount"], plan, json["currency"], json["message"], false);
    transaction._completed = json["completed"] == true;
    transactions = _getTransactionsFromJSON(json, "transactions");
    completedTransactions = _getTransactionsFromJSON(json, "completedTransactions");
    remainingTransactions = _getTransactionsFromJSON(json, "remainingTransactions");
    remainingAmount = json["remainingAmount"];

    transaction._transactions = transactions;
    transaction._completedTransactions = completedTransactions;
    transaction._remainingTransactions = remainingTransactions;
    transaction._remainingAmount = remainingAmount;

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
    'remainingAmount': _remainingAmount,
    'plan': _plan.toString(),
    'initialPayment' : _initialPaymentAmount,
    'transactions' : this.convertTransactionQueueToJSON(_transactions),
    'completedTransactions' : this.convertTransactionQueueToJSON(_completedTransactions),
    'remainingTransactions' : this.convertTransactionQueueToJSON(_remainingTransactions),
    'completed' : _completed
  });

  Map<String, dynamic> toMap() {
    return { "postPayID": _financialTransactionID, "postPayJSON": this.toJSON() };
  }

  static Map<String, dynamic> fromMap(Map<String, dynamic> dbRecord) {
    var res = json.decode(dbRecord["postPayJSON"]);
    return res;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "payee: ${this.payee}, financial transaction id: ${this._financialTransactionID}, total amount: ${this._totalAmount}, remaining amount: ${this._remainingAmount}, payment plan: ${this.paymentPlan}, initial payment: ${this.initialPayment}, completed: ${this.isCompleted}";
  }

  String planAsString() {
    switch (this.paymentPlan) {
      case PaymentPlan.CREDIT8WEEKS:
        return "8 Week Payoff by Credit";
        break;
      case PaymentPlan.CREDIT6WEEKS:
        return "6 Week Payoff by Credit";
        break;
      case PaymentPlan.CREDIT4WEEKS:
        return "4 Week Payoff by Credit";
        break;
      case PaymentPlan.CREDIT10WEEKS:
        return "10 Week Payoff by Credit";
        break;
      case PaymentPlan.DEBITHALFWEEKLY:
        return "Half Weekly";
        break;
      case PaymentPlan.DEBITQUARTERWEEKLY:
        return "Quarter Weekly";
        break;
      case PaymentPlan.DEBITTENTHWEEKLY:
        return "Tenth Weekly";
        break;
      case PaymentPlan.DEBITTRUSTEDWEEKLY:
        return "Trusted Weekly";
        break;

    }
  }

}