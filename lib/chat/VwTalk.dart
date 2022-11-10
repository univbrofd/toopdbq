import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/timeline/VwTimeline.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/friend/FbFriend.dart';
import 'FbChat.dart';
import 'SqChat.dart';
import 'VwChat.dart';

class VwTalk extends HookConsumerWidget {
  late TextEditingController myController;
  bool bolTable = false;
  late ValueNotifier<bool> scrollEnd;
  late ValueNotifier<bool> loadMsgStop;
  late ValueNotifier<List<Map>> listMsg;
  late ValueNotifier<bool> blockGetMessage;
  late ValueNotifier<UserMt?> user;
  late WidgetRef widgetRef;
  late Map talk;
  late String tid;
  late StreamSubscription lnMessage;
  late List<Map> listTimeline;
  final focusNode = FocusNode();

  VwTalk({super.key});

  StreamSubscription setMessageListen(){
    return FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('resive message talk');
      final Map msg = message.data;
      String tid = msg['tid'] ?? '';
      String? category = msg['category'];
      if(category == 'chat'){
        if(tid == talk['tid']) {
          addListNew([msg]);
        }
      }
    });
  }

  void addListNew(List<Map> list){
    listMsg.value = [...list,...listMsg.value];
  }

  void addListOld(List<Map> list){
    listMsg.value = [...listMsg.value,...list];
  }

  Future<void> initTalk(String tid) async{
    await SqTalk.create(tid);
    await SqTalk.selectNew(tid, null, addListNew);
  }

  void sendMsg() {
    String text = myController.text;
    if(text.isEmpty){return;}
    FbChat.sendMsg(uidReceiver: tid, text: text, tid: tid, nameTalk: talk['name'] ?? '', callback: (Map msg){
      listMsg.value = [msg,...listMsg.value];
      widgetRef.read(pvChat.notifier).addTalk(msg);
    });
    myController.clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    talk = ModalRoute.of(context)?.settings.arguments as Map;
    tid = talk['tid'];
    scrollEnd = useState(false);
    loadMsgStop = useState(false);
    listMsg = useState([]);
    blockGetMessage = useState(false);
    widgetRef = ref;
    user = useState(null);
    listTimeline = ref.watch(pvTimeline);
    myController = useTextEditingController();

    if(listMsg.value.isNotEmpty){
      String timeTop = listMsg.value.first['time'];
      List<Map> listM = listTimeline.where((element) => (element['tid'] == tid && int.parse(element['time']) > int.parse(timeTop))).toList();
      if(listM.isNotEmpty) listMsg.value = [...listM,...listMsg.value];
    }

    useEffect((){
      lnMessage = setMessageListen();
      UserMt? userM = UserMt.mapUser[tid];
      if(userM == null){
        userM = UserMt(tid);
        userM.getData(callback: (UserMt userN) {
          user.value = userN;
        });
      }else{
        user.value = userM;
      }
      return lnMessage.cancel;
    },[]);

    if(listMsg.value.isEmpty){
      initTalk(tid);
    }

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            title: Text(talk['nameTalk'] == '' ? (user.value?.name ?? 'トーク') : 'トーク',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            backgroundColor: Color.fromRGBO(139,170, 216,1),
          ),
          body: SafeArea(
            child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: focusNode.unfocus,
                      child: wdListMsg(tid),
                    ),
                  ),
                  wdInputMsg(tid),
                ]
            ),
          )
      ),
    );
  }
  Widget wdLoad() {
    return Text('load');
  }

  ScrollController scrollController = ScrollController();

  Widget wdListMsg(String tid) {
    if(listMsg.value.isNotEmpty) {
      //scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }

    Future<void> loadListMsg(String tid) async{
      int indexBtm = listMsg.value.last['idx'];
      if(indexBtm > 1 && !loadMsgStop.value){
        loadMsgStop.value = true;
        await SqTalk.selectOld(tid, indexBtm, addListOld);
        loadMsgStop.value = false;
      }
    }

    return (Container(
        color: Color.fromRGBO(139,170, 216,1),
        child: NotificationListener<ScrollNotification>(
          child: ListView.builder(
              reverse: true,
              controller: scrollController,
              itemCount: listMsg.value.length,
              itemBuilder: (context, index) {
                return wdRowMsg(listMsg.value[index]);
              }
          ),
          onNotification: (notification){
            if(scrollController.position.pixels > scrollController.position.maxScrollExtent){
              loadListMsg(tid);
            }
            return false;
          },
        )
    ));
  }

  Widget wdRowMsg(Map msg)  {
    return(Container(
        margin: const EdgeInsets.all(4),
        child: (msg['uid'] == 'null' || msg['uid'] == null) ?  wdRowMsgMy(msg) : wdRowMsgYou(msg)
    ));
  }

  Widget wdRowMsgMy(Map msg){
    return (Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        Container(
          constraints: BoxConstraints(maxWidth: 250),
          child: Text(msg['text'],style: TextStyle(
            fontSize: 14,
          )),
          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(108, 230, 123, 1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        SizedBox(width: 4),
      ],
    ));
  }

  Widget wdRowMsgYou(Map msg){
    return (Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 3),
        glWdIconUser(user.value?.urlIcon, 40),
        SizedBox(width: 6),
        Container(
          constraints: BoxConstraints(maxWidth: 250),
          child: Text(msg['text'],style: TextStyle(
            fontSize: 14,
          )),
          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    ));
  }

  Widget wdIcon(String? url){
    return(CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xff94d500),
        child: Image.network(
          url ?? '',
          errorBuilder: (c,o,s){
            return Icon(
              Icons.person,
              color: Colors.black,
            );
          },
        ))
    );
  }

  Widget wdInputMsg(String tid) {
    return  Container(
        margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
                child:Container(
                  child:  TextField(
                    onTap: (){
                      List<int> list = [];
                      int i = 0;
                      while(i < myController.text.length){
                        i = myController.text.indexOf('\n',i);
                        if(i < 0)break;
                        list.add(i);
                        i++;
                      }
                      if(list.contains(myController.selection.baseOffset + 1)){
                        myController.selection = TextSelection.fromPosition(TextPosition(offset: myController.selection.baseOffset + 1));
                      }else if(myController.selection.baseOffset + 1 == myController.text.length){
                        myController.selection = TextSelection.fromPosition(TextPosition(offset: myController.text.length));
                      }
                    },
                    focusNode: focusNode,
                    controller: myController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                      fillColor: Color.fromRGBO(245, 245, 245,1),
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0.5,
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(24))
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0.5,
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(24))
                      ),
                    ),
                  ),
                )
            ),
            SizedBox(width: 12,),
            Container(
              margin: EdgeInsets.only(bottom: 2),
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  minimumSize: MaterialStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: sendMsg,
                child: const Icon(Icons.send,
                  size: 30,
                ),
              ),
            )
          ],
        )
    );
  }
}
