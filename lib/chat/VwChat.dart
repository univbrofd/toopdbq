import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/chat/SqChat.dart';
import 'package:toopdbq/swichat/VwSwichat.dart';

import '../common/VwCommon.dart';
import '../common/user.dart';
import '../timeline/VwTimeline.dart';
import 'FbChat.dart';

class ChatNotifier extends StateNotifier<List<Map>?>{
  ChatNotifier(): super(null);

  void setChat(List<Map> list){
    debugPrint('setChat');
    state = list;
  }

  void addListTalk(List<Map> listTalk){
    if(state == null){
      state = listTalk;
    }else{
      List<Map> stateC = List<Map>.from(state!);
      for(Map talk in listTalk){
        stateC.removeWhere((element) => element['tid'] == talk['tid']);
      }
      state = [...listTalk,...stateC];
    }
  }

  void addTalk(Map talk){
    debugPrint('addTalk');
    removeTalk(talk);
    if(state == null) {
      state = [talk];
    }else{
      state = [talk,...state!];
    }
  }

  void removeTalk(Map talk){
    debugPrint('removeTalk');
    if(state != null) {
      List<Map>? listTalk = state!.toList();
      listTalk.removeWhere((element) => element['tid'] == talk['tid']);
      state = listTalk;
    }
  }
}

class StBlockChat extends StateNotifier<bool>{
  StBlockChat():super(false);
  void set(bool bol){
    state = bol;
  }
}

final pvChat = StateNotifierProvider<ChatNotifier,List<Map>?>((ref){
  return ChatNotifier();
});

final pvBlockChat = StateNotifierProvider<StBlockChat,bool>((ref) => StBlockChat());

class VwChat extends HookConsumerWidget{
  late WidgetRef ref;

  Future<void> initChat() async{
    await SqChat.selectAll(
        ref.read(pvChat.notifier).setChat
    );
    await updateListTalk();
  }

  Future<void> updateListTalk() async {
    bool blockChat = ref.read(pvBlockChat);
    if(blockChat || UserMt.mid == null) return;
    ref.watch(pvBlockChat.notifier).set(true);

    await FbChat.getMsg_Save(callback: (List<List<Map>> result){
      List<Map> listChat = result[1];
      if(listChat.isNotEmpty){
        ref.read(pvChat.notifier).addListTalk(listChat);
      }
      ref.watch(pvBlockChat.notifier).set(false);
    });
  }

  static Future<void> getChat(WidgetRef ref) async{
    bool blockChat = ref.watch(pvBlockChat);
    if(blockChat || UserMt.mid == null) return;
    ref.read(pvBlockChat.notifier).set(true);
    await FbChat.getMsg_Save(callback:  (List<List<Map>> result){
      List<Map> listChat = result[0];
      List<Map> listMsg = result[1] as List<Map>;
      listMsg.sort((a,b) => b['time'].compareTo(a['time']));

      VwSwichat.setMsg(ref,listMsg);

      if(listChat.isNotEmpty) ref.read(pvChat.notifier).addListTalk(listChat);
      if(listMsg.isNotEmpty) ref.read(pvTimeline.notifier).add(listMsg, false);

      ref.read(pvBlockChat.notifier).set(false);
    });
  }

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.ref = ref;
    List<Map>? listTalk = ref.watch(pvChat);

    if (listTalk == null){
      initChat();
    }
    return (Scaffold(
      body: Container(child: listTalk == null ? glWdLoad() :
      listTalk.isEmpty ? wdEmpty() : wdListTalk()),
      backgroundColor: Colors.white,
    ));
  }

  Widget wdEmpty(){
    return Container(
        alignment: Alignment.center,
        child: Text('メッセージがありません')
    );
  }


  Widget wdListTalk(){
    List<Map>? listTalk = ref.watch(pvChat);
    return(ListView.builder(
      itemCount: listTalk!.length,
      itemBuilder: (context, index){
        Map talk = listTalk[index];
        return Container(
          margin: const EdgeInsets.all(8),
          child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/talk',arguments: talk),
              child: VwRowTalk(talk)
          ),
        );
      },
    ));
  }
}

class VwRowTalk extends HookConsumerWidget{
  String tid = '';
  String? name;
  String text = '';
  late ValueNotifier<UserMt?> user;
  VwRowTalk(Map talk, {Key? key}) : super(key: key){
    tid = talk['tid'] ?? '';
    text = talk['text'];
  }

  @override
  Widget build(BuildContext context,WidgetRef ref){
    user = useState(null);
    useEffect((){
      UserMt? userM = UserMt.mapUser[tid];
      if(userM == null){
        userM = UserMt(tid);
        userM.getData(callback: (UserMt userN) {
          user.value = userN;
        });
      }else{
        user.value = userM;
      }
    },[]);
    return(Row(
        children: [
          SizedBox(width: 10),
          glWdIconUser(user.value?.urlIcon, 50),
          SizedBox(width: 10),
          wdName()
        ]
    ));
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

  Widget wdName(){
    return(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (name == 'null' || name == null) ? (user.value?.name ?? 'no None') : name!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(90, 90, 90, 1)
          ),
        ),
      ],
    ));
  }
}