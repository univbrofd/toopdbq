import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/event/VwEvent.dart';
import 'package:toopdbq/main.dart';
import 'package:toopdbq/swichat/VwSwichat.dart';
import 'FbMain.dart';
import 'VwLoad.dart';
import 'VwNetworkError.dart';
import 'card/Card.dart';
import 'card/FbCard.dart';
import 'card/VwMatch.dart';
import 'chat/VwChat.dart';
import 'common/user.dart';
import 'login/VwLogin.dart';
import 'my/StMy.dart';
import 'my/VwMy.dart';

class VwHome extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  //late ValueNotifier<List<String>?> listCardUidInit;
  //late ValueNotifier<List<StackedCard>?> listCardInit;
  late ValueNotifier<DateTime> timeCardInit;
  late ValueNotifier<bool> blockApp;
  late ValueNotifier<bool> blockLoad;
  late ValueNotifier<bool> blockGetMessage;

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    UserMt? userMy = ref.watch(pvUserMy);
    //listCardUidInit = useState(null);
    //listCardInit = useState(null);
    timeCardInit = useState(DateTime.now());
    blockApp = useState(true);
    blockLoad = useState(false);
    load();

    useEffect((){
      listenMsgMain(ref);
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (result != ConnectivityResult.mobile && result != ConnectivityResult.wifi && result != ConnectivityResult.none) {
          print('onConnectivityChanged.listen : $result');
          Navigator.of(context).pushNamed('/vwNetworkError');
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => VwNetworkError(),
            //以下を追加
            fullscreenDialog: true,
          ));
        }
      });
    },const []);

    return blockApp.value ? VwLoad() : (userMy == null ? VwLogin() :
      DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: null,
          bottomNavigationBar: menu(),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              VwSwichat(),
              VwEvent(),
              VwMy(),
              //VwChat(),//VwTimeline(key: const PageStorageKey(2)),
              //VwFriend(),
              // Container(child: listCardInit.value == null ? const Center() : VwCard(
              //     dateLogInit :timeCardInit.value,
              //     listCardInit : listCardInit.value!,
              //     listUidInit : listCardUidInit.value!
              // )),
            ],
          ),
        ),
      )
    );
  }

  Future<void> load() async{
    print('vwHome load blockApp:${blockApp.value}, blockLoad:${blockLoad.value}');
    if(!blockApp.value||blockLoad.value)return;
    blockLoad.value = true;
    if(await App.checkNetwork(context)){
      try{
        await getUserUidToken();
        //await initVwCard();
        await VwSwichat.init(ref);
        //VwEvent.getEvent(ref: ref,listTag: []);
        //FbFriend.getMatch();
        ready();
        blockLoad.value = false;
      }catch(e){
        print(e);
      }
    }
  }

  Future<void> getUserUidToken() async{
    print('getUserUidToken');
    final user = auth.currentUser;
    try{
      UserMt.tokenMy = await messaging.getToken();
      VwMy.init(ref, user);
      print('🐯 FCM TOKEN: ${UserMt.tokenMy}');
      String? tokenOld = await UserMt.getToken();
      if(tokenOld == null || UserMt.tokenMy != tokenOld) UserMt.setToken();
    }catch(e){
      print(e);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      print('token refresh: $fcmToken');
      if(user != null) {
        UserMt.setToken();
      }
    }).onError((err) {
      print(err);
    });
  }

  void ready(){
    if(
    !blockApp.value ||
        UserMt.mid == null ||
        UserMt.tokenMy == null
    )return;
    blockApp.value = false;
  }

  // Future<void> initVwCard() async{
  //   if(listCardInit.value != null && listCardUidInit.value != null)return;
  //   List resultGetUid = await getListCardUid();
  //   List<String> listCardUidM = [... resultGetUid[0]];
  //   List result = await getListCard(listCardUidM);
  //
  //   timeCardInit.value = resultGetUid[1];
  //   listCardUidInit.value = result[1];
  //   listCardInit.value = result[0];
  //   ready();
  // }

  Future<List> getListCardUid() async {
    DateTime time = DateTime.now();
    while(DateTime (2022, 7).compareTo(time) <= 0){
      List? result =  await FbCard.getUser(time);
      time = DateTime(time.year,time.month - 1,time.day);
      if(result != null) {
        timeCardInit.value = result[1];
        return [result[0],time];
      }
    }
    timeCardInit.value = time;
    return [[],time];
  }

  Future<List> getListCard(List<String> listUidM) async {
    print('home getListCard numList:${listUidM.length}');
    List<String> listUid = listUidM;
    List<StackedCard> listCard = [];
    while(listCard.length < 5 && listUid.isNotEmpty){
      String uid = listUid.first;
      listUid.removeAt(0);
      UserMt user = UserMt(uid);
      await user.getData();
      user.getImgPoster();
      StackedCard? card = StackedCard.create(user);
      if(card != null) listCard.add(card);
    }
    print('end getListCard numList:${listUid.length}');
    return [listCard,listUid];
  }

  Widget wdIconNone(){
    return const CircleAvatar(
      radius: 24,
      backgroundColor: Color(0xff94d500),
      child: Icon(
        Icons.person,
        color: Colors.black,
      ),
    );
  }

  Future<void> listenMsgMain(WidgetRef ref) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('getMessage at LnMessage');
      final Map data = message.data;
      String? category = data['category'];
      print('receive message data: $data');
      switch (category) {
        case 'chat':
          await VwChat.getChat(ref);
          break;
        case 'match':
          VwMatch.getMatch(ref);
          break;
        case 'swichat':
          VwSwichat.listenMsg(ref,data);
          break;
        default:
          break;
      }
    });
  }

  Future<void> navMatch(String uid) async{
    UserMt user = await UserMt(uid).getData();
    StackedCard? card = StackedCard.create(user);
    if(card == null){
      blockGetMessage.value = false;
      return;
    }else {
      await card.getImgPoster();
      Navigator.of(context).pushNamed(
          '/vwMatch', arguments: AgMatch([], [card]))
          .then((result) {
        blockGetMessage.value = false;
      });
    }
  }

  Widget menu(){
    UserMt? userMy = ref.watch(pvUserMy);
    return Container(
      color: Colors.white,
      height: 80,
      padding: EdgeInsets.only(bottom: 10),
      child: const TabBar(
        labelColor: colorMain,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.transparent,
        tabs: [
          const Tab(
            icon: Icon(Icons.people_alt),
          ),
          const Tab(
            icon: Icon(Icons.public),
          ),
          const Tab(
            icon: Icon(Icons.account_box),
          ),
        ],
      ),
    );
  }
}
