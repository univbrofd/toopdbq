import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/event/FbEvent.dart';
import 'package:toopdbq/event/SqEvent.dart';
import 'package:toopdbq/event/VwEventListLike.dart';
import 'package:toopdbq/main.dart';

import '../friend/VwFriendProfile.dart';

class VwEventDetail extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  Map event;
  late ValueNotifier<List<UserMt>> member;
  late ValueNotifier<bool> liked;

  VwEventDetail(this.event);

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    member = useState([]);
    liked = useState(false);

    useEffect((){
      useEffectAsync();
      getMember();
    },[]);

    return wd();
  }

  void useEffectAsync() async{
    if(await SqEvent.existEvent(event['eid'])) liked.value = true;
  }

  Future<void> getMember() async{
    String idHost = event['host'];
    UserMt host = UserMt(idHost);
    await host.getData();
    List<UserMt> list = [host];
    for(String uid in event['member']){
      if(idHost == uid)continue;
      UserMt user = UserMt(uid);
      await user.getData();
      list.add(user);
    }
    member.value = list;
  }

  void _onLike(){
    liked.value = true;
  }
}

extension Layout on VwEventDetail{
  Widget wd(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorMain,
        title: Text(event['title'],style: TextStyle(
          fontWeight: FontWeight.w900
        ),),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 8),
            alignment: Alignment.center,
            child: Text('${event['member'].length} / ${event['numMax']} 人',style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700
            ),),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: wdMain(),
      )
    );
  }

  Widget wdMain(){
    return Container(
      child: Stack(
        children: [
          wdMember(),
          wdInfo(),
          wdTool(),
        ],
      ),
    );
  }

  Widget wdInfo(){
    return Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5),
        padding: EdgeInsets.symmetric(vertical: 16,horizontal: 16),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2), //色
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(0,0),
              ),
            ],
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30)
            )
        ),
        child: SafeArea(child: SingleChildScrollView(
          child:  Column(
            children: [
              wdComment(),
              wdTime(),
              wdPlace(),
              wdListTag(),
            ],
          ),
        ))
    );
  }

  Widget wdTitle(){
    return Container(
      child: Text(event['title'] ?? ''),
    );
  }

  Widget wdComment(){
    return Container(
      child: Text(
        event['comment'] ?? '',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14
        ),
      ),
    );
  }

  Widget wdTime(){
    DateTime time = DateTimeExtension.fromString(event['time'].toString());
    return Row(
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
            decoration: BoxDecoration(
              color: colorMain,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                ),
                SizedBox(width: 8,),
                Text(
                  '${time.month}/${time.day} (${time.getWeekDay()}) ${time.hour}:${time.minute.toString().padLeft(2,'0')}',
                  style: TextStyle(
                      color: Colors.white,
                    fontSize: 16
                  ),
                ),
              ],
            ),
          ),
          Spacer()
        ],
      );
  }

  Widget wdPlace(){
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 123, 230, 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.place,
                color: Colors.white,
              ),
              SizedBox(width: 8,),
              Text(
                event['place'],
                style: TextStyle(
                    color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Spacer()
      ],
    );
  }

  Widget  wdListTag(){
    List<String> listTag = List<String>.from(event['listTag']);
    return listTag.isEmpty ? Center() : Container(
        margin: EdgeInsets.only(top: 8),
        child: Wrap(
          children: listTag.map((String tag){
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4,horizontal: 8),
                margin: EdgeInsets.only(right: 8,bottom: 8),
                decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            }).toList()
        ),
    );
  }

  Widget wdMember(){
    return Container(
      padding: EdgeInsets.all(8),
      child: ListView.builder(
          itemCount: member.value.length,
          itemBuilder: (context,index){
            UserMt user = member.value[index];
            return Container(
              margin: index + 1 == member.value.length ? EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.5) : EdgeInsets.zero,
              child: InkWell(
                onTap: (){
                  Navigator.push (context, MaterialPageRoute(
                    builder: (context) => VwFriendProfile(user),
                    //以下を追加
                    fullscreenDialog: true,
                  ));
                },
                child: wdUser(user),
              ),
            );
          }
      ),
    );
  }

  Widget wdUser(UserMt user){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          wdIcon(user.urlIcon),
          wdContent(user)
        ],
      ),
    );
  }
  Widget wdIcon(String? urlIcon){
    return Container(
      child: glWdIconUser(urlIcon,50),
    );
  }

  Widget wdContent(UserMt user){
    return Flexible(child:Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wdName(user.name),
          user.profile == null ? Center() : wdProfile(user.profile)
        ],
      ),
    ));
  }

  Widget wdName(String? name){
    return Container(
      child: Text(
        name ?? 'No Name',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget wdProfile(String? profile){
    return Container(
      child:  Text(
        profile ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 14
        ),
      ),
    );
  }

  Widget wdTool(){
    return SafeArea(child: Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Spacer(),
          event['host'] == UserMt.mid ? wdBtnShowLike() :
            liked.value ? wdBtnLiked() : wdBtnLike()
        ],
      )
    ));
  }

  Widget wdBtnNope(){
    return Expanded(child:Container(
      child: ElevatedButton.icon(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.reply
        ),
        label: Text(
          '戻る',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700
          ),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey
        ),
      )
    ));
  }

  Widget wdBtnLike(){
    return FloatingActionButton(
      heroTag: 'event btn like',
      backgroundColor: colorMain,
      onPressed: (){
        _onLike();
        Navigator.pop(context,true);
      },
      child: Icon(
          Icons.favorite,
      ),
    );
  }

  Widget wdBtnLiked(){
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: (){

      },
      child: Icon(
        color:colorMain,
        Icons.favorite,
      ),
    );
  }

  Widget wdBtnShowLike(){
    return FloatingActionButton(
      heroTag: 'event btn showLike',
      backgroundColor: Colors.white,
      onPressed: (){
        if(event['eid'] == null)return;
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => VwEventListLike(event['eid']),
        ));
      },
      child: Icon(
        color:colorMain,
        Icons.emoji_people_outlined,
      ),
    );
  }
}