import 'package:flutter/widgets.dart';

import '../FbMain.dart';
import '../common/user.dart';
import '../main.dart';
import 'SqFriend.dart';

class FbFriend{
  static Future<List<String>> getMatch({Function(List<String> list)? callback}) async{

    final snap = await refFdb.child('match/${UserMt.mid}').get();
    if(snap.exists){
      Map data = snap.value as Map;
      List<String> listUidM = List<String>.from(data.keys);
      for(String uid in listUidM) {
        SqFriend.insert(uid);
      }
      refFdb.child('match/${UserMt.mid}').remove();
      if(callback != null) callback(listUidM);
      print('fb friend getMatch numList:${listUidM.length}');
      return listUidM;
    }else{
      print('fb friend getMatch null');
      return [];
    }
  }
}