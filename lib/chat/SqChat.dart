import 'package:flutter/cupertino.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';

class SqChat {
  static Future<void> create(Database db) async{
    print('sq chat create');
    await db.execute('''CREATE TABLE chat (
      tid TEXT PRIMARY KEY , 
      nameTalk TEXT ,
      time TEXT ,
      text TEXT ,
      uid TEXT ,
      nameUser TEXT ,
      urlIcon TEXT ,
      new INTEGER , 
      tokenReceiver TEXT
    )''');
  }

  static Future<List<Map>> select(String id) async{
    if (App.sdb == null) {
      await App.initSqlite();
    }
    List<Map> list = await App.sdb!.query('chat',where: 'tid = ?', whereArgs: [id]);
    print('sq chat select numList:${list.length}');
    return list;
  }

  static Future<void> selectAll(Function callback) async {
    if (App.sdb == null) await App.initSqlite();
    List<Map> list = (await App.sdb!.rawQuery(
        'SELECT * FROM chat ORDER BY time DESC'));
    print('sq chat selectAll listNum:${list.length}');
    callback(list);
  }

  static Future<void> update(Map<String, dynamic> talk) async {
    print('update');
    if (App.sdb == null) await App.initSqlite();
    if (talk['tid'] == null) {
      print('sq chat update no table');
      return;
    }
    List<Map> list = (await App.sdb!.query('chat', where: 'tid = ?', whereArgs: [talk['tid']]));
    int count = list.length;
    print('sq chat update talk');
    if (count > 0) {
      await App.sdb!.update(
          'chat', talk, where: 'tid = ?', whereArgs: [talk['tid']]);
    } else {
      await App.sdb!.insert(
          'chat', talk, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> updateCheckAll() async{
    if (App.sdb == null) await App.initSqlite();
    print('sq chat updateCheckAll');
    for(var map in await App.sdb!.query('chat',where: 'new = ?',whereArgs: [0])){
      String tid = map['tid'] as String;
      updateCheck(map,tid);
    }
  }

  static Future<void> updateCheck(Map<String, Object?> map, String tid) async{
    if (App.sdb == null) await App.initSqlite();
    print('sq chat updateCheck tid:$tid');
    App.sdb!.update('chat', map,where: 'tid = ?',whereArgs: [tid]);
  }

  static delete(String tid) async{
    if (App.sdb == null) await App.initSqlite();
    print('sq chat delete tid:$tid');
    App.sdb!.delete('chat', where: 'tid=?', whereArgs: [tid]);
    App.sdb!.delete('chat_$tid');
  }
}

class SqTalk {
  static Future<void> create(String tid) async {
    if (App.sdb == null) await App.initSqlite();
    debugPrint('sq chat create tid:$tid');
    await App.sdb!.transaction((txn) async {
      await txn.execute('''CREATE TABLE IF NOT EXISTS chat_$tid (
        idx INTEGER PRIMARY KEY AUTOINCREMENT, 
        tid TEXT ,
        nameTalk TEXT , 
        time TEXT ,
        text TEXT , 
        uid TEXT ,
        nameUser Text ,
        new INTEGER
      )''');
    });
  }

  static Future<void> selectNew(String id, int? indexBtm, Function callback) async {
    if (App.sdb == null) await App.initSqlite();
    late String query;
    if (indexBtm == null) {
      query = 'SELECT * FROM chat_$id ORDER BY idx DESC LIMIT 20';
    } else {
      query =
      'SELECT * FROM chat_$id WHERE idx > ${indexBtm} ORDER BY idx DESC ';
    }
    List<Map> list = (await App.sdb!.rawQuery(query));
    debugPrint(list.toString());
    if (list.isNotEmpty) {
      callback(list);
    }
    print('sq chat selectNew numList:${list.length}');
  }

  static Future<void> selectOld(String id, int? indexTop, Function callback) async {
    if (App.sdb == null) await App.initSqlite();
    if (indexTop != null) {
      var query = 'SELECT * FROM chat_$id ORDER BY idx DESC LIMIT 20 ,${indexTop +
          1}';
      List<Map> list = (await App.sdb!.rawQuery(query));
      if (list.isEmpty) {
        return;
      }
      callback(list);
      print('sq chat selectOld numList:${list.length}');
    }else{
      print('sq chat selectOld none');
    }
  }

  static Future<void> insert(Map msg) async {
    if (App.sdb == null) await App.initSqlite();
    await create(msg['tid']);
    print('sq chat insert msg:${msg}');
    await App.sdb!.transaction((txn) async {
      await txn.rawInsert('''INSERT INTO chat_${msg['tid']}(
        tid, nameTalk, time, text, uid, nameUser, new
      ) VALUES(
        "${msg['tid']}",
        "${msg['nameTalk']}",
        "${msg['time']}", 
        "${msg['text']}", 
        "${msg['uid']}",
        "${msg['nameUser']}",
        "${msg['new'] ?? 0}"
      )''');
      print('insert msg : $msg');
    });
  }

  static Future<List<Map>> selectTimeline(DateTime timeTop,DateTime timeBtm) async {
    if (App.sdb == null) await App.initSqlite();
    List<Map> listTable = (await App.sdb!.query(
        'sqlite_master', where: 'name LIKE ?', whereArgs: ['chat_%']));
    List<String> listTableName = listTable.map((e) => e['name'] as String).toList();
    List<Map> listMsg = [];
    for (var tableName in listTableName) {
      List<Map> listMsgTable = await selectMsgTimeline(tableName, timeTop,timeBtm);
      listMsg = [...listMsg, ...listMsgTable];
    }
    listMsg.sort((a, b) => b['time'].compareTo(a['time']));
    print('sq chat selectTimeline time : $timeTop, listNum: ${listMsg.length}');
    return listMsg;
  }

  static Future<List<Map>> selectMsgTimeline(String name, DateTime timeTop,DateTime timeBtm) async {
    if (App.sdb == null) await App.initSqlite();
    String strTimeTop = timeTop.toFormString();
    String strTimeBtm = timeBtm.toFormString();
    String query = 'SELECT * FROM $name WHERE $strTimeTop >= time AND time > $strTimeBtm AND uid != "null"';
    List<Map> list = await App.sdb!.rawQuery(query);
    print('sq chat selectMsgTimeline numList:${list.length}');
    return list;
  }

  static Future<Map?> selectReply(Map msg) async{
    try{
      String query = 'SELECT * FROM chat_${msg['uid']} WHERE idx = ${msg['idx'] + 1}';
      final result = await App.sdb!.rawQuery(query);
      Map? msgReply = result.first;
      if(msgReply['tid'] == null || msgReply['uid'] == 'null'){
        print('sq chat selectReply msgReply:${msgReply}');
        return msgReply;
      }else{
        print('sq chat selectReply null');
        return null;
      }
    }catch(e){
      print(e);
      print('sq chat selectReply null');
      return null;
    }
  }
}


