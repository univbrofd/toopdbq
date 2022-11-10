import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toopdbq/common/ExDatetime.dart';

import '../FbMain.dart';
import '../common/user.dart';

class FbMy{
  static Future<Map?> getSubData(String mid) async{
    final snapshot = await refFdb.child('user/$mid').get();
    if (snapshot.exists) {
      print('fb my getSubData user:${snapshot.value}');
      return snapshot.value as Map;
    }else{
      print('fb my getSubData null');
      return null;
    }
  }

  static Future<void> setImage(File file,String uid,EmUser emUser,Function(String) callback) async {
    String key = strEmUser(emUser);
    final ref = refRsr.child('$key/$uid/$key.jpg');
    try {
      final uploadTask = ref.putFile(file);
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async{
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress =
                100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            print("fb my setImage Upload is $progress% complete.");
            break;
          case TaskState.paused:
            print("fb my setImage Upload is paused.");
            break;
          case TaskState.canceled:
            print("fb my setImage Upload was canceled");
            break;
          case TaskState.error:
            print("fb my setImage Upload was failed");
          // Handle unsuccessful uploads
            break;
          case TaskState.success:
            String url = await ref.getDownloadURL();
            print("fb my setImage Upload was success url:$url");
            callback(url);
            break;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> setData(dynamic data,String uid,String key) async {
    switch(key){
      case 'name':
        print('fb my auth name update data:$data');
        auth.currentUser?.updateDisplayName(data);
        break;
      case'urlIcon':
        print('fb my auth urlIcon update data:$data');
        auth.currentUser?.updatePhotoURL(data);
        break;
    }
    print('fb my auth set $key:$data');
    await refFdb.child('user/$uid/$key').set(data);
  }

  static Future<void> setLog({String? uidM}) async{

    String ym = DateTime.now().toFormStringYM();
    print('fb my setLog　uid:$uidM');
    refFdb.child('card/$ym/${uidM ?? UserMt.mid}').set({
      'uid':uidM ?? UserMt.mid,
      'time':DateTime.now().toFormString()
    });
  }

  static Future<bool> delete() async{
    try{
      print('fb my delete');
      await refFdb.child('user/${UserMt.mid}').remove();
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }

}
