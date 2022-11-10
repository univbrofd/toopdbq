
import 'package:toopdbq/common/ExDatetime.dart';

import '../main.dart';

class SqFriend{

  static Future<void> insert(String uid) async{
    if(App.sdb == null){await App.initSqlite();}
    final time = DateTime.now().toFormString();
    if(await selectOne(uid) == null) {
      print('sq friend insert');
      App.sdb!.insert('friend',{'uid':uid,'time':time,'new':0});
    }
  }

  static Future<void> updateCheck(String uid)async{
    if(App.sdb == null){await App.initSqlite();}
    Map<String,Object?>? friend = await selectOne(uid);
    if(friend == null)return;
    Map<String,Object?> friendM = {...friend,'new':1};
    print('sq friend updateCheck uid:$uid');
    await App.sdb!.update('friend', friendM, where: 'uid = ?', whereArgs: [uid]);
  }

  static Future<List<Map>> selectNew() async{
    if(App.sdb == null){await App.initSqlite();}
    List<Map> list = await App.sdb!.query('friend',where: 'new = ?',whereArgs: [0]);
    print('sq friend selectNew numList:${list.length}');
    return list;
  }

  static Future<Map<String,Object?>?> selectOne(String uid) async{
    if(App.sdb == null){await App.initSqlite();}
    List<Map> listFriend = (await App.sdb!.query('friend', where: 'uid = ?', whereArgs: [uid]));
    if(listFriend.isEmpty){
      print('sq friend selectOne null');
      return null;
    }else{
      print('sq friend selectOne uset:${listFriend.first}');
      return listFriend.first as Map<String,Object?>?;
    }
  }

  static Future<List<Map>> selectAll(String? strTime) async{
    if(App.sdb == null){await App.initSqlite();}
    List<Map> list = [];
    if(strTime == null){
      var query = 'SELECT * FROM friend ORDER BY time DESC';
      list = (await App.sdb!.rawQuery(query));
    }else{
      var query = 'SELECT * FROM friend WHERE time > "$strTime" ORDER BY time DESC';
      list = (await App.sdb!.rawQuery(query));
    }
    print('sq friend selectAll numList:${list.length}');
    return list;
  }


}