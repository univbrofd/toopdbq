
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/FbMain.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/SqMain.dart';
import 'package:toopdbq/my/FbMy.dart';
import '../card/VwCard.dart';
import '../common/user.dart';
import '../main.dart';
import 'StMy.dart';



class VwMy extends HookConsumerWidget{
  late BuildContext context;
  late UserMt? userMy;
  late WidgetRef ref;
  late ValueNotifier<File?> posterNew;
  late ValueNotifier<File?> iconNew;
  late ValueNotifier<bool> load;

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    userMy = ref.watch(pvUserMy);
    posterNew = useState(null);
    iconNew = useState(null);
    load = useState(false);

    return(Scaffold(
      backgroundColor: Colors.white,
      body: ref.watch(pvMyReload) ? wdProfile() : wdProfile()
    ));
  }

  Widget wdProfile(){
    return Container(
        child: Stack(
          children: [
            wdImage(context),
            wdMain(),
            wdHeader()
          ],
        )
    );
  }

  Widget wdMain(){
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.width * 1.5,
                )
            ),
            wdGrpIcon(),
            wdInfo()
          ],
        ),
      ),
    );
  }

  Widget wdGrpIcon(){
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.width * 0.1,),
              Container(
                height: MediaQuery.of(context).size.width * 0.1,
                color: Colors.white,
              )
            ],
          ),
          Container(
              margin: EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  wdIcon(MediaQuery.of(context).size.width * 0.2),
                  const Spacer(),
                  wdBtnEdit(MediaQuery.of(context).size.width * 0.1),
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget wdInfo(){
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wdGrpName(),
          wdStatus(),
          wdText(),
          wdBtnLogout(),
          wdBtnDelete()
        ],
      ),
    );
  }

  Widget wdIcon(double size){
    try{
      return(SizedBox(
          height: size,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child:
              iconNew.value != null ? Image.file(iconNew.value!,fit: BoxFit.cover,) :
              Image.network(userMy!.urlIcon!, fit: BoxFit.cover,)
          ))
      );
    }catch(e){
      return(
          Container(
              width: size,
              height: size,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: colorMain,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              )
          )
      );
    }

  }

  Widget wdBtnEdit(double height){
    return ElevatedButton.icon(
      onPressed: (){
        if(userMy == null)return;
        Navigator.of(context).pushNamed('/editProfile',arguments: userMy)
            .then((value){
          if(value is List<File?>) {
            iconNew.value = value[0];
            posterNew.value = value[1];
          }
        });
      },
      icon: Icon(
        Icons.edit,
        color: Colors.white,
      ),
      label: Container(
        alignment: Alignment.center,
        width: 70,
        child: Text(
          '編集',
          style: TextStyle(
              color: Colors.white
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: colorMain.withOpacity(0.5)
      ),
    );
  }

  Widget wdImage(BuildContext context) {
    return(ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.74,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 1.6,
        child:
        posterNew.value != null ? Image.file(posterNew.value!,fit: BoxFit.cover,) :
        userMy?.urlPoster != null ? Image.network(userMy!.urlPoster!, fit: BoxFit.cover,) :
        Image.asset('images/smpl_poster.jpg', fit: BoxFit.cover,),
      ),
    ));
  }

  Widget wdGrpName(){

    return(Container(
      padding: EdgeInsets.fromLTRB(16, 4, 8, 0),
      child: Row(
        children: [
          Text(
            userMy?.name ?? 'no name',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600
            ),
          ),
          Spacer(),
        ],
      )
    ));
  }

  Widget wdStatus(){
    return Container(
      padding: EdgeInsets.fromLTRB(16, 4, 8, 0),
      child: Row(
        children: [
          wdSex(),
          SizedBox(width: 8,),
          wdAge(),
          SizedBox(width: 8,),
          wdLive()
        ],
      ),
    );
  }

  Widget wdSex(){
    int? sex = userMy?.sex;
    return Container(
        child: sex == null ? Center() : sex == 0 ? Icon(
          Icons.male_outlined,
          size: 30,
          color: colorMain,
        ) : Icon(
          Icons.female,
          size: 30,
          color: Colors.pink,
        )
    );
  }

  Widget wdAge(){
    int? age;
    if(userMy?.birthday != null) {
      DateTime birthday = DateTimeExtension.fromString(userMy!.birthday!);
      age = birthday.getAge();
    }
    return Container(
      child: age == null ? Center()
      : Text(
          '$age',
        style: TextStyle(
          fontSize: 24,
          color: Colors.black54,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  Widget wdLive(){
    String? live = userMy?.live1;
    return Container(
      child: live == null ? Center()
      : Text(
          live,
        style: TextStyle(
          fontWeight:FontWeight.w600,
          fontSize: 24,
          color: Colors.black54
        ),
      ),
    );
  }

  Widget wdText(){
    return(Container(
      padding: EdgeInsets.all(16),
      child: Text(
        userMy?.profile ?? '初めまして　浅香ひろと申します　この度はプロフィ＝るを見ていただきありがとうがおざいます　そんな僕のことは知らないと思いますが　ここを見てたくさん知っていただけるといいです',
        style: TextStyle(
          fontSize: 14
        ),
      ),
    ));
  }

  Widget wdBtnLogout(){
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.all(8),
      child: ElevatedButton.icon(
        onPressed: logout,
        icon: Icon(
          Icons.logout,
          color: Colors.white,
        ),
        label: Container(
          alignment: Alignment.center,
          width: 70,
          child: Text(
            'ログアウト',
            style: TextStyle(
                color: Colors.white
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey
        ),
      )
    );
  }

  Widget wdBtnDelete(){
    return Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.all(8),
        child: ElevatedButton.icon(
          onPressed: openDialog,
          icon: Icon(
            Icons.delete,
            color: Colors.white,
          ),
          label: Container(
            alignment: Alignment.center,
            width: 70,
            child: Text(
              '削除',
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red
          ),
        )
    );
  }

  static Future<void> init(WidgetRef ref, User? user) async{
    if (user != null) {
      await ref.read(pvUserMy.notifier).setUser(user);
      UserMt.setToken();
    }
    UserMt.mid = user?.uid ?? '';
    UserMt.nameMy = user?.displayName;
    UserMt.urlIconMy = user?.photoURL;
  }

  Future<void> logout() async{
    await auth.signOut();
    UserMt.mid = null;
    UserMt.nameMy = null;
    ref.read(pvUserMy.notifier).logout();
  }

  Future<void> delete() async{
    load.value = true;
    if(await FbMy.delete()){
      await SqMain.deleteTableAll();
      ref.read(pvUserMy.notifier).logout();
    }
    load.value = false;
  }
  void openDialog() {
    showDialog<void>(
      context: context,
      builder: (_){
        return CupertinoAlertDialog(
          title: Text('データを削除しますか？'),
          content: Text('ユーザ、友達、チャットのデータが削除されます。一度削除すると復元はできません。'),
          actions:[
            CupertinoDialogAction(
              child: Text('削除'),
              isDestructiveAction: true,
              onPressed: () {
                delete();
                Navigator.of(context).pop();
              }),
            CupertinoDialogAction(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]
        );
      }
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
