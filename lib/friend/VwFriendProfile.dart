import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/card/VwCardFull.dart';
import 'package:toopdbq/chat/SqChat.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';
import '../common/VwProfile.dart';
import '../main.dart';

class VwFriendProfile extends HookConsumerWidget{
  UserMt user;
  late BuildContext context;

  VwFriendProfile(this.user);

  Widget wdBtn(){
    return FloatingActionButton(
      heroTag: 'friendProfile btn chat',
      onPressed: () async{
        if(user.uid != null) {
          await SqTalk.create(user.uid!);
          List<Map> list = await SqChat.select(user.uid!);
          Map talk;
          if (list.isEmpty){
            talk = {
              "tid":user.uid!,
              'nameTalk':user.name,
              'time':DateTime.now().toFormString(),
              'text':'',
              'urlIcon':user.urlIcon,
            };
          }else{
            talk = list.first;
          }
          Navigator.of(context).pushNamed('/talk',arguments: talk);
        }
      },
      child: Icon(
        Icons.chat,
      ),
      backgroundColor: colorMain,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.context = context;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          VwProfile(user, 20, wdBtn()),
          wdHeader()
        ],
      )
    );
  }

  Widget wdHeader(){
    return Container(
      padding: EdgeInsets.fromLTRB(10, 40, 10, 0),
      child: Row(
        children: [
          wdBtnBack(),
          Spacer(),
          wdBtnBlock()
        ],
      ),
    );
  }

  Widget wdBtnBack(){
    return Container(
      width: 50,
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.white, //色
            width: 1, //太さ
          ),
        ),
        onPressed: Navigator.of(context).pop,
        child: Icon(Icons.chevron_left, color: Colors.white,size: 30,),
      ),
    );
  }

  Widget wdBtnBlock(){
    return Container(
      width: 34,
      height: 34,
      child: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: (){},
        child: Icon(Icons.priority_high,size: 20,),
      ),
    );
  }
}