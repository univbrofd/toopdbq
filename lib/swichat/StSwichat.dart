import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/user.dart';

class StSwichatUserActive extends StateNotifier<UserMt?>{
  StSwichatUserActive():super(null);

  void set(UserMt user){
    print('st swichatUserActive set user:$user');
    state = user;
  }

  void remove(){
    print('st swichatUserActive set remove:$remove');
    state = null;
  }
}

class StSwichatMapUser extends StateNotifier<Map<String,Map>>{
  StSwichatMapUser():super({});

  void set(Map<String,Map> map){
    print('st swichatMapUser set map:$map');
    state = map;
  }
}

class StSwichatListMsg extends StateNotifier<List<Map>>{
  StSwichatListMsg():super([]);

  void set(List<Map> list){
    print('st swichatListMsg set numList:${list.length}');
    state = list;
  }

  void addListNew(List<Map> list){
    print('st swicathListMsg addListNew numList:${list.length}');
    state = [...list,...state];
  }

  void addListOld(List<Map> list){
    print('st swicathListMsg addListOld numList:${list.length}');
    state = [...list,...state,];
  }
}

class StSwichatBlock extends StateNotifier<bool>{
  StSwichatBlock():super(true);

  void set(bool bol){
    print('st swichatBlock set bool:$bol}');
    state = bol;
  }
}

class StSwichatUserInvite extends StateNotifier<UserMt?>{
  StSwichatUserInvite():super(null);

  void set(UserMt? user){
    print('st swichatUserInvite set user:$user');
    state = user;
  }
}

class StSwichatPoster extends StateNotifier<NetworkImage?>{
  StSwichatPoster():super(null);

  void set(NetworkImage? img){
    print('st swichatPoster set ');
    state = img;
  }
}

final pvSwichatMapUser = StateNotifierProvider<StSwichatMapUser,Map<String,Map>>((ref) => StSwichatMapUser());
final pvSwichatUserActive = StateNotifierProvider<StSwichatUserActive,UserMt?>((ref) => StSwichatUserActive());
final pvSwichatListMsg = StateNotifierProvider<StSwichatListMsg,List<Map>>((ref) => StSwichatListMsg());
final pvSwichatBlock = StateNotifierProvider<StSwichatBlock,bool>((ref) => StSwichatBlock());
final pvSwichatUidInvite = StateNotifierProvider<StSwichatUserInvite,UserMt?>((ref) => StSwichatUserInvite());
final pvSwichatPoster = StateNotifierProvider<StSwichatPoster,NetworkImage?>((ref) => StSwichatPoster());