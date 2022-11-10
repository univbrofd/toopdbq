import 'package:firebase_database/firebase_database.dart';
import 'package:toopdbq/FbMain.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/swichat/SqSwichat.dart';

class FbSwichat{
  static void setLog(UserMt userMy) async{
    List<String> listTag = await SqSwichat.getTag();
    print('FbSwichat setLog');
    refFdb.child('swichat/${UserMt.mid}').set({
      'time' : DateTime.now().toFormString(),
      'listTag':listTag,
      'uid':UserMt.mid,
      'token':UserMt.tokenMy,
      'sex':userMy.sex,
      'sexTarget':userMy.sexTarget,
      'birthday':userMy.birthday,
      'age':userMy.age,
      'ageTargetTop':userMy.ageTargetTop,
      'ageTargetBtm':userMy.ageTargetBtm,
      'live1':userMy.live1,
      'live2':userMy.live2,
      'live3':userMy.live3,
    });
  }

  static Future<List> getLog() async{
    print('Fb swichat getLog');

    DateTime timeStart = DateTime.now().subtract(const Duration(hours: 1));
    String strTime = timeStart.toFormString();

    final snap = await refFdb.child('swichat').orderByChild('time').startAt(strTime).get();
    if(snap.exists){
      print((snap.value as Map).values.toList());
      Map data = snap.value as Map;
      List list = data.values.toList();
      list.sort((a,b) => (a['time'] == null || b['time'] == null) ? false : a['time']!.compareTo(b['time']!));
      print('FbSwichat getLog list:${list.reversed.toList()}');
      return list.reversed.toList();
    }else{
      print("Fb getLog no data");
      return [];
    }
  }

  static deleteLog() async{
    print('FbSwichat deleteLog');
    await refFdb.child('swichat/${UserMt.mid}').remove();
  }

  static Future<Map?> getMatch({String? uid}) async{
    print('fb swichat getMatch');
    final snap = await refFdb.child('swichatMatch/${uid ?? UserMt.mid}').get();
    if(snap.exists){
      Map map = snap.value as Map;
      return map;
    }else{
      return null;
    }
  }

  static invite(String uid,String token) async{
    print('fb swichat invite');
    refFdb.child('swichatInvite/${UserMt.mid}').set({
      'uid':uid,
      'token':token,
      'tokenHandler':UserMt.tokenMy,
    });
  }

  static switchUser({String? uid}) async{
    print('fb switchUser');
    refFdb.child('swichatMatch/${UserMt.mid}').remove();
    if(uid == null)return;
    final snap = await refFdb.child('swichatMatch/$uid/uid').get();
    if(snap.exists && snap.value == UserMt.mid){
      refFdb.child('swichatMatch/$uid').remove();
    }
  }

  static Future<String?> getTimeMatch() async{
    final snap = await refFdb.child('swichatMatch/${UserMt.mid}/timeMatch').get();
    if(snap.exists){
      return snap.value as String;
    }
  }
}