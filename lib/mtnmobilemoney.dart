import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:alt_http/alt_http.dart';
import 'package:uuid/uuid.dart';

class MTNMobileMoney {

  MTNMobileMoney._();
  static final MTNMobileMoney _mtnMOMO = MTNMobileMoney._();
  static String _apiKey = '';
  static String _accessToken = '';
  //static final _referenceID = Uuid().v4();
  static final _referenceID = 'cd0f4b28-3de1-4148-bf2e-aa3543dc5be2';
  static final _hostURL = 'sandbox.momodeveloper.mtn.com';
  static final _createAPIUserURL = '/v1_0/apiuser';
  static final _getAPIKeyURL = '/v1_0/apiuser/' + _referenceID + '/apikey';
  static final _getDisbursementTokenURL = '/disbursement/token/';
  static final _getAccountBalanceURL = '/disbursement/v1_0/account/balance';
  static final _transferMoneyURL = '/disbursement/v1_0/transfer';
  static final _checkTransferStatusURL = '/disbursement/v1_0/transfer/' + _referenceID;

  static final String _collectionsKey = 'df26565ecc4c4abe94ca3f0dae9bd5c9';
  static final String _disbursementKey = 'd89864081c2749c183c7457204ffb74a';

  static Future<http.Response> createAPIUser() async {

    var client = AltHttpClient();

    var data = {
      'providerCallbackHost' : 'string'
    };

    var req = await client.postUrl(Uri.https(_hostURL, _createAPIUserURL)).then((HttpClientRequest request) {
      request.headers.add('X-Reference-Id', _referenceID);
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      request.write(data);
      return request.close();
    }). then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _createAPIUserURL));
      print(response.statusCode);
      print(response.reasonPhrase);
    });

  }

  static Future<http.Response> getAPIKey() async {

    var client = AltHttpClient();

    var req = await client.postUrl(Uri.https(_hostURL, _getAPIKeyURL,)).then((HttpClientRequest request) {
      request.headers.add('X-Reference-Id', _referenceID);
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      return request.close();
    }).then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _getAPIKeyURL));
      print(response.statusCode);
      print(response.reasonPhrase);
      response.transform(utf8.decoder).listen((contents) {
        // handle data
        _apiKey = json.decode(contents)['apiKey'];
        print(_apiKey);
      });
    });
  }

  static Future<http.Response> getDisbursementToken() async {

    String credentials = '$_referenceID:$_apiKey';
    String basicCred = base64.encode(utf8.encode(credentials));

    var client = AltHttpClient();

    var req = await client.postUrl(Uri.https(_hostURL, _getDisbursementTokenURL)).then((HttpClientRequest request) {
      request.headers.add('Authorization', 'Basic $basicCred');
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      return request.close();
    }). then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _getDisbursementTokenURL));
      print(response.statusCode);
      print(response.reasonPhrase);
      response.transform(utf8.decoder).listen((contents) {
        // handle data
        _accessToken = json.decode(contents)['access_token'];
        print(_accessToken);
      });
    });

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

  static Future<http.Response> transferMoney() async {

    var data = {
      "amount": "5000",
      "currency": "EUR",
      "externalId": "12345",
      "payee": {
        "partyIdType": "MSISDN",
        "partyId": "0780123456"
      },
      "payerMessage": "test message",
      "payeeNote": "test note"
    };

    var body = json.encode(data);

    print(body);

    var client = AltHttpClient();

    var req = await client.postUrl(Uri.https(_hostURL, _transferMoneyURL)).then((HttpClientRequest request) {
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
    });

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
      });
      return response;
    });

    return response;

  }
}

enum PaymentPlan {
  HALF,
  QUARTER,
  TEN,
  FIVE
}

class MOMOTransaction {

  final double _amount;
  final String _currency;
  final String _message;

  MOMOTransaction(this._amount, this._currency, this._message);

  double get getAmount { return this._amount; }

  String get getCurrency { return this._currency; }

  String get getMessage { return this._message; }

}

class AfterPayTransaction{

  final String _payee;
  final String _payer;
  final double _totalAmount;
  final PaymentPlan _plan;
  double _initialPaymentAmount;
  Queue<MOMOTransaction> _transactions;
  Queue<MOMOTransaction> _completedTransactions;
  Queue<MOMOTransaction> _remainingTransactions;
  bool _completed;

  AfterPayTransaction(this._payee, this._payer, this._totalAmount, this._plan, String currency, String message) {
    //TODO: Initialise _completedTransactions and _remainingTransactions
    double remainder = 0.0;
    double recurringCharge = 0.0;

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

  String get payer { return this._payer; }

  Queue<MOMOTransaction> get allTransactions { return this._transactions; }

  Queue<MOMOTransaction> get remainingTransactions { return this._remainingTransactions; }

  Queue<MOMOTransaction> get completedTransactions { return this._completedTransactions; }

  PaymentPlan get paymentPlan { return this._plan; }

  bool get isCompleted { return this._completed; }

}