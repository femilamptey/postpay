import 'dart:convert';

Account accountFromJson(String str) {
  final jsonData = json.decode(str);
  return Account.fromJson(jsonData);
}

String clientToJson(Account data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Account {

  int accountNo;
  int pin;
  int accountBalance;
  int availableBalance;

  Account({
    this.accountNo,
    this.pin,
    this.accountBalance,
    this.availableBalance,
  });

  factory Account.fromJson(Map<String, dynamic> json) => new Account(
    accountNo: json["accountNo"],
    pin: json["pin"],
    accountBalance: json["accountBalance"],
    availableBalance: json["availableBalance"],
  );

  Map<String, dynamic> toJson() => {
    "accountNo": accountBalance,
    "pin": pin,
    "accountBalance": accountBalance,
    "availableBalance": availableBalance,
  };

}