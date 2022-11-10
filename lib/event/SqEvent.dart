
import 'package:sqflite/sqflite.dart';
import 'package:toopdbq/common/ExDatetime.dart';

import '../main.dart';

class SqEvent{
  static Future<List> getLikeEvent(Function? callback) async{
    if(App.sdb == null){await App.initSqlite();}
    List<Map> list = (await App.sdb!.rawQuery('SELECT * FROM likeEvent'));
    if(list.isNotEmpty) {
      print(list);
      if(callback != null) callback(list);
    }
    print('sq event getLikeEvent numList:${list.length}');
    return list;
  }

  static Future<void> addLikeEvent(String eid) async{
    if(App.sdb == null){await App.initSqlite();}
    print('fb event addLikeEvent');
    String time = DateTime.now().toFormString();
    Map<String,String> user = {'eid':eid,'time':time};
    if(await existEvent(eid)) {
      await App.sdb!.insert('likeEvent', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }else{
      await App.sdb!.insert('likeEvent', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<bool> existEvent(String eid) async{
    if(App.sdb == null){await App.initSqlite();}
    List<Map> list = await App.sdb!.rawQuery('SELECT * FROM likeEvent WHERE eid = "$eid"');
    print('fb event existEvent bol:${list.isNotEmpty} list:$list');
    return list.isNotEmpty;
  }

  static Future<void> deleteTable() async {
    if(App.sdb == null){await App.initSqlite();}
    print('fb event deleteTable');
    await App.sdb!.transaction((txn) async {
      await txn.execute('DROP TABLE likeEvent');
    });
  }
}