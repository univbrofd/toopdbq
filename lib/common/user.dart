import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/my/FbMy.dart';

import '../FbMain.dart';
import '../main.dart';

enum EmUser{
  name,
  urlIcon,
  urlPoster,
  profile,
}

String strEmUser(EmUser em){
  switch(em){
    case EmUser.name:
      return'name';
      break;
    case EmUser.urlIcon:
      return 'urlIcon';
      break;
    case EmUser.urlPoster:
      return 'urlPoster';
      break;
    case EmUser.profile:
      return 'profile';
      break;
  }
}

class UserMt{
  static String? mid;
  static String? tokenMy;
  static String? nameMy;
  static String? urlIconMy;
  String? uid;
  String? name;
  String? urlIcon;
  String? profile;
  String? urlPoster;
  String? token;
  String? timeMatch;
  User? user;
  NetworkImage? imgPoster;
  NetworkImage? imgIcon;

  int? sex; //m:0 f:1
  int? sexTarget;//m:0 f:1
  String? birthday;
  int? age;
  int? ageTargetTop;
  int? ageTargetBtm;
  String? live1;
  String? live2;
  String? live3;

  UserMt._createMy(User this.user){
    print('Muser:${user?.uid}');
    uid = user?.uid;
    name = user?.displayName;
    urlIcon = user?.photoURL;
  }

  UserMt(this.uid);

  static Future<UserMt> createMy(User user) async{
    UserMt userMt = UserMt._createMy(user);
    await userMt.getData(callback: (UserMt user){
      if(user.name != null &&
          user.urlIcon != null &&
          user.profile != null &&
          user.urlPoster != null)FbMy.setLog(uidM: user.uid);
    });
    if(userMt.token == null){
      userMt.token = UserMt.tokenMy;
      setToken();
    }
    return userMt;
  }

  static Future<String?> getToken() async{
    final snap = await refFdb.child('user/${UserMt.mid}/token').get();
    if (snap.exists) {
      return snap.value as String?;
    }else{
      return null;
    }
  }

  static setToken(){
    refFdb.child('user/${UserMt.mid}/token').set(UserMt.tokenMy);
  }

  Future<void> setData() async{
    Map data = {};
    if(uid != null)data['uid'] = uid;
    if(name != null)data['name'] = name;
    if(urlIcon != null)data['urlIcon'] = urlIcon;
    if(urlPoster != null)data['urlPoster'] = urlPoster;
    if(profile != null)data['profile'] = profile;
    if(token != null)data['token'] = tokenMy;
    if(timeMatch != null)data['timeMatch'] = timeMatch;
    if(birthday != null)data['birthday'] = birthday;
    if(sex != null)data['sex'] = sex;
    if(sexTarget != null)data['sexTarget'] = sexTarget;
    if(live1 != null)data['live1'] = live1;
    if(live2 != null)data['live2'] = live2;
    if(live3 != null)data['live3'] = live3;
    print('setData data:${data}');

    refFdb.child('user/$uid').set(data);
    if(uid != UserMt.mid)FbMy.setLog(uidM: uid);
  }

  Future<UserMt> getData({void Function(UserMt)? callback}) async{
    final snapshot = await refFdb.child('user/$uid').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      uid ??= data['uid'];
      name = data['name'];
      urlIcon = data['urlIcon'];
      urlPoster = data['urlPoster'];
      profile = data['profile'];
      token = data['token'];
      timeMatch = data['timeMatch'];
      birthday = data['birthday'];
      sex = data['sex'];
      sexTarget = data['sexTarget'];
      ageTargetTop = data['ageTargetTop'];
      ageTargetBtm = data['ageTargetBtm'];
      live1 = data['live1'];
      live2 = data['live2'];
      live3 = data['live3'];
      
      if(birthday != null){
        DateTime time = DateTimeExtension.fromString(birthday!);
        age = time.getAge();
      }

      print('UserMt getData uid:$uid');

      if(uid != null) UserMt.mapUser[uid!] = this;
      if(callback != null) {
        callback(this);
      }
    } else {
      print('UserMt getData No data available.');
    }
    return this;
  }

  Future<void> linkWithCredential(AuthCredential credential) async{
    await user?.linkWithCredential(credential);
  }

  bool isAnonymous(){
    return user?.isAnonymous ?? false;
  }

  void getImgPoster() {
    if(urlPoster != null) imgPoster = NetworkImage(urlPoster!);
  }

  void getImg(){
    if(urlIcon != null) imgIcon = NetworkImage(urlIcon!);
    if(urlPoster != null) imgPoster = NetworkImage(urlPoster!);
  }

  static Map<String,UserMt> mapUser = {};

  Map getMapForCouple(){
    return {
      'uid' : uid,
      'name' : name,
      'urlIcon' : urlIcon,
      'profile' : profile,
      'urlPoster' : urlPoster,
      'token' : token,
      'sex' : sex,
      'birthday' : birthday,
      'age' : age,
      'live1' : live1,
      'live2' : live2,
      'live3' : live3,
    };
  }
}

Widget glWdIcon(NetworkImage? img, double size){
  return img == null
      ? Container(
          width: size,
          height: size,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: colorMain,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: size * 0.5,
            ),
          )
      )
      : SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Image(
              image: img,
            fit: BoxFit.cover,
          ),
        )
  );
}

Widget glWdIconUser(String? url,double size){
  try{
    return(SizedBox(
      height: size,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Image.network(
            url!,
            fit: BoxFit.cover,
          )
      ))
    );
  }catch(e){
    return(
        Container(
          width: size,
          height: size,
          child: CircleAvatar(
              radius: 24,
              backgroundColor: colorMain,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: size * 0.5,
              ),
          )
        )
    );
  }
}
