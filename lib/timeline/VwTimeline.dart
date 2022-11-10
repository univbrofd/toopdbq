import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/card/VwCard.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/main.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../chat/FbChat.dart';
import '../chat/SqChat.dart';

class StTimeline extends StateNotifier<List<Map>>{
  StTimeline(): super([]);

  void set(List<Map> list){
    List<Map> listM = list.map((e){
      Map mapM = {...e,'key':UniqueKey().toString()};
      return mapM;
    }).toList();
    state = listM;
  }
  void add(List<Map> list,bool old) {
    List<Map> listM = list.map((e){
      Map mapM = {...e,'key':UniqueKey().toString()};
      return mapM;
    }).toList();
    state = old ? [...state,...listM] : [...listM,...state];
  }
}

class StTimelineTime extends StateNotifier<DateTime?>{
  StTimelineTime(): super(null);
  void set(DateTime time){state = time;}
  void pull(){
    state = DateTime(state!.year,state!.month,state!.day-5);
  }
}

class StTimelineActiveKey extends StateNotifier<String?>{
  StTimelineActiveKey(): super(null);
  void set(String? key){state = key;}
}

final pvTimeline = StateNotifierProvider<StTimeline,List<Map>>((ref){return StTimeline();});
final pvTimelineTime = StateNotifierProvider<StTimelineTime,DateTime?>((ref){return StTimelineTime();});
final pvTimelineActiveKey = StateNotifierProvider<StTimelineActiveKey,String?>((ref){return StTimelineActiveKey();});

class VwTimeline extends HookConsumerWidget{
  VwTimeline({required Key key}):super(key: key);
  late WidgetRef ref;
  late BuildContext context;
  late List<Map> listMsg;
  late DateTime? timeBtm;
  late ValueNotifier<bool> blockGetMsg;
  late ValueNotifier<bool> openHeader;
  late TextEditingController myController;
  Color colorOff = Color.fromRGBO(200, 200, 200, 1);
  Function(Map)? _setReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.ref = ref;
    this.context = context;
    listMsg = ref.watch(pvTimeline);
    timeBtm = ref.watch(pvTimelineTime);
    String? activeKey = ref.watch(pvTimelineActiveKey);
    blockGetMsg = useState(false);
    openHeader = useState(true);
    myController = useTextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (timeBtm == null) {
        init();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child:Stack(
        alignment: Alignment.topCenter,
        children: [
          listMsg.isEmpty ? wdEmpty() : wdListTimeline(),
          Column(
            children: [
              activeKey == null ? const Center() : wdToolBar(activeKey),
              Spacer(),
              activeKey == null ? const Center() : wdTextFiled(),
            ],
          ),
          (openHeader.value && activeKey== null) ? wdHeader() : Center(),
        ],
      )
    ));
  }

  void _onNavTalk(){
    String? activeKey = ref.watch(pvTimelineActiveKey);
    if(activeKey != null){
      Map user = listMsg.where((element) => element['key'] == activeKey).first;
      Navigator.of(context).pushNamed('/talk',arguments: user);
    }
  }

  Widget wdToolBar(String key){
    List list = listMsg.where((element) => (element['key'] == key)).toList();
    Map? msg =  list.isNotEmpty ? list.first : null;
    return msg == null ? Center() : Container(
      height: 46,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            boxShadow: [BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                offset: const Offset(0,2),
                blurRadius: 1.0,
                spreadRadius: 0
            )]
        ),
        padding: EdgeInsets.only(bottom: 8),
        child:Row(
          children: [
            Container(
              child: FloatingActionButton(
                backgroundColor: Colors.grey,
                onPressed: (){
                  ref.read(pvTimelineActiveKey.notifier).set(null);
                },
                child: Icon(
                  Icons.undo,
                  color: Colors.white,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
            Spacer(),
            Text(
              '${msg['nameUser']}',
              style: TextStyle(
                fontSize: 16,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w800
              ),
            ),
            Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                  onPressed: _onNavTalk,
                  icon: const Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                  label: Text(
                      '話す',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorMain,
                    padding: EdgeInsets.all(8),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                  ),
                ),
              ),

          ],
        )
      ),
    );
  }

  Widget wdEmpty() {
    return Container(
      alignment: Alignment.center,
      child: Text('メッセージがありません')
    );
  }

  Future<void> init() async{
    DateTime timeTop = DateTime.now();
    print('timeline init listMsg.leng : ${listMsg.length}, time: $timeTop');
    List<Map> listMsgM = [];
    while(listMsg.length < 20 && DateTime(2022,9,1).compareTo(timeTop) < 0){
      DateTime timeBtm = DateTime(timeTop.year,timeTop.month,timeTop.day-5);
      List<Map> listMsgNew = await SqTalk.selectTimeline(timeTop,timeBtm);
      listMsgM = [...listMsgM,...listMsgNew];
      timeTop = timeBtm;
    }
    ref.read(pvTimelineTime.notifier).set(DateTime.now());
    ref.read(pvTimeline.notifier).set(listMsgM);
  }

  
  Future<void> getMsgOld() async{
    print('getMsgOld');
    print(blockGetMsg.value);
    if(blockGetMsg.value)return;
    blockGetMsg.value = true;
    DateTime timeTop = timeBtm!;
    DateTime timeBtmM =  DateTime(timeTop.year,timeTop.month,timeTop.day-5);
    List<Map> listMsgNew = await SqTalk.selectTimeline(timeTop,timeBtmM);
    ref.read(pvTimelineTime.notifier).set(timeBtmM);
    ref.read(pvTimeline.notifier).add(listMsgNew, true);
    blockGetMsg.value = false;
  }

  Future<void> getMsgNew() async {
    if(blockGetMsg.value || UserMt.mid == null)return;
    blockGetMsg.value = true;
    List dataMsg = await FbChat.getMsg_Save();
    List<Map> listMsgNew = dataMsg[2];
    if(listMsgNew.isNotEmpty){
      listMsgNew.sort((a,b) => b['time'].compareTo(a['time']));
      ref.read(pvTimeline.notifier).add(listMsgNew, false);
    }
    blockGetMsg.value = false;
  }

  AutoScrollController scrollController = AutoScrollController();
  final focusNode = FocusNode();

  Widget wdHeader(){
    int numUser = listMsg.map((e)=> e['uid']).toSet().length;
    return Container(
        child: Row(
          children: [
            Spacer(),
            Text('ユーザー $numUser',style: TextStyle(
              fontSize: 14,
              color: Colors.black
            ),),
            Spacer(),
            Text('メッセージ ${listMsg.length}',style: TextStyle(
              fontSize: 14,
              color: Colors.black
            ),),
            Spacer()
          ],
        ),
      );
  }

  double? _pixels;
  late int _timestamp;
  bool _onScroll(ScrollNotification notification){
    double pixels = scrollController.position.pixels;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (_pixels != null) {
      final double velocity = (pixels - _pixels!) / (timestamp - _timestamp!);
      if(openHeader.value && _pixels! > 0 && velocity > 0 ){
        openHeader.value = false;
      }else if(velocity < -0.9 ){
        openHeader.value = true;
      }
    }
    _pixels = pixels;
    _timestamp = timestamp;

    return true;
  }

  void _onTapRow(double position,String key,int index,Function(Map) setReply) {
    String? activeKey = ref.watch(pvTimelineActiveKey);
    focusNode.unfocus();
    if(activeKey != null){
      ref.read(pvTimelineActiveKey.notifier).set(null);
    }else{
      scrollController.animateTo(
          (scrollController.offset - 160 + position),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut
      );
      ref.read(pvTimelineActiveKey.notifier).set(key);
      ref.read(pvCardIndex.notifier).set(index);
    }
    _setReply = setReply;
  }

  Widget wdListTimeline(){

    return Focus(
      focusNode: focusNode,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child:Container(
          child: ListView.builder(
              controller: scrollController,
              itemCount: listMsg.length,
              itemBuilder: (context, index){
                Map msg = listMsg[index];
                String key = msg['key'];
                return AutoScrollTag(
                  key: Key(key),
                  controller: scrollController,
                  index: index,
                  child: Container(
                    padding: index == 0 ? const EdgeInsets.only(top: 50) :
                      (index == listMsg.length - 1) ? EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.7) : EdgeInsets.zero,
                    child: VwTimelineRow(msg:msg,onTapRow: _onTapRow,index: index,keyMsg: key,),
                  )
                );
              }
          ),
        ),
      )
    );
  }

  void sendMsg(){
    int activeIndex = ref.watch(pvCardIndex);
    try {
      Map msg = listMsg[activeIndex];
      String uidReceiver = msg['uid'];
      String text = myController.text;
      print('sendMsg from timeline,msg:$msg');
      FbChat.sendMsg(uidReceiver: uidReceiver, text: text,);
      if(_setReply != null)_setReply!({'text':text});
    }catch(e){
      print(e);
    }
    myController.clear();

  }

  Widget wdTextFiled(){
      return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        color: Colors.white,
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
                          print(i);
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
                    autofocus: true,
                    focusNode: focusNode,
                    controller: myController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: decoText()
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
                  color: colorMain,
                  size: 30,),
              ),
            )
          ],
        )
      );
  }

  InputDecoration decoText(){
    return const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
        fillColor: Color.fromRGBO(245, 245, 245,1),
        filled: true,
        focusedBorder: OutlineInputBorder (
            borderSide: BorderSide(
              width: 0.5,
              color: Color.fromRGBO(0, 0, 0, 0.2),
            ),
            borderRadius: BorderRadius.all(Radius.circular(24))
        ),
        enabledBorder: OutlineInputBorder (
            borderSide: BorderSide(
              width: 0.5,
              color: Color.fromRGBO(0, 0, 0, 0.2),
            ),
            borderRadius: BorderRadius.all(Radius.circular(24))
        )
    );
  }
}

class VwTimelineRow extends HookConsumerWidget{
  Function(double,String,int,Function(Map)) onTapRow;
  final myController = TextEditingController();
  late WidgetRef ref;
  Map msg;
  int index;
  String keyMsg;
  late ValueNotifier<Map?> msgReply;
  late ValueNotifier<UserMt?> user;
  VwTimelineRow({required this.index, required this.onTapRow,required this.msg,required this.keyMsg,});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    this.ref = ref;
    String? activeKey = ref.watch(pvTimelineActiveKey);
    List<Map> listMsg = ref.watch(pvTimeline);
    user = useState(null);
    msgReply = useState(null);
    useEffect((){
      getReply();
      String? uid = msg['uid'];
      UserMt? userM = UserMt.mapUser[uid];
      if(userM == null){
        userM = UserMt(uid);
        userM.getData(callback: (UserMt userM){
          user.value = userM;
        });
      }else{
        user.value = userM;
      }
    },[]);

    return GestureDetector(
        onTapDown: (details){
          onTapRow(details.globalPosition.dy - details.localPosition.dy,keyMsg,index,setReply);
        },
        child:Container(
          child: Opacity(
            opacity: (activeKey == null || activeKey == msg['key']) ? 1 : 0.3,
           child: Container(
             padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
             decoration: BoxDecoration(
                 border:
                   activeKey == msg['key'] ? Border.all(color: colorMain, width: 1) :
                   (index == listMsg.length - 1 || listMsg[index + 1]['tid'] != msg['tid']) ? const Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.4,
                          )
                      ):
                       null
             ),
             child: Column(
               children: [
                 wdReply(),
                 Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     (index != 0 && listMsg[index - 1]['tid'] == msg['tid']) ? SizedBox(width: 40,) :
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: glWdIconUser(user.value?.urlIcon, 40),
                      ),
                     wdContent(),
                   ],
                 ),
               ],
             )
           ),
          )
        )
    );
  }

  Widget wdContent(){
    List<Map> listMsg = ref.watch(pvTimeline);
    return Container(
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (index != 0 && listMsg[index - 1]['tid'] == msg['tid']) ? SizedBox(width: 40,) : wdName(),
          SizedBox(height: 4,),
          wdText(),
        ],
      ),
    );
  }

  Widget wdName(){
    return Container(
      margin: EdgeInsets.only(top: 8),
      alignment: Alignment.topLeft,
      child: Text(user.value?.name ?? 'none', style: TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w700
      )),
    );
  }

  Widget wdText(){
    List<Map> listMsg = ref.watch(pvTimeline);
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      child: Text(msg['text'],style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
      )),
      margin: (index == listMsg.length - 1 || listMsg[index + 1]['tid'] != msg['tid']) ? EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black,
            width: 1,
          )
      ),
    );
  }

  Widget wdReply(){
    return msgReply.value == null ? Center() : Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(vertical: 2,horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: colorMain,
                    width: 1,
                )
            ),
            child: Row(
              children: [
                Icon(Icons.reply,
                color: colorMain,size: 14,),
                SizedBox(width: 5,),
                Text(msgReply.value!['text'],
                  style: TextStyle(
                      color: colorMain
                  ),
                )
              ],
            )
          )
        ],
      ),
    );
  }

  void getReply() async{
    msgReply.value = await SqTalk.selectReply(this.msg);
    print(msgReply.value);
  }

  void setReply(Map msg) async{
    print('setReply');
    if(msgReply.value == null) msgReply.value = msg;
  }
}