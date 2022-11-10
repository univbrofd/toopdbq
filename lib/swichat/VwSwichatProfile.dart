import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/card/FbCard.dart';
import 'package:toopdbq/common/StMain.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/main.dart';
import 'package:toopdbq/swichat/SqSwichat.dart';
import 'package:toopdbq/swichat/VwSwichat.dart';
import '../common/VwProfile.dart';

class VwSwichatProfile extends HookConsumerWidget {
  late BuildContext context;
  late WidgetRef ref;
  UserMt user;

  VwSwichatProfile(this.user);

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;

    return Scaffold(
        body: wdBody()
    );
  }
}

extension Layout on VwSwichatProfile{
  Widget wdBody(){
    return Container(
      child: Stack(
        children: [
          VwProfile(user,100,null),
          wdToolProfile()
        ],
      ),
    );
  }

  Widget wdToolProfile(){
    return SafeArea(child: Column(
      children: [
        wdRowBtn(),
        Spacer(),
      ],
    ));
  }

  Widget wdActionBtnUp(){
    return(FloatingActionButton(
      heroTag: 'card btn up',
      onPressed: (){
        Navigator.pop(context,null);
      },
      backgroundColor: Colors.lightBlue,
      child: Icon(
        Icons.arrow_drop_up_outlined,
        color: Colors.white,
        size: 50,
      ),
    ));
  }

  Widget wdRowBtn(){
    return(Container(
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          wdBtnBack(),
          Spacer(),
          wdBtnNope(),
        ],
      ),
    ));
  }

  Widget wdBtnLike(){
    return FloatingActionButton(
        heroTag: 'cardFull btn like',
        onPressed:(){
          if(user.uid != null) {
            SqSwichat.addLikeUid(user.uid!);
            ref.read(pvListLikeUid.notifier).add([user.uid!]);
            FbCard.like(user.uid!);
          }
        },
        backgroundColor: colorMain,
        child: Icon(
          Icons.favorite,
          color: Colors.white,
          size: 30,
        )
    );
  }

  Widget wdBtnOption(){
    return Container(
      height: 40,
        child:FloatingActionButton(
          heroTag: 'cardFull btn option',
          onPressed:(){
          },
          backgroundColor: Colors.black54,
          child: Icon(
            Icons.priority_high,
            color: Colors.white,
            size: 20,
          )
      )
    );
  }

  Widget wdBtnBack(){
    return(FloatingActionButton(
        heroTag: 'card btn nope',
        onPressed:(){
          Navigator.pop(context);
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.chevron_left,
          color: Colors.black,
          size: 30,
        )
    ));
  }

  Widget wdBtnNope(){
    return Container(
      width: 48,
      height: 48,
      child: FloatingActionButton(
        heroTag: 'card btn nope',
        onPressed:(){
          VwSwichat.switchUser(ref);
          Navigator.pop(context);
        },
        backgroundColor: Colors.red,
        child: Icon(
          Icons.close,
          color: Colors.white,
        )
    ));
  }
}