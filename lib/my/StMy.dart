import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/couple/couple.dart';

import '../common/user.dart';

class StCoupleMy extends StateNotifier<Couple?>{
  StCoupleMy():super(null);

  set(Couple couple){
    state = couple;
  }
}

class UserMyNotifier extends StateNotifier<UserMt?>{
  UserMyNotifier(): super(null);

  set(UserMt userMt){
    state = userMt;
  }

  Future<void> setUser(User user) async{
    UserMt userMt = await UserMt.createMy(user);
    userMt.getImg();
    UserMt.mid = user.uid;
    state = userMt;
  }

  Future<void> linkWithCredential(AuthCredential credential) async{
    await state?.linkWithCredential(credential);
  }

  void setData(){
    state?.setData();
  }

  void logout(){
    state = null;
  }
}

class StMyrReload extends StateNotifier<bool>{
  StMyrReload():super(false);
  void toggle(){
    if(state){
      state = false;
    }else{
      state = true;
    }
  }
}

final pvUserMy = StateNotifierProvider<UserMyNotifier,UserMt?>((ref){
  return UserMyNotifier();
});

final pvMyReload = StateNotifierProvider<StMyrReload,bool>((ref){
  return StMyrReload();
});

final pvCoupleMy = StateNotifierProvider<StCoupleMy,Couple?>((ref){
  return StCoupleMy();
});