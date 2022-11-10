import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toopdbq/common/ExDatetime.dart';

import '../main.dart';

class SqSwichat {
  static setTag(List<String> list) async{
    print('sq swichat setTag num:${list.length}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('listSwichatTag', list);
  }

  static Future<List<String>> getTag() async{
    final prefs = await SharedPreferences.getInstance();
    List<String> listTag = prefs.getStringList('listSwichatTag') ?? [];
    print('sq swichat getTag num:${listTag.length}');
    return listTag;
  }

  static Future<List> getLikeUid(Function? callback) async{
    if(App.sdb == null){await App.initSqlite();}
    List<Map> list = (await App.sdb!.rawQuery('SELECT * FROM likeUid'));
    if(list.isNotEmpty) {
      print(list);
      if(callback != null) callback(list);
    }
    print('sq event getLikeUid numList:${list.length}');
    return list;
  }

  static Future<void> addLikeUid(String uid) async{
    if(App.sdb == null){await App.initSqlite();}
    print('fb event addLikeUid');
    String time = DateTime.now().toFormString();
    Map<String,String> user = {'uid':uid,'time':time};
    if(await existUid(uid)) {
      await App.sdb!.insert('likeUid', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<bool> existUid(String uid) async{
    if(App.sdb == null){await App.initSqlite();}
    List<Map> list = await App.sdb!.rawQuery('SELECT * FROM likeUid WHERE uid = "$uid"');
    print('fb event existUid bol:${list.isNotEmpty} list:$list');
    return list.isNotEmpty;
  }
}