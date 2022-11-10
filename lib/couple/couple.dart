import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/couple/FbCouple.dart';

class Couple{
  Couple(this.cid);
  Couple.fromUser({
      required UserMt this.userM,
      required UserMt this.userF,
      this.timeMatch,
      this.numSentence,
  }) : cid = getCid(userM.uid! ,userF.uid!),
    name = '${userF.name} × ${userM.name}';

  static getCid(String uidM,String uidF){
    final list = [uidM,uidF];
    list.sort();
    return '${list[0].substring(0,14)}${list[1].substring(0,14)}';
  }

  String cid;
  String? urlIcon;
  UserMt? userM;
  UserMt? userF;
  bool openM = false;
  bool openF = false;
  String? urlImage;
  String? name;
  DateTime? timeMatch;
  int? numSentence;
  List<Map> listMsg = [];
  List<Map> listMsgUpload = [];
  List<Map> listMsgRemove = [];

  Future<Couple> getData({Function(Couple)? callback}) async{
    final map = await FbCouple.get(cid);
    if(map != null){
      userM = UserMt(map['uidM']);
      userF = UserMt(map['uidF']);

      await Future.wait([
        userM!.getData(),
        userF!.getData()
      ]);

      name = map['name'];
      openF = map['openF'] ?? false;
      openM = map['openM'] ?? false;
      timeMatch = DateTimeExtension.fromString(map['timeMatch']);
      urlIcon = map['urlIcon'];
      urlImage = map['urlImage'];
    }
    return this;
    if(callback != null) callback(this);
  }

  void fixSex(){
    UserMt? userMC = userM;
    UserMt? userFC = userF;
    bool openMC = openM;
    bool openFC = openF;

    if(userM?.sex == 1 || userF?.sex == 0){
      userM = userFC;
      userF = userMC;
      openM = openFC;
      openF = openMC;
    }
  }

  void sortMsgUpload(){
    listMsg.removeWhere((element){
      print(element['upload']);
      print(listMsgUpload);
      print(listMsgRemove);
      if(listMsgUpload.contains(element)) return false;
      if(listMsgRemove.contains(element)) return true;
      if(element['upload'] == null || element['upload'] == false) return true;
      return false;
    });
  }

  Map getMap(){
    Map map = {
      'cid' : cid,
      'urlIcon' : urlIcon,
      'uidM' : userM?.uid,
      'uidF' : userF?.uid,
      'openM' : openM,
      'openF' : openF,
      'urlImage' : urlImage,
      'name' : name,
      'timeMatch' : timeMatch?.toFormString(),
    };
    return map;
  }
}