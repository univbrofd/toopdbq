import 'package:flutter/cupertino.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';

import '../FbMain.dart';
import '../main.dart';
import 'SqChat.dart';

class FbChat{
  static Future<List> getMsg_Save({Function(List<List<Map>>)? callback}) async{
    if(UserMt.mid == null) return [];
    Map<String,List<Map>> mapChat = {};
    List<Map> listMsg = [];
    final snapshot = await refFdb.child('msg/${UserMt.mid}').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      listMsg = List<Map>.from(data.values.toList());
      debugPrint(data.toString());
      for(Map info in data.values){
        var tid = info['tid'];
        if(tid == null){
          print('fb chat getMsg null');
          return [];
        }
        if(mapChat.containsKey(tid)){
          mapChat[tid]!.add(info);
        }else{
          mapChat[tid] = [info];
        }
      }
      print('fb chat getMsg numList:${listMsg.length}');
    }else{
      debugPrint('msg data is empty');
    }
    List<Map> listChat = [];
    for(String tid in mapChat.keys){
      mapChat[tid]!.sort((a,b) => a['time'].compareTo(b['time']));
      for(Map msg in mapChat[tid]!){
        await SqTalk.insert(msg);
      }
      Map<String,dynamic> msgNew = Map<String,dynamic>.from(mapChat[tid]!.last);
      listChat.add(msgNew);
      await SqChat.update(msgNew);
    }
    print('fb msg remove');
    refFdb.child('msg/${UserMt.mid}').remove();
    if(callback != null) callback([listChat,listMsg]);
    return [mapChat,listChat,listMsg];
  }

  static Future<void> sendMsg({
    required String uidReceiver,
    required String text,
    String? tid,
    String? nameTalk,
    Function(Map msg)? callback,
  })  async{
    if(text.isEmpty || uidReceiver.isEmpty){return;}
    if(UserMt.mid == null)return;
    String time = DateTime.now().toFormString();
    final snap = await refFdb.child('user/$uidReceiver/token').get();
    print('fb caht get user token');
    String? tokenReceiver = snap.value as String?;
    Map<String,dynamic>  msgM = {
      'nameTalk': nameTalk,
      'time':time,
      'text':text,
      'nameUser':UserMt.nameMy,
    };
    Map<String,dynamic> msgHandler = {...msgM,
      'tid': tid ?? uidReceiver,
    };

    Map<String,dynamic> msgReceiver = {...msgM,
      'tid': tid == uidReceiver ? UserMt.mid : tid ?? UserMt.mid,
      'uid':UserMt.mid,
      'tokenReceiver': tokenReceiver
    };

    print('FbChat sendMsg : $msgHandler');
    refFdb.child('msg/$uidReceiver/${UserMt.mid}-$time').set(msgReceiver);
    SqTalk.insert(msgHandler);
    SqChat.update(msgHandler);
    if(callback != null) callback(msgHandler);
  }
}