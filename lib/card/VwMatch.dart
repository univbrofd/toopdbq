
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:toopdbq/chat/FbChat.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/friend/SqFriend.dart';

import '../friend/FbFriend.dart';
import '../timeline/VwTimeline.dart';
import '../chat/SqChat.dart';
import '../chat/VwChat.dart';
import '../friend/VwFriend.dart';
import 'Card.dart';

class AgMatch{
  List<String> listUid;
  List<StackedCard> listCard;
  AgMatch(this.listUid,this.listCard);
}

class VwMatch extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  late ValueNotifier<List<StackedCard>> listCard;
  late ValueNotifier<List<String>> listUid;
  late ValueNotifier<int> indexActive;
  late ValueNotifier<bool> cardAdding;
  final ScrollController conList = ScrollController();
  late ValueNotifier<bool> blockMessage;

  @override
  Widget build(BuildContext context,WidgetRef ref){
    AgMatch agMatch = ModalRoute.of(context)?.settings.arguments as AgMatch;
    this.context = context;
    this.ref = ref;
    listUid = useState(agMatch.listUid);
    listCard = useState(agMatch.listCard);
    indexActive = useState(0);
    cardAdding = useState(false);
    blockMessage = useState(false);
    useEffect((){
      //messageListen();
      addCard();
    },const []);

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                _onNextCard();
              }
            },
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: conList,
                scrollDirection: Axis.horizontal,
                itemCount: listCard.value.length,
                itemBuilder: (BuildContext context,int idx){
                  StackedCard card = listCard.value[idx];
                  return Container(
                    child: VwMatchCard(card: listCard.value[idx],onNextCard: _onNextCard),
                  );
                }
            ),
          ),
          wdBtn()
        ],
      )
    );
  }

  // void messageListen(){
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('message Match');
  //     final Map data = message.data;
  //     if(UserMt.mid == null || data['category'] == 'match') return;
  //     getMatch();
  //   });
  // }

  Widget wdBtn(){
    return(Container(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Row(
        children: [
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 40,
              )
          ),
          Spacer(),
          TextButton(
              onPressed: _onNextCard,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 40,
              )
          )
        ],
      ),
    ));
  }

  void _onNextCard(){
    if((indexActive.value + 1) >= listCard.value.length) {
      Navigator.of(context).pop();
      return;
    }
    try {
      SqFriend.updateCheck(listCard.value[indexActive.value + 1].uid);
    }catch(e) {
      print(e);
    }
    indexActive.value = indexActive.value + 1;
    conList.animateTo(
        (conList.offset + MediaQuery.of(context).size.width),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut
    );
  }

  static Future<void> getMatch(WidgetRef ref) async{
    bool blockFriend = ref.watch(pvBlockFriend);
    if(blockFriend || UserMt.mid == null) return;
    ref.read(pvBlockFriend.notifier).set(true);

    List<String> list = await FbFriend.getMatch();
    List<UserMt> listFriendM = [];
    for(String uid in list){
      UserMt user = UserMt(uid);
      user.timeMatch = DateTime.now().toFormString();
      listFriendM.add(user);
    }
    ref.read(pvListFriend.notifier).add(listFriendM);
    ref.read(pvBlockFriend.notifier).set(false);
  }

  Future<void> addCard() async{
    if(cardAdding.value || (listCard.value.length - indexActive.value) > 3||listUid.value.isEmpty)return;
    cardAdding.value = true;
    int numAdd = 0;
    List<StackedCard> listCardC = [];
    List<String> listUidC = listUid.value;
    var i = 0;
    while(listUidC.isNotEmpty && i < 5){
      String uid = listUidC.first;
      listUidC.remove(uid);
      UserMt user = await UserMt(uid).getData();
      StackedCard? card = StackedCard.create(user);
      await card?.getImgPoster();
      if(card != null) {
        listCardC.add(card);
        i++;
      }
    }
    listCard.value = listCardC;
    listUid.value = listUidC;
    cardAdding.value = false;
  }

}

class VwMatchCard extends HookConsumerWidget{
  VwMatchCard({required this.card,required this.onNextCard});
  StackedCard card;
  Function() onNextCard;
  late TextEditingController conInp;
  late BuildContext context;
  late ValueNotifier<TextStyle> style;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    this.context = context;
    style = useState(TextStyle(fontSize: 70));
    conInp = useTextEditingController();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   style.value = TextStyle(fontSize: 70);
    // });

    return Container(
      width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            wdPoster(),
            wdComment(),
            wdInputMsg(),
          ],
      ),
    );
  }

  Widget wdPoster() {
    return (card.imgPoster == null ? Center(): Image(image: card.imgPoster!,
        fit: BoxFit.cover,
      width: double.maxFinite,
      height: double.maxFinite,
      )
    );
  }

  Widget wdComment(){
    return (Container(
      alignment: Alignment.center,
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          const Text(
            "IT'S A",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
         const Text(
           "MATCH!",
           overflow: TextOverflow.clip,
           style: TextStyle(
             fontSize: 60,
             color: Colors.greenAccent,
             fontWeight: FontWeight.w900,
             fontStyle: FontStyle.italic,
           ),
         ),
        ],
      )
    ));
  }

  Widget wdInputMsg() {
    return (Column(
      children:[
        Spacer(),
        Container(
          margin:EdgeInsets.fromLTRB(10, 0, 10, 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: TextField(
                    onTap: (){
                      List<int> list = [];
                      int i = 0;
                      while(i < conInp.text.length){
                        i = conInp.text.indexOf('\n',i);
                        if(i < 0)break;
                        list.add(i);
                        i++;
                      }
                      if(list.contains(conInp.selection.baseOffset + 1)){
                        conInp.selection = TextSelection.fromPosition(TextPosition(offset: conInp.selection.baseOffset + 1));
                      }else if(conInp.selection.baseOffset + 1 == conInp.text.length){
                        conInp.selection = TextSelection.fromPosition(TextPosition(offset: conInp.text.length));
                      }
                    },
                    controller: conInp,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      fillColor: Colors.transparent,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0,
                            color: Color.fromRGBO(0, 0, 0, 0),
                          ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent
                        )
                      ),
                      hintText: 'メッセージ'
                    ),
                  ),
                )
              ),
              Container(
                child: TextButton(
                  onPressed: (() => sendMsg()),
                  child: Text('送信',style: TextStyle(
                    color: Colors.black
                  ),)
                ),
              )
            ]
          ),
        )
      ]
    ));
  }
  void sendMsg() {
    debugPrint('sendMsg');
    primaryFocus?.unfocus();
    String text = conInp.text;
    FbChat.sendMsg(uidReceiver: card.uid, text: text);
    conInp.clear();
    onNextCard();
  }

  Matrix4 _generateFormMatrix(Animation animation) {
    final value = lerpDouble(35.0 , 0, animation.value);
    return Matrix4.translationValues(0.0, -value!, 0.0);
  }
}