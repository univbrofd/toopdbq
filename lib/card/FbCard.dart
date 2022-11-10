import 'package:toopdbq/common/ExDatetime.dart';

import '../FbMain.dart';
import '../common/user.dart';
import 'SqCard.dart';

class FbCard{
  static Future<List?> getUser(DateTime timeM) async{
    var time = timeM;
    String strTime = time.toFormStringYM();
    time = DateTime(time.year,time.month - 1,time.day);

    try{
      final snapshot = await refFdb.child('card/$strTime').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        List listMapRem = await SqMetUser.getMetUser();
        List listUidRem = listMapRem.map((e) => e['uid'] as String).toList();
        if(UserMt.mid != null)listUidRem.add(UserMt.mid);
        List list = data.keys.toSet().difference(listUidRem.toSet()).toList();

        print('Fb Card getUser numList:${list.length}');
        return [list,timeM];
      }
    }catch(e){
      print(e);
    }
    print('Fb Card getUser null');
    return null;
  }

  static void like(String uid){
    print('fb card onlike $uid');
    refFdb.child('like/$uid/${UserMt.mid}').set(UserMt.tokenMy);
  }
}

