import 'package:toopdbq/common/ExDatetime.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';

class SqMetUser{


  static Future<List> getMetUser({Function? callback}) async{

    if(App.sdb == null){await App.initSqlite();}
    List<Map> list = (await App.sdb!.rawQuery('SELECT * FROM metUser'));
    if(list.isNotEmpty) {
      print(list);
      if(callback != null) callback(list);
    }
    print('sq getMetUser numList:${list.length}');
    return list;
  }

  static Future<void> addMetUser(String uid) async{
    print('sq addMetUser');
    if(App.sdb == null){await App.initSqlite();}

    String time = DateTime.now().toFormString();
    List<Map> list = await App.sdb!.rawQuery('SELECT * FROM metUser WHERE uid = "$uid"');
    Map<String,String> user = {'uid':uid,'time':time};
    if(list.isEmpty) {
      await App.sdb!.insert('metUser', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }else{
      await App.sdb!.insert('metUser', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> deleteTable() async {
    print('sq metUser deleteTable');
    await App.sdb!.transaction((txn) async {
      await txn.execute('DROP TABLE metUser');
    });
  }
}