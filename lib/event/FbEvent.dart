import 'package:firebase_auth/firebase_auth.dart';
import 'package:toopdbq/FbMain.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';

class FbEvent{
  static Future<List<Map>> getListEvent({required DateTime time,required List<String> listTag}) async{
    String strTimeTop = time.toFormString();
    final snap = await refFdb.child('event_list/${time.year}').orderByChild('time').startAt(strTimeTop).limitToLast(20).get();
    List<Map> listEvent = [];
    if(snap.exists) {
      Map data = snap.value as Map;
      List<String> listEid = List<String>.from(data.keys).reversed.toList();
      for (String eid in listEid) {
        if(eid == UserMt.mid)continue;
        if(listTag.isNotEmpty){
          List<String> list = data[eid]['listTag'] ?? [];
          list = [...list,...listTag] ;
          Set<String> set = list.toSet();
          if(list.length == set.length)continue;
        }
        Map? event = await getEvent(eid);
        if (event != null) listEvent.add(event);
      }
    }
    print('fb event getListEvent numList:${listEvent.length}');
    return listEvent;
  }

  static Future<Map?> getEvent(String eid) async{
    final snap = await refFdb.child('event/$eid').get();
    Map? map = snap.value as Map?;
    print('fb getEvent eid:$eid, numEvent:${map?.length}');
    return map;
  }

  static Future<Map?> getEventMy({Function(Map)? func}) async{
    if(UserMt.mid == null) return null;
    final snap = await refFdb.child('event/${UserMt.mid}').get();
    Map? event = snap.value as Map?;
    if(event != null && func != null) func(event);
    print('fb getEventMy $event');
    return event;
  }
  
  static Future<Map> setEvent({
    required String title,
    required int numMax,
    required DateTime time,
    required String place,
    required List<String> listTag,
    required String comment,
  }) async{
    String strTime = time.toFormString();
    Map event = {
      'comment':comment,
      'tokenHost':UserMt.tokenMy,
      'host':UserMt.mid ?? '',
      'listTag':listTag,
      'member':[UserMt.mid],
      'numMax':numMax,
      'place':place,
      'time':strTime,
      'title':title,
      'urlIcon':UserMt.urlIconMy,
    };
    refFdb.child('event/${UserMt.mid}').set(event);
    refFdb.child('event_list/${time.year}/${UserMt.mid}').set({
      'eid':UserMt.mid,
      'time':strTime,
      'listTag':listTag
    });
    print('fb event setEvent $event');
    return event;
  }

  static void onLike(String eid,String tokenHost){
    String strTime = DateTime.now().toFormString();
    refFdb.child('event/$eid/listLike/${UserMt.mid}').set({
      'uid':UserMt.mid,
      'time':strTime,
      'tokenHost':tokenHost
    });
    print('fb event onLike');
  }

  static Future<List<String>> getListLike(String eid) async{
    final snap = await refFdb.child('event/$eid/listLike').get();
    if(snap.exists){
      final data = snap.value as Map;
      print(data.values);
      final list = data.values.toList();
      list.sort((a,b){
        return a['time']!.compareTo(b['time']!);
      });
      List<String> listUid = List<String>.from(list.map((e){return e['uid'] ?? '';}));
      print('fb event getListLike listNum${listUid.length}');
      return listUid;
    }else{
      print('fb event getListLieke nodata');
      return [];
    }
  }
}