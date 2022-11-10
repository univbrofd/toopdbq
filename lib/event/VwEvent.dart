import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/VwCommon.dart';
import 'package:toopdbq/event/FbEvent.dart';
import 'package:toopdbq/event/SqEvent.dart';
import 'package:toopdbq/event/StEvent.dart';
import 'package:toopdbq/main.dart';

import '../common/user.dart';
import 'VwEventDetail.dart';
import 'VwEventPost.dart';
import '../common/VwDialogTag.dart';

class VwEvent extends HookConsumerWidget{
  late WidgetRef ref;
  late BuildContext context;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.ref = ref;
    this.context = context;
    return Scaffold(
      backgroundColor: Colors.white,
      body: wdBody()
    );
  }

  static Future<void> getEvent({required WidgetRef ref,required List<String> listTag}) async{
    bool eventLoad = ref.watch(pvEventLoad);
    if(eventLoad)return;
    ref.read(pvEventLoad.notifier).set(true);
    VwEvent.getEventMy(ref);
    List<Map> listEventC = ref.watch(pvEvent);
    DateTime time = DateTime.now();
    try{
      final strTime = listEventC.last['time'];
      time = DateTimeExtension.fromString(strTime);
    }catch(_){}
    List<Map> listEventN = ref.watch(pvEvent);
    DateTime timeLimit = time.add(const Duration(days: 100));
    while(listEventN.length < 5 && time.compareTo(timeLimit) < 0){
      List<Map> result = await FbEvent.getListEvent(time:time,listTag: listTag);
      listEventN = [...listEventN,...result];
      if(result.isEmpty || result.length < 5){
        time = DateTime(time.year + 1);
      }else{
        time = DateTimeExtension.fromString(result.last['time']);
      }
    }
    ref.read(pvEvent.notifier).add(listEventN);
    ref.read(pvEventLoad.notifier).set(false);
  }
  
  static getEventMy(WidgetRef ref){
    if(ref.watch(pvEventMy) != null)return;
    FbEvent.getEventMy(func: (Map event){
      ref.read(pvEventMy.notifier).set(event);
    });
  }

  void _onTapSearch() async{
    final listTag = ref.watch(pvEventTag);

    var result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: VwDialogTag(numMax: 5,theme: 'event',initListTag: listTag,)
          );
        }
    );
    try{
      if(listTag != result){
        final listTagM = result as List<String>;
        ref.read(pvEventTag.notifier).set(listTag);
        ref.read(pvEvent.notifier).set([]);
        VwEvent.getEvent(ref: ref,listTag: result);
      }
    }catch(e){}
  }

  void _onLike(Map event){
    String eid = event['eid'];
    String? tokenHost = event['tokenHost'];
    if(tokenHost != null)FbEvent.onLike(eid,tokenHost);
    SqEvent.addLikeEvent(eid);
    ref.read(pvEventLike.notifier).add(eid);
  }
}

extension Layout on VwEvent{
  Widget wdBody() {
    List<Map> list = ref.watch(pvEvent);
    bool load = ref.watch(pvEventLoad);
    final listTag = ref.watch(pvEventTag);

    return Container(
        child: Stack(
          children: [
            !load ? Center() : Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: MediaQuery
                  .of(this.context)
                  .size
                  .height * 0.7),
              child: glWdLoad(),
            ),
            Column(
              children: [
                listTag.isEmpty ? Center() : wdTag(),
                list.isEmpty ? Center(child: Text('イベントがありません')) : wdList(),
              ],
            ),
            wdBtnMain()
          ],
        )
    );
  }

  Widget wdList() {
    List<Map> list = ref.watch(pvEvent);
    return Flexible(child: ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        Map event = list[index];
        return Container(
          margin: const EdgeInsets.all(8),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => VwEventDetail(event),
              )).then((result){
                if(result == true){
                  _onLike(event);
                }
              });
            },
            child: VwRowList(event),
          ),
        );
      },
    ));
  }

  Widget wdBtnMain(){
    Map? eventMy = ref.watch(pvEventMy);
    
    return Column(
      children: [
        Spacer(),
        wdBtnSearch(),
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(12),
          child: eventMy == null ? wdBtnPost() : wdBtnMy(eventMy)
        )
      ],
    );
  }

  Widget wdBtnPost(){
    return FloatingActionButton(
      heroTag: 'event btn post',
      child: Icon(Icons.add),
      backgroundColor: Colors.grey,
      onPressed: (){
        Navigator.push(this.context, MaterialPageRoute(
          builder: (context) => VwEventPost(),
          fullscreenDialog: true,
        ));
      },
    );
  }

  Widget wdBtnMy(Map eventMy){
    return GestureDetector(
      onTap: (){
        Navigator.push(this.context, MaterialPageRoute(
          builder: (context) => VwEventDetail(eventMy),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: [BoxShadow(
                offset: Offset(0,4),
                blurRadius: 8,
                color: Colors.black26
            )]
        ),
        child: glWdIconUser(UserMt.urlIconMy, 56),
      ),
    );
  }

  Widget wdBtnSearch(){
    return Container(
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.all(12),
      child: FloatingActionButton(
        heroTag: 'event btn search',
        child: Icon(Icons.search),
        backgroundColor: colorMain,
        onPressed: _onTapSearch
      ),
    );
  }
  
  Widget wdTag(){
    final listTag = ref.watch(pvEventTag);

    return Container(
      child: Row(
        children: listTag.map((String tag){
          return Text(tag);
        }).toList(),
      ),
    );
  }
}

class VwRowList extends HookConsumerWidget{
  late BuildContext context;
  Map event;
  List<String>? listTag;
  VwRowList(this.event);
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    this.context = context;
    if(event['listTag'] != null) {
      listTag = List<String>.from(event['listTag']);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          wdMain(),
          wdTimePlace(),
          wdTag(),
        ],
      ),
    );
  }

  Widget wdMain(){
    return Container(
      child: Row(
        children: [
          wdIcon(),
          wdContent()
        ],
      ),
    );
  }

  Widget wdIcon(){
    return Container(
      padding: EdgeInsets.only(right: 8),
      child: glWdIconUser(event['urlIcon'],50),
    );
  }

  Widget wdContent(){
    return Flexible(child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              wdTitle(),
              SizedBox(width: 4,),
              wdNum()
            ],
          ),
          wdComment()
        ],
      ),
    ));
  }

  Widget wdTitle(){
    return Flexible(child:Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
          event['title'],
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16
        ),
      ),
    ));
}

  Widget wdComment() {
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Text(
          event['comment'],
        maxLines: 2,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget wdTimePlace(){
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          wdTime(),
          SizedBox(width: 4,),
          wdPlace()
        ],
      ),
    );
  }

  Widget wdTime(){
    DateTime time = DateTimeExtension.fromString(event['time'].toString());
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.grey,
                width: 1
            )
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.grey,size: 15,),
              Spacer(),
              Text('${time.month}/${time.day} (${time.getWeekDay()}) ${time.hour}:${time.minute.toString().padLeft(2,'0')}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600
              ),),
              Spacer(),
            ],
          )
        ),
    );
  }

  Widget wdPlace(){
    return Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey,
              width: 1
            )
          ),
        child: Row(
          children: [
            Icon(Icons.place, color: Colors.grey,size: 15,),
            Expanded(child:
              Text(
                event['place'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget wdNum(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2,horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
          width: 1
        )
      ),
      child: Row(
        children: [
          Icon(Icons.group, color: Colors.grey,size: 14,),
          SizedBox(width: 8,),
          Text('${event['member'].length} / ${event['numMax']}',style: TextStyle(
            color: Colors.grey,
            fontSize: 14
          ),),
        ],
      ),
    );
  }

  Widget wdTag(){
    return listTag == null ? Container() : Container(
      width: 500,
      child:
      Wrap(
        children: listTag!.map((String tag){
            return Container(
              margin: EdgeInsets.fromLTRB(0, 4, 4, 4),
              padding: EdgeInsets.symmetric(vertical: 2,horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Colors.white
                ),
                maxLines: 1,
              ),
            );
          }).toList(),
      )
    );
  }
}