import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class MTNMobileMoney {

  MTNMobileMoney._();
  static final MTNMobileMoney mtnMOMO = MTNMobileMoney._();
  String apiKey = '';
  String accessToken = '';
  static final referenceID = new Uuid().v4();
  static final createAPIUserURL = 'sandbox.momodeveloper.mtn.com/v1_0/apiuser';
  static final getAPIKeyURL = 'sandbox.momodeveloper.mtn.com/v1_0/apiuser/' + referenceID + '/apikey';
  static final getDisbursementTokenURL = 'sandbox.momodeveloper.mtn.com/v1_0/disbursement/token/';
  static final getAccountBalanceURL = 'sandbox.momodeveloper.mtn.com/v1_0/account/balance';
  static final transferMoneyURL = 'sandbox.momodeveloper.mtn.com/v1_0/transfer';
  static final checkTransferStatusURL = 'sandbox.momodeveloper.mtn.com/v1_0/transfer/' + referenceID;

  final String collectionsKey = 'df26565ecc4c4abe94ca3f0dae9bd5c9';
  final String disbursementKey = 'd89864081c2749c183c7457204ffb74a';

  Future<http.Response> getAPIKey() {

  }
}