import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/couple/couple.dart';

import '../FbMain.dart';

class FbCouple{
  static Future<Map?> get(String cid) async{
    final snap = await refFdb.child('couple/$cid').get();
    print('FbCouple get cid:$cid, data${snap.value}');
    if(snap.exists) {
      return snap.value as Map;
    }else{
      return null;
    }
  }

  static Future<void> up(String cid,String key,dynamic data) async{
    refFdb.child('couple/$cid/$key').set(data);
  }

  static void setInit(Couple couple){
    print('FbCouple setInit');

    refFdb.child('couple/${couple.cid}').set({
      'cid':couple.cid,
      'uidM':couple.userM?.uid,
      'uidF':couple.userF?.uid,
      'timeMatch':couple.timeMatch?.toFormString()
    });
  }

  static Future<void> onOpenChat({required String? cid,required int? sex,required bool bol}) async{
    if(cid == null || sex == null)return;
    refFdb.child('couple/$cid/${sex == 0 ? 'openM' : 'openF'}').set(bol);
  }

  static Future<void> uploadOpenChat(Couple couple) async{
    print('fb couple uploadOpenChat');

    if(couple.listMsgUpload.isNotEmpty) {
      for (Map msg in couple.listMsgUpload) {
        print('openChat add msg:$msg');
        refFdb.child('openChat/${couple.cid}/${couple.cid}-${msg['time']}').set(msg);
      }
    }
    if(couple.listMsgRemove.isNotEmpty) {
      for (Map msg in couple.listMsgRemove) {
        print('openChat remove msg:$msg');
        refFdb.child('openChat/${couple.cid}/${couple.cid}-${msg['time']}').remove();
      }
    }
  }
}