import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toopdbq/card/SqCard.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/couple/FbCouple.dart';
import 'package:toopdbq/friend/SqFriend.dart';
import 'package:toopdbq/swichat/FbSwichat.dart';
import 'package:toopdbq/swichat/SqSwichat.dart';
import 'package:toopdbq/swichat/StSwichat.dart';
import 'package:toopdbq/swichat/VwSwichatMain.dart';
import 'package:toopdbq/swichat/VwSwichatLoad.dart';
import 'package:toopdbq/swichat/VwSwichatTag.dart';
import 'package:toopdbq/couple/couple.dart';

import '../chat/FbChat.dart';
import '../chat/SqChat.dart';
import '../chat/VwChat.dart';
import '../main.dart';
import '../my/StMy.dart';

class VwSwichat extends HookConsumerWidget{
  final text1 = 'スウィッチ チャット';
  final text2 = 'AI が選んだ相手と\nチャットを楽しもう！';
  final text3 = '相手を変えたい時は\nスウィッチできます';
  final focusNode = FocusNode();
  final tid = 'swichat';

  late BuildContext context;
  late WidgetRef ref;
  late TextEditingController myController;
  late TextEditingController conInpTag;
  late StreamSubscription lnMessage;
  ScrollController scrollController = ScrollController();

  late ValueNotifier<List<String>> listTag;
  late ValueNotifier<List> listTagSample;
  late ValueNotifier<Map> mapTagSample;
  late ValueNotifier<bool> scrollEnd;
  late ValueNotifier<bool> loadMsgStop;
  late ValueNotifier<bool> blockGetMessage;
  late ValueNotifier<DateTime?> timeMath;

  late ValueNotifier<int?>  aniValNumTimeYear;
  late ValueNotifier<int?>  aniValNumTimeDay;
  late ValueNotifier<int?>  aniValNumLen;
  late ValueNotifier<int?>  aniValNumText;

  late Map talk;

  static Timer? timerSwichat;

  VwSwichat() {
    VwSwichatAsync();
  }

  VwSwichatAsync() async{
    await SqTalk.create(tid);
    List<Map> list = await SqChat.select(tid);
    if (list.isEmpty){
      talk = {
        "tid":tid,
        'nameTalk':'Switch Chat',
        'time':DateTime.now().toFormString(),
        'text':'',
        'urlIcon':'',
      };
    }else{
      talk = list.first;
    }
  }

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    UserMt? user = ref.watch(pvSwichatUserActive);
    bool block = ref.watch(pvSwichatBlock);
    listTag = useState([]);
    listTagSample = useState([]);
    mapTagSample = useState({});
    scrollEnd = useState(false);
    loadMsgStop = useState(false);
    blockGetMessage = useState(false);
    myController = useTextEditingController();
    conInpTag = useTextEditingController();
    timeMath = useState(null);

    aniValNumTimeYear = useState(null);
    aniValNumTimeDay = useState(null);
    aniValNumLen = useState(null);
    aniValNumText = useState(null);

    useEffect((){
      getTag();
      resume(ref);
      getTimeMatch();
    },[]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: wdBody(),
    );
  }

  void getTag() async{
    listTag.value = await SqSwichat.getTag();
  }

  static init(WidgetRef ref) async{
    print('swichat init');
    SqTalk.selectNew('swichat', null, (List<Map> list){
      ref.read(pvSwichatListMsg.notifier).set(list);
    });

    final prefs = await SharedPreferences.getInstance();
    bool bol = prefs.getBool('blockSwichat') ?? true;
    //getPartner(ref);
    if(bol){
      ref.read(pvSwichatBlock.notifier).set(bol);
      return;
    }
  }

  static listenMsg(WidgetRef ref,Map data){
    String? action = data['action'];
    if(action == 'match'){
      String? uid = data['uid'];
      if(uid == null)return;
      match(ref, uid);
    }else if(action == 'switch'){
      switchUser(ref);
    }
  }

  static setMsg(WidgetRef ref,List<Map> list){
    UserMt? user = ref.watch(pvSwichatUserActive);
    if(user == null)return;
    List<Map> listMsgSwichat = list;
    listMsgSwichat.removeWhere((element) => element['tid'] != 'swichat' || element['uid'] != user!.uid);
    if(listMsgSwichat.isNotEmpty)ref.read(pvSwichatListMsg.notifier).addListNew(listMsgSwichat);

  }

  static invite(WidgetRef ref,String uid, String token){
    bool block = ref.watch(pvSwichatBlock);
    UserMt? user = ref.watch(pvSwichatUserActive);
    if(block) return;
    if(user != null)return;
    getPartner(ref);
  }

  static match(WidgetRef ref,String uid){
    bool block = ref.watch(pvSwichatBlock);
    if(block){
      removeUser(ref);
    }else {
      setTimeMatch();
      timerSwichat?.cancel();
      FbSwichat.deleteLog();
      setUser(ref: ref, uid: uid);
    }
  }

  getTimeMatch() async{
    final prefs = await SharedPreferences.getInstance();
    String? strTime = prefs.getString('matchTime');
    strTime ??= await FbSwichat.getTimeMatch();
    if(strTime == null){
      DateTime time = DateTimeExtension.fromString(strTime!);
      timeMath.value = time;
    }else{
      timeMath.value = DateTime.now();
    }
  }

  static setTimeMatch() async{
    String? strTime = await FbSwichat.getTimeMatch();
    strTime ??= DateTime.now().toFormString();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('matchTime',strTime);
    print('setTimeMatch $strTime');
  }

  static inactive(WidgetRef ref){
    timerSwichat?.cancel();
  }

  static switchUser(WidgetRef ref) async{
    setBlock(ref, false);
    removeUser(ref);
    resume(ref);
  }

  static setBlock(WidgetRef ref, bool bol) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('swichatBlock', bol);
    ref.read(pvSwichatBlock.notifier).set(bol);
  }

  static removeUser(WidgetRef ref){
    final user = ref.watch(pvSwichatUserActive);
    FbSwichat.switchUser(uid: user?.uid);
    ref.read(pvSwichatUserActive.notifier).remove();
    ref.read(pvSwichatListMsg.notifier).set([]);
    ref.read(pvSwichatPoster.notifier).set(null);
    SqChat.delete('swichat');
  }

  static Future<bool> getPartner(WidgetRef ref) async{
    print('getPartner');
    Map? dataMatch = await FbSwichat.getMatch();
    String? uidPartner = dataMatch?['uid'];
    if(dataMatch != null && uidPartner != null){
      Map? dataMatchOfPartner = await FbSwichat.getMatch(uid: uidPartner);
      if(UserMt.mid != dataMatchOfPartner?['uid']){
        FbSwichat.switchUser();
      }else{
        setUser(ref:ref,uid: uidPartner);
        return true;
      }
    }
    return false;
  }

  static Future<bool> existsFriend(WidgetRef ref) async{
    UserMt? user = ref.watch(pvSwichatUserActive);
    String? uid;
    if(user == null){
      Map? map = await FbSwichat.getMatch();
      if(map?['uid'] != null){
        uid = map!['uid']!;
      }
    }else{
      uid = user.uid;
    }
    if(uid != null){
      final friend = await SqFriend.selectOne(uid);
      if(friend != null){
        return true;
      }
    }
    return false;
  }

  static setUser({required WidgetRef ref,required String uid}) async{
    print('setUser');
    setBlock(ref, true);
    if(UserMt.mid != null)setCouple(ref, uid);
    UserMt user = UserMt(uid);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('partner', uid);
    user.getData(callback: (UserMt userM) async{
      user.getImgPoster();
      ref.read(pvSwichatPoster.notifier).set(userM.imgPoster);
      ref.read(pvSwichatUserActive.notifier).set(userM);
      user.getImg();
    });
  }

  static setCouple(WidgetRef ref,String uid) async{
    print('vwSwichat setCouple');
    String cid = Couple.getCid(UserMt.mid!, uid);
    Couple couple = Couple(cid);
    await couple.getData();
    if (couple.userM == null || couple.userF == null){
      UserMt? userMy = ref.watch(pvUserMy);
      UserMt partner = UserMt(uid);
      await partner.getData();
      if(userMy?.sex == 0){
        couple.userM = userMy;
        couple.userF = partner;
      }else{
        couple.userF = userMy;
        couple.userM = partner;
      }
      couple.timeMatch = DateTime.now();
      FbCouple.setInit(couple);
    }
    ref.read(pvCoupleMy.notifier).set(couple);
  }

  // static Future<UserMt?> getLog(WidgetRef ref) async{
  //   List<Map> listLog = ref.watch(pvSwichatLog);
  //   DateTime? timeTop;
  //   try{
  //     timeTop = DateTimeExtension.fromString(listLog.first['time']);
  //   }catch(e){}
  //
  //
  //   if(listLogM.isNotEmpty) ref.read(pvSwichatLog.notifier).add(listLogM!);
  // }

  _onStart() async{
    print('swichat onStart');
    UserMt? userMy = ref.watch(pvUserMy);
    if(userMy == null || userMy.name == null){
      await Navigator.of(context).pushNamed('/editProfile',arguments: userMy);
    }
    await setBlock(ref, false);
    resume(ref);
  }

  static resume(WidgetRef ref) async{
    bool blockSwichat = ref.watch(pvSwichatBlock);
    UserMt? userMy = ref.watch(pvUserMy);

    print('swichat resume block:$blockSwichat, userMy:${userMy?.name}');

    //await checkStatus(ref);

    if(!await getPartner(ref) && !blockSwichat && userMy != null){
      FbSwichat.setLog(userMy);
      List listLog = await FbSwichat.getLog();
      if(listLog.isEmpty) return;
      Map? mapUser =  await gradeUser(ref, listLog);
      if(mapUser == null) return;
      await selectUser(ref, mapUser);
    }
  }

  static Future<bool?> checkStatus(WidgetRef ref) async{
    if(await existsFriend(ref)) return true;
  }

  static Future<Map?> gradeUser(WidgetRef ref,List listLog) async{
    UserMt? userMy = ref.watch(pvUserMy);
    if(userMy == null) return null;

    Map<String,Map> mapUser = ref.watch(pvSwichatMapUser);
    List<String> listChecked = mapUser.keys.toList();
    List<String> listTagMy = await SqSwichat.getTag();
    List listMetUser = await SqMetUser.getMetUser();

    for(Map log in listLog){
      String? uid = log['uid'];
      if(uid == null || uid == UserMt.mid)continue;
      if(listChecked.contains(uid))continue;
      if(blockSex(log, userMy)){
        mapUser[uid] = {'token':log['token']};
        continue;
      }
      if(blockLive(log, userMy)){
        mapUser[uid] = {'token':log['token']};
        continue;
      }
      if(blockAge(log, userMy)){
        mapUser[uid] = {'token':log['token']};
        continue;
      }

      List<String> listTag = log['listTag'] as List<String>? ?? [];
      List list = [...listTag,...listTagMy];
      Set set = list.toSet();
      int num = list.length - set.length;
      mapUser[uid] = {
        'grade': num,
        'token':log['token']
      };
    }
    ref.read(pvSwichatMapUser.notifier).set(mapUser);
    return mapUser;
  }

  static selectUser(WidgetRef ref,Map mapUser) async{
    List listUid = mapUser.keys.toList();
    listUid.sort((a,b) {
      if(mapUser[a]?['grade'] == null){
        return 1;
      }else if(mapUser[b]?['grade'] == null){
        return 0;
      }else{
        return (mapUser[a]!['grade']!.compareTo(mapUser[b]!['grade']!));
      }
    });

    if(listUid.isEmpty)return;
    String uid = listUid[0];
    FbSwichat.invite(uid,mapUser[uid]?['token']);

    int index = 1;
    Timer.periodic(
        Duration(seconds: 60),
        (timer) {
          bool block = ref.read(pvSwichatBlock);
          if(block || index == listUid.length) {
            timer.cancel();
            return;
          }else{
            String uid = listUid[index];
            FbSwichat.invite(uid,mapUser[uid]?['token']);
          }
          index++;
        }
    );
  }

  void sendMsg(String? uid) {
    if(uid == null)return;
    String text = myController.text;
    if(text.isEmpty){return;}
    FbChat.sendMsg(uidReceiver: uid, text: text, tid: tid, nameTalk: 'Switch Chat', callback: (Map msg){
      //player.load('audio/sound_chat.mp3');
      ref.read(pvSwichatListMsg.notifier).addListNew([msg]);
      ref.read(pvChat.notifier).addTalk(msg);
    });
    myController.clear();
  }

  static bool blockSex(Map value,UserMt userMy){
    int? sex;
    int? sexTarget;

    if(userMy.sex == 0){
      if(userMy.sexTarget == 1){
        sex = 1;
        sexTarget = 0;
      }else if(userMy.sexTarget == 0){
        sex = 0;
        sexTarget = 0;
      }
    }else if(userMy.sex == 1) {
      if(userMy.sexTarget == 0){
        sex = 0;
        sexTarget = 1;
      }else if(userMy.sexTarget == 1){
        sex = 1;
        sexTarget = 1;
      }
    }

    if(value['sex'] == sex && value['sexTarget'] == sexTarget) {
      return false;
    }else{
      return true;
    }
  }

  static bool blockAge(Map value,UserMt userMy){
    int? age = userMy.age;
    int? ageTargetTop = userMy.ageTargetTop;
    int? ageTargetBtm = userMy.ageTargetBtm;

    int? ageM = value['age'];
    int? ageTargetTopM = value['ageTargetTop'];
    int? ageTargetBtmM = value['ageTargetBtm'];

    if(age != null && ageM != null) {
      if(ageTargetTop != null && ageTargetTop < ageM) return true;
      if(ageTargetBtm != null && ageTargetBtm > ageM) return true;

      if(ageTargetTopM != null && ageTargetTopM < age) return true;
      if(ageTargetBtmM != null && ageTargetBtmM > age) return true;
      return false;
    }else if(age == null && ageM == null) {
      return false;
    }else{
      return true;
    }
  }

  static bool blockLive(Map value,UserMt userMy){
    String? live1 = userMy.live1;
    if(live1 != value['live1']) {
      return true;
    }else{
      return false;
    }
  }
}

extension Layout on VwSwichat{
  Widget wdBody(){
    bool blockChat = ref.watch(pvSwichatBlock);
    UserMt? user = ref.watch(pvSwichatUserActive);

    return Container(
      child: Stack(
        children: [
          user?.imgPoster == null ? Image.asset(
            'images/back_swichat.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ) : Image(
            image: user!.imgPoster!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Opacity(
            opacity: user == null ? 0.48 : 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: gradientMain
              )
            )
          ),
          SafeArea(
            top: false,
            child: user != null ? wdMain() :
              blockChat ? wdExplain() : wdLoad()
          )
        ],
      ),
    );
  }

  Widget wdExplain(){
    return SafeArea(child:Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            'Switch Chat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900
            ),
          ),
          SizedBox(height: 4,),
          Text(
            text1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(
              text2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          Spacer(),
          wdBtnStart(),
          Spacer(),
          wdTag(),
        ],
      ),
    ));
  }

  Widget wdBtnStart(){
    return Container(
      width: 240,
      child:FloatingActionButton.extended(
        heroTag:'swichat btn start',
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        backgroundColor: colorMain,
          onPressed: _onStart,
          label: Text(
              'はじめる',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900
            ),
          ),
        icon: Icon(Icons.stream),
      ),
    );
  }
}