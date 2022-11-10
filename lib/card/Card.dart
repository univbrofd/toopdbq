import 'package:flutter/cupertino.dart';
import '../common/user.dart';
import 'FbCard.dart';
import 'SqCard.dart';

enum SlideDirection {
  Left,
  Right,
  Up,
}

class StackedCard extends ChangeNotifier {
  late UserMt user;
  late String uid;
  late String name;
  late String urlIcon;
  late String profile;
  late String urlPoster;
  late String token;
  late SlideDirection direction;
  NetworkImage? imgPoster;

  StackedCard._create(this.user){
    uid = user.uid!;
    name = user.name!;
    urlIcon = user.urlIcon!;
    urlPoster = user.urlPoster!;
    profile = user.profile!;
    token = user.token!;
    imgPoster = user.imgPoster;
  }

  static StackedCard? create(UserMt user){
    try{
      StackedCard card = StackedCard._create(user);
      return card;
    }catch(e){
      return null;
    }
  }

  void slideLeft() {
    direction = SlideDirection.Left;
    notifyListeners();
    SqMetUser.addMetUser(uid);
  }

  void slideRight() {
    direction = SlideDirection.Right;
    notifyListeners();
    SqMetUser.addMetUser(uid);
    if(UserMt.mid != null) {
      FbCard.like(uid);
    }
  }

  void slideUp() {
    direction = SlideDirection.Up;
    notifyListeners();
    SqMetUser.addMetUser(uid);
  }

  Future<void> getImgPoster() async{
    user.getImgPoster();
    imgPoster = user.imgPoster;
    notifyListeners();
  }
}
