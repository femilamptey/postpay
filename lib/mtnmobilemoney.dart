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

    var headers = {
      'Authorization': 'Basic ' + base64.encode(utf8.encode(credentials)),
      'Ocp-Apim-Subscription-Key': _disbursementKey
    };

    var client = AltHttpClient();

    var req = await client.postUrl(Uri.https(_hostURL, _getDisbursementTokenURL)).then((HttpClientRequest request) {
      request.headers.add('Authorization', 'Basic ' + base64.encode(utf8.encode(credentials)));
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

  static Future<List<Object>> getAccountBalance() async {

    var availableBalance = 0.0;
    var currency = '';

    var client = AltHttpClient();

    var req = await client.getUrl(Uri.https(_hostURL, _getAccountBalanceURL)).then((HttpClientRequest request) {
      request.headers.add('Authorization', 'Bearer ' + _accessToken);
      request.headers.add('X-Reference-Id', _referenceID);
      request.headers.add('X-Target-Environment', 'sandbox');
      request.headers.add('Ocp-Apim-Subscription-Key', _disbursementKey);
      request.headers.contentType = ContentType.json;
      return request.close();
    }). then((HttpClientResponse response) {
      print(Uri.https(_hostURL, _getAccountBalanceURL));
      print(response.statusCode);
      print(response.reasonPhrase);
      response.transform(utf8.decoder).listen((contents) {
        // handle data
        availableBalance = double.parse(json.decode(contents)['availableBalance']);
        print(availableBalance);
        currency = json.decode(contents)['currency'];
        print(currency);
      });
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

    var headers = {
      'Authorization': 'Bearer ' + _accessToken,
      'X-Reference-Id': _referenceID,
      'X-Target-Environment': 'sandbox',
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Key': _disbursementKey
    };

    var response = await http.post(
      Uri.https(_hostURL, _transferMoneyURL),
      headers: headers,
      body: body
    );

    print(Uri.https(_hostURL, _transferMoneyURL).toString());
    print(response.statusCode);
    print(response.body);

    checkTransactionStatus();

  }

  static Future<http.Response> checkTransactionStatus() async {

    var headers = {
      'Authorization': 'Bearer ' + _accessToken,
      'X-Reference-Id': _referenceID,
      'X-Target-Environment': 'sandbox',
      'Content-Type': 'application/json',
      'Ocp-Apim-Subscription-Key': _disbursementKey
    };

    var response = await http.get(
      Uri.https(_hostURL, _checkTransferStatusURL),
      headers: headers,
    );

    print(Uri.https(_hostURL, _checkTransferStatusURL).toString());
    print(response.statusCode);
    print(response.body);

  }

}

class MOMOTransaction {

  final Double _amount;
  final String _currency;
  final String _message;

  MOMOTransaction(this._amount, this._currency, this._message);

}

class AfterPayTransaction{

  final String _payee;
  final String _payer;
  final Double _initialPaymentAmount;
  final Queue<MOMOTransaction> _transactions;
  bool _completed;

  AfterPayTransaction(this._payee, this._payer, this._initialPaymentAmount, this._transactions, this._completed);

}