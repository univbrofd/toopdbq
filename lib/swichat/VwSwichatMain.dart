import 'package:toopdbq/Ad/adSwichat.dart';
import 'package:toopdbq/couple/VwCouple.dart';
import 'package:toopdbq/my/StMy.dart';
import 'package:toopdbq/swichat/VwSwichat.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/swichat/StSwichat.dart';
import 'package:toopdbq/swichat/VwSwichatProfile.dart';
import 'package:toopdbq/couple/couple.dart';
import '../chat/SqChat.dart';
import '../main.dart';
import 'WdSwichat.dart';

extension VwSwichatMain on VwSwichat{
  void _onTapTextField(){
    List<int> list = [];
    int i = 0;
    while (i < myController.text.length) {
      i = myController.text.indexOf('\n', i);
      if (i < 0) break;
      list.add(i);
      i++;
    }
    if (list.contains(
        myController.selection.baseOffset + 1)) {
      myController.selection = TextSelection.fromPosition(
          TextPosition(
              offset: myController.selection.baseOffset + 1));
    } else if (myController.selection.baseOffset + 1 ==
        myController.text.length) {
      myController.selection = TextSelection.fromPosition(
          TextPosition(offset: myController.text.length));
    }
  }

  Widget wdMain(){
    return GestureDetector(
      onTap: focusNode.unfocus,
      child: Container(
        child: Stack(
          children: [
            wdTalk(),
            Column(
              children: [
                wdHeader(),
                Spacer(),
                wdInputMsg()
              ],
            ),
          ],
        )
      )
    );
  }

  Widget wdHeader(){
    Couple? couple = ref.watch(pvCoupleMy);
    List<Map> listMsg = ref.watch(pvSwichatListMsg);
    return GestureDetector(
      onTap: (){
        if(couple == null) {
          UserMt? userMy = ref.watch(pvUserMy);
          UserMt? user = ref.watch(pvSwichatUserActive);
          print('$userMy $user ${timeMath.value}');
          if(userMy == null || user == null || timeMath.value == null)return;
          int numSentence =  ref.watch(pvSwichatListMsg).length;
          couple = Couple.fromUser(userM:userMy,userF:user,timeMatch: timeMath.value!,numSentence: numSentence);
        }
        if(couple?.userM?.uid == UserMt.mid){
          couple?.openM = true;
        }else if(couple?.userF?.uid == UserMt.mid){
          couple?.openF = true;
        }
        couple!.listMsg = listMsg;
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => VwCouple(couple: couple!,mode: 1,)
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          )
        ),
        child: SafeArea(
            child: Row(
              children: [
                wdHeaderLeft(),
                Spacer(),
                wdHeaderRight(),
              ],
            )
        )
      )
    );
  }

  Widget wdHeaderLeft(){
    return Container(
      padding: EdgeInsets.only(left: 8),
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: [
          Row(
            children: [
              wdIconCp(),
              SizedBox(
                width: 8,
              ),
              wdNameCp(),
            ],
          )
        ],
      ),
    );
  }

  Widget wdHeaderRight(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        children: [
          Spacer(),
          wdTimeElapsed(),
          SizedBox(width: 4,),
          wdNumSentences(),
          SizedBox(width: 8,),
        ],
      ),
    );
  }

  Widget wdBtnTimeline(){
    return GestureDetector(
      onTap: (){},
      child: Container(
        color: Colors.blue,
        child: Icon(Icons.public),
      ),
    );
  }

  Widget wdIconCp(){
    Couple? couple = ref.watch(pvCoupleMy);
    UserMt? user = ref.watch(pvSwichatUserActive);
    UserMt? userMy = ref.watch(pvUserMy);
    return couple?.urlIcon == null
        ? Stack(
           children: [
             Container(
               margin: EdgeInsets.only(left: 24),
               decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(100),
                   boxShadow: [BoxShadow(
                       blurRadius: 2,
                       spreadRadius: 1,
                       color: Colors.black.withOpacity(0.3),
                       offset: Offset(1, 0)
                   )]
               ),
               child: wdIconUser(userMy?.imgIcon),
             ),
             Container(
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(100),
                   boxShadow: [BoxShadow(
                       blurRadius: 1,
                       spreadRadius: 1,
                       color: Colors.black54,
                     offset: Offset(1, 0)
                   )]
               ),
               child: wdIconUser(user?.imgIcon),
             )
           ],
        )
        : wdIconUser(user?.imgIcon);
  }

  Widget wdNameCp(){
    Couple? couple = ref.watch(pvCoupleMy);
    UserMt? user = ref.watch(pvSwichatUserActive);

    return  Expanded(child: Container(
      child: Text(
        couple?.name ?? '${UserMt.nameMy} × ${user?.name}',
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16
        ),
      ),
    ));
  }

  Widget wdTimeElapsed(){
    int? dayElapsed;
    if(timeMath.value != null) {
      dayElapsed = DateTime.now().difference(timeMath.value!).inDays;
    }

    int year = 0;
    int day = 0;
    if(dayElapsed != null){
      year = dayElapsed ~/ 365;
      day = dayElapsed % 365;
    }

    return wdCounter(
      color: Colors.pink,
      icon: Icons.watch_later_outlined,
      text: '${aniValNumTimeYear.value ?? (year == 0 ? '' : '$year月')}${aniValNumTimeDay.value ?? day+1}',
      unit: '日',
      title: '出会って'
    );
  }

  Widget wdNumSentences() => wdCounter(
      color : colorMain,
      icon: Icons.subject,
      text:'${aniValNumLen.value ?? ref.watch(pvSwichatListMsg).length}',
      unit: '回',
      title: 'やりとり'
  );

  Widget wdNumText() {
    List listMsg = ref.watch(pvSwichatListMsg);
    int numText = 0;
    for(final msg in listMsg){
      try{
        numText += msg['text'].toString().length;
      }catch(e){
        print(e);
      }
    }

    return wdCounter(
      color: Colors.orange,
      icon: Icons.text_fields,
      text:  '${aniValNumText.value ?? numText}',
      unit: '個',
      title:"もじ"
    );
  }

  Widget wdIconUser(NetworkImage? icon){
    UserMt? user = ref.watch(pvSwichatUserActive);
    return GestureDetector(
      onTap: (){
        // if(user == null) return;
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => VwSwichatProfile(user)
        //   //以下を追加
        // )).then((result){
        //   if(result == null)return;
        //   if(result){
        //     //FbCard.like(widget.card!.uid);
        //   }else{
        //     VwSwichat.switchUser(ref);
        //   }
        // });
      },
      child: glWdIcon(icon, 50),
    );
  }

  Widget wdBtnSwicth(){
    return Container(
      height: 40,

      child: FloatingActionButton(
        heroTag: 'swichta btn switch',
        backgroundColor: Colors.red.withOpacity(0.8),
        onPressed: (){
          VwSwichat.switchUser(ref);
        },
        child: Icon(Icons.clear),
      ),
    );
  }

  Widget wdUser(UserMt user){
    return Flexible(child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wdName(user.name),
            wdStatus(user)
          ],
        )),
    );
  }

  Widget wdName(String? name){
    return Container(
      child: Text(
        name ?? '',
        maxLines: 1,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18
        ),
      ),
    );
  }

  Widget wdStatus(UserMt? user){
    int? age;
    if(user?.birthday != null) {
      DateTime birthday = DateTimeExtension.fromString(user!.birthday!);
      age = birthday.getAge();
    }
    return Container(
      child: Row(
        children: [
          wdAge(age),
          SizedBox(width: 8,),
          wdLive(user?.live1),
          SizedBox(width: 8,),
          wdSex(user?.sex),
        ],
      ),
    );
  }

  Widget wdSex(int? sex){
    return Container(
        child: sex == null ? Center() : sex == 0 ? Icon(
          Icons.male_outlined,
          size: 24,
          color: colorMain,
        ) : Icon(
          Icons.female,
          size: 24,
          color: Colors.pink,
        )
    );
  }

  Widget wdAge(int? age){
    return Container(
      child: age == null ? Center()
          : Text(
        '$age',
        style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  Widget wdLive(String? live){
    return Container(
      child: live == null ? Center()
          : Text(
        live,
        style: TextStyle(
            fontWeight:FontWeight.w600,
            fontSize: 18,
            color: Colors.black
        ),
      ),
    );
  }

  Widget wdTalk(){
    return Container(
      margin: EdgeInsets.only(bottom: 56),
      child :wdListMsg(),
    );
  }

  Widget wdListMsg() {
    List<Map> listMsg = ref.watch(pvSwichatListMsg);

    if(listMsg.isNotEmpty) {
      //scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
    Future<void> loadListMsg(String tid) async{
      int? indexBtm = listMsg.last['idx'];
      if(indexBtm != null && indexBtm > 1 && !loadMsgStop.value){
        loadMsgStop.value = true;
        await SqTalk.selectOld(tid, indexBtm, (List<Map> list){
          ref.read(pvSwichatListMsg.notifier).addListOld(list);
        });
        loadMsgStop.value = false;
      }
    }

    return Container(
        child: NotificationListener<ScrollNotification>(
          child: ListView.builder(
              reverse: true,
              controller: scrollController,
              itemCount: listMsg.length,
              itemBuilder: (context, index) {
                return wdRowMsg(listMsg[index]);
              }
          ),
          onNotification: (notification){
            if(scrollController.position.pixels > scrollController.position.maxScrollExtent){
              loadListMsg(tid);
            }
            return false;
          },
        )
    );
  }

  Widget wdRowMsg(Map msg)  {
    return(Container(
        margin: const EdgeInsets.all(4),
        child: (msg['uid'] == 'null' || msg['uid'] == null || msg['uid'] == '0') ?  wdRowMsgMy(msg) : wdRowMsgYou(msg)
    ));
  }

  Widget wdRowMsgMy(Map msg){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        Container(
          constraints: BoxConstraints(maxWidth: 250),
          child: Text(msg['text'],style: TextStyle(
            fontSize: 14,
            color: Colors.black
          )),
          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(108, 230, 123, 0.84),
            borderRadius: BorderRadius.circular(20),

          ),
        ),
        SizedBox(width: 4),
      ],
    );
  }

  Widget wdRowMsgYou(Map msg){
    UserMt? user = ref.watch(pvSwichatUserActive);
    return (Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 3),
        glWdIconUser(user?.urlIcon, 40),
        SizedBox(width: 6),
        Container(
          constraints: BoxConstraints(maxWidth: 250),
          child: Text(msg['text'],style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w500
          )),
          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          decoration: BoxDecoration(
            //color: Color.fromRGBO(255, 255, 255, 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: 0.5
            ),
            boxShadow: [BoxShadow(
              color: Colors.white.withOpacity(0.84),
              blurRadius: 1,
              spreadRadius: 1,
            )]
          ),
        ),
      ],
    ));
  }

  Widget wdIcon(String? url){
    return GestureDetector(
      onTap: (){
        UserMt? user = ref.watch(pvSwichatUserActive);
        if(user == null) return;
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => VwSwichatProfile(user)
          //以下を追加
        )).then((result){
          if(result == null)return;
          if(result){
            //FbCard.like(widget.card!.uid);
          }else{
            VwSwichat.switchUser(ref);
          }
        });
      },
      child: CircleAvatar(
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
          )),
    );
  }

  Widget wdInputMsg() {
    UserMt? user = ref.watch(pvSwichatUserActive);
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4,horizontal: 8),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                wdTextField(),
                SizedBox(width: 12,),
                wdBtnSendMsg(user)
              ],
            )
        );
  }

  Widget wdTextField(){
    return  Flexible(
        child: Container(
          constraints: BoxConstraints(
            minHeight: 40,
            maxHeight: MediaQuery.of(context).size.height * 0.24
          ),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.white,
                    width: 0.5
                ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 2,
                  spreadRadius: 1
                )
              ]
            ),
            child: TextField(
              onTap: _onTapTextField,
              cursorColor: colorMain,
              focusNode: focusNode,
              controller: myController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 100,
              maxLength: 200,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
              ),
              decoration: const InputDecoration(
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(24))
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(24))
                ),
              ),
            ),
          )
    );
  }
  Widget wdBtnSendMsg(UserMt? user){
    return Container(
      width: 40,
      height: 40,
      child: FloatingActionButton(
        heroTag: 'swichat btn sendMsg',
        backgroundColor:Color.fromRGBO(108, 230, 123, 0.84),
        onPressed: (){
          if(UserMt.mid == 'pGg9QKmsymPaxd6whCMx8UMmfXA3') {
            animation();
          }else{
            sendMsg(user?.uid);
          }
        },
        child: const Icon(Icons.send,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void animation() async{
    //AudioPlayer player = AudioPlayer();
    //await player.play(AssetSource('audio/sound_chat.mp3'));
    AdSwichat.animation(key: 'msg',func: (dynamic value) async{
      ref.read(pvSwichatListMsg.notifier).addListNew([value]);
    });
    AdSwichat.animation(key: 'day', func: (dynamic value){
      aniValNumTimeDay.value = value;
    });
    // AdSwichat.animation(key: 'len', func: (dynamic value){
    //   aniValNumLen.value = value;
    // });
    // AdSwichat.animation(key: 'text', func: (dynamic value){
    //   aniValNumText.value = value;
    // });
  }
}

