import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'mtnmobilemoney.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  static Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  static initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "payments.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Transactions ("
          "afterpayID PRIMARY KEY,"
          "afterpayJSON BLOB"
          ")");
    });
  }

  // ignore: missing_return
  static Future<DBStatus> storeAfterpayTransaction(AfterPayTransaction transaction) async {
    await DBProvider.database.then((database) {
      database.insert("Transactions", transaction.toMap()).then((res) async {
        print(res);
      });
    });
  }

  // ignore: missing_return
  static Future<List<Map<String, dynamic>>> getAllTransactions() async {
    var res = List<Map<String, dynamic>>();
    await DBProvider.database.then((database) async {
      res = await database.query("Transactions", columns: ["afterPayJSON"]).then((results) {
        return results;
      });
    });
    return res;
  }

  static deleteTransactionTable() async {
    await DBProvider.database.then((database) async {
      await database.delete("Transactions").then((number) {
        print(number);
      });
    });
  }

}

enum DBStatus {
  SUCCESS,
  FAILURE
}

