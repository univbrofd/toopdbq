import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/couple/FbCouple.dart';
import 'package:toopdbq/couple/couple.dart';
import 'package:toopdbq/my/StMy.dart';
import '../main.dart';
import '../swichat/WdSwichat.dart';

class VwCouple extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  Couple couple;
  NetworkImage? imgImage;
  NetworkImage? imgIcon;
  NetworkImage? imgIconM;
  NetworkImage? imgIconF;
  NetworkImage? imgImageM;
  NetworkImage? imgImageF;
  int  mode = 0;
  ScrollController scrollController = ScrollController();

  late ValueNotifier<List<Map>> listMsgUpload;
  late ValueNotifier<List<Map>> listMsgRemove;
  late ValueNotifier<bool> bolOpenChat;

  VwCouple({required this.couple,int? mode}){
    if(mode != null)this.mode = mode;
    if(couple.urlImage != null) {
      imgImage = NetworkImage(couple.urlImage!);
    }
    if(couple.urlIcon != null) {
      imgIcon = NetworkImage(couple.urlIcon!);
    }
    if(couple.userM?.urlIcon != null) {
      imgIconM = NetworkImage(couple.userM!.urlIcon!);
    }
    if(couple.userF?.urlIcon != null) {
      imgIconF = NetworkImage(couple.userF!.urlIcon!);
    }
    if(couple.userM?.urlPoster != null){
      imgImageM = NetworkImage(couple.userM!.urlPoster!);
    }
    if(couple.userF?.urlPoster != null){
      imgImageF = NetworkImage(couple.userF!.urlPoster!);
    }

    if(imgImage == null){
      if(couple.userF?.uid != UserMt.mid && imgIconF != null){
        imgImage = imgImageF;
      }else if( imgIconM != null){
        imgImage = imgImageM;
      }
    }
  }

  void showDialogOpenChat(Function(bool) callback){
    showCupertinoDialog(
        context: context,
        builder: (context){
          return  CupertinoAlertDialog(
              title: Text('オープンチャットを\nONにしますか？'),
              content: Text('\nONにすると、相手はあなたが送った\nメッセージを含めたチャット内容を\n公開することができます。\n\nOFF、相手があなたのメッセージを\n公開することはできません。\n\n*自身のメッセージの公開は自由です。'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OFF'),
                  isDestructiveAction: true,
                  onPressed: () {
                    callback(false);
                    Navigator.pop(context);
                  }
                ),
                CupertinoDialogAction(
                    child: Text('ON'),
                    onPressed: () {
                      callback(true);
                      Navigator.pop(context);
                    },
                ),
              ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;

    listMsgUpload = useState([]);
    listMsgRemove = useState([]);
    bolOpenChat = useState(false);

    useEffect(() => loadImage,[]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: wdBody(),
    );
  }

  void loadImage(){
    if(imgImage != null) precacheImage(imgImage!, context);
    if(imgIcon != null) precacheImage(imgIcon!, context);
    if(imgIconF != null) precacheImage(imgIconF!, context);
    if(imgIconM != null) precacheImage(imgIconM!, context);
  }

  void _onUpload(){
    FbCouple.uploadOpenChat(couple);
  }
}

extension Layout on VwCouple{
  Widget wdBody(){
    return Container(
      child: Stack(
        children: [
          wdImage(),
          wdContent(),
          wdHeader(),
          mode == 1 ? wdBtnPreview() : mode == 2 ? wdBtnUpload() : Container()
        ],
      )
    );
  }

  Widget wdImage(){
    return imgImage == null ? Container() : Container(
      child: Image(
        image:imgImage!,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      )
    );
  }

  Widget wdContent(){
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: SizedBox(height: 56,),
            ),
            wdValue(),
            SizedBox(height: 8),
            wdGrpUser(),
            mode != 1 ? Container() : SizedBox(height: 16),
            mode != 1 ? Container() : wdOpenChat(),
            SizedBox(height: 16),
          ],
        ),
      ),
      couple.listMsg.isEmpty
          ? SliverToBoxAdapter(child: wdListMsgEmpty())
          : wdListMsg(couple.listMsg),
      SliverToBoxAdapter(
          child: couple.listMsg.isEmpty ? Container() : SizedBox(height: 160,)
      ),
    ]);
  }

  Widget wdHeader(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0)
          ]
        )
      ),
      child: SafeArea(child: Row(
        children: [
          wdBtnBack(),
          SizedBox(width: 16,),
          wdIconCp(),
          SizedBox(width: 8,),
          wdNameCp(),
        ],
      )),
    );
  }

  Widget wdBtnBack(){
    return Container(
      width: 48,
      height: 48,
      child: FloatingActionButton(
        onPressed: Navigator.of(context).pop,
        backgroundColor: Colors.white,
        child: Icon(Icons.chevron_left,color: Colors.grey,),
      ),
    );
  }

  Widget wdIconCp(){
    return imgIcon == null
        ? Stack(
            children: [
              Container(
                margin: EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [BoxShadow(
                        blurRadius: 2,
                        spreadRadius: 1,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(1, 0)
                    )]
                ),
                child: glWdIcon(imgIconM,40),
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
                child: glWdIcon(imgIconF,40),
              )
            ],
          )
        : glWdIcon(imgIcon,40);
  }

  Widget wdNameCp(){
    return Container(
      child: Text(
        couple.name ?? '${couple.userF?.name} × ${couple.userM?.name}',
        style: TextStyle(
          shadows: [
            Shadow(
              color: Colors.white,
              blurRadius: 20,
            )
          ],
          color: Colors.black54,
          fontSize: 16,
          fontWeight: FontWeight.w800
        ),
      ),
    );
  }

  Widget wdValue(){
    return Container(
      child: Row(
        children: [
          Spacer(),
          wdTimeElapsed(),
          SizedBox(width:8,),
          wdNumSentences(),
          SizedBox(width:8,),
        ],
      ),
    );
  }

  Widget wdTimeElapsed(){
    int? dayElapsed;
    Couple? couple = ref.watch(pvCoupleMy);
    DateTime? timeMath = couple?.timeMatch;
    if(timeMath != null) {
      dayElapsed = DateTime.now().difference(timeMath).inDays;
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
        text: '${(year == 0 ? '' : '$year月')}${day+1}',
        unit: '日',
        title: '出会って'
    );
  }

  Widget wdNumSentences() => wdCounter(
      color : colorMain,
      icon: Icons.subject,
      text:'${couple.numSentence ?? 0}',
      unit: '回',
      title: 'やりとり'
  );

  Widget wdGrpUser(){
    return Container(
      child: Row(
        children: [
          Spacer(),
          wdUser(image: imgImageF, icon: imgIconF, user: couple.userF,color: Colors.pink),
          Spacer(),
          wdUser(image: imgImageM, icon: imgIconM, user: couple.userM,color: colorMain),
          Spacer(),
        ],
      ),
    );
  }

  Widget wdUser({
    required NetworkImage? image,
    required NetworkImage? icon,
    required UserMt? user,
    required Color color
  }){
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.46,
      height: MediaQuery.of(context).size.width * 0.74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          blurRadius: 4,
          color: Colors.white.withOpacity(0.3),
        )],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          image == null ? Center() : Image(image: image,fit: BoxFit.cover,),
          wdUserContent(icon, user, color),
        ],
      )
      ));
  }
  Widget wdUserContent(NetworkImage? icon,UserMt? user,Color color){
    return Container(
        padding: EdgeInsets.fromLTRB(4, 100, 4, 4),
        decoration: BoxDecoration(
          gradient:LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0),
                color.withOpacity(0.5)
              ]
          ),
        ),
        child:  Column(
          children: [
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                glWdIcon(icon, 40),
                SizedBox(width: 8,),
                Text(user?.name ?? '?????',style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                          blurRadius: 2,
                          color: Colors.white.withOpacity(0.5)
                      )
                    ]
                ))
              ],
            ),
            user?.profile == null ? Container() : Container(
              height: MediaQuery.of(context).size.width * 0.1,
              child: Text(
                user!.profile!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white
                ),
              ),
            )
          ],
        )
    );
  }

  Widget wdListMsgEmpty(){
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(56,MediaQuery.of(context).size.width * 0.2,56,0),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.grey,
              width: 1
          ),
          boxShadow: [BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 3,
              spreadRadius: 1
          )]
      ),
      child: Text(
        'メッセージがありません',
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900
        ),
      ),
    );
  }

  Widget wdListMsg(List<Map> listMsg) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
          return wdRowMsg(listMsg[index]);
      },
      childCount: listMsg.length,
      ),
    );
  }

  Widget wdRowMsg(Map msg)  {
    bool m = msg['uid'] == 'null' ||
        msg['uid'] == null ||
        msg['uid'] == '0' ||
        msg['uid'] == couple.userM?.uid ? true : false;
    return InkWell(
      onTap: (){
        if(mode != 1) {
          return;
        }else if(!m && !couple.openF){
          return;
        }
        if(msg['upload'] == true) {
          if(listMsgRemove.value.contains(msg)) {
            List<Map> list = [...listMsgRemove.value];
            list.remove(msg);
            listMsgRemove.value = list;
          }else {
            listMsgRemove.value = [...listMsgRemove.value,msg];
          }
        } else {
          if(listMsgUpload.value.contains(msg)) {
            List<Map> list = [...listMsgUpload.value];
            list.remove(msg);
            listMsgUpload.value = list;
          }else{
            listMsgUpload.value = [...listMsgUpload.value, msg];
          }
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          m ? Spacer() : Container(),
          (mode != 1 || !m) ? Container() : wdMsgOpen(
              listMsgUpload.value.contains(msg) || msg['upload'] == true
              ? true
              : false
          ),
          Opacity(
            opacity: mode != 1 ? 1 :
            listMsgUpload.value.contains(msg) || msg['upload'] == true ? 1.0 : 0.5,
            child:Container(
                margin: const EdgeInsets.all(4),
                child: m ? wdRowMsgM(msg) : wdRowMsgF(msg)
            )
          ),
          (mode != 1 || m) ? Container() : wdMsgOpen(
              !couple.openF
              ? null
              : listMsgUpload.value.contains(msg) || msg['upload'] == true
                ? true
                : false
          ),
          !m ? Spacer() : Container(),
        ],
      )
    );
  }

  Widget wdRowMsgM(Map msg){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 250),
          child: Text(
              msg['text'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.black
              )
          ),
          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(108, 230, 123, 0.84),
            borderRadius: BorderRadius.circular(20),

          ),
        ),
        SizedBox(width: 6),
        glWdIcon(imgIconM, 40),
        SizedBox(width: 3),
      ],
    );
  }

  Widget wdRowMsgF(Map msg){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 3),
        glWdIcon(imgIconF, 40),
        SizedBox(width: 6),
        Container(
          constraints: BoxConstraints(maxWidth: 250),
          child: Text(
              msg['text'],
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500
                )
          ),
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
    );
  }

  Widget wdMsgOpen(bool? open){
    return mode != 1 ? Container() : Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        boxShadow: [BoxShadow(
          color: open == null
            ? Colors.orange.withOpacity(0.7) : open
            ? colorMain.withOpacity(0.7)
            : Colors.pink.withOpacity(0.7),
          blurRadius: 3,
          spreadRadius: 1
        )]
      ),
      child: open == null
        ? Icon(Icons.lock,color: Colors.white,size: 18,) : open
        ? Icon(Icons.done,color: Colors.white,size: 18,)
        : Icon(Icons.block,color: Colors.white,size: 18,)
    );
  }

  Widget wdOpenChat(){
    Couple? coupe = ref.watch(pvCoupleMy);
    UserMt? userMy = ref.watch(pvUserMy);

    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: bolOpenChat.value ? Colors.white : colorMain,
          width: 0.5
        ),
        boxShadow: [BoxShadow(
          blurRadius: 3,
          spreadRadius: 1,
          color: bolOpenChat.value ? colorMain.withOpacity(0.5) : Colors.white.withOpacity(0.84),
        )]
      ),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 58,
            padding: EdgeInsets.only(left: 0),
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.public,
              size: 38,
              color: bolOpenChat.value ? Colors.white : colorMain.withOpacity(0.84),
            )),
          Spacer(),
          Text('オープンチャット',style: TextStyle(
            color: bolOpenChat.value ? Colors.white : colorMain,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            shadows: bolOpenChat.value ? [Shadow(
              blurRadius: 10,
              color: Colors.white,
            )] : []
          ),),
          Spacer(),
          SizedBox(width: 58,
            child: CupertinoSwitch(
              value: bolOpenChat.value,
              onChanged: (bool bol){
                if(bol){
                  showDialogOpenChat((bool bol){
                    bolOpenChat.value = bol;
                    if(bol) FbCouple.onOpenChat(cid: couple.cid, sex: userMy?.sex, bol: true);
                  });
                }else {
                  bolOpenChat.value = false;
                  FbCouple.onOpenChat(cid: couple.cid, sex: userMy?.sex, bol: false);
                }
              },
              activeColor: colorMain,
              trackColor: colorMain.withOpacity(0.32),
              thumbColor: bolOpenChat.value ? Colors.white : colorMain,
            )
          ),
        ],
      ),
    );
  }

  Widget wdBtnPreview(){
    return SafeArea(child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            Spacer(),
            InkWell(
              onTap: (){
                Couple coupleC = couple;
                couple.fixSex();
                couple.listMsgUpload = listMsgUpload.value;
                couple.listMsgRemove = listMsgRemove.value;
                couple.sortMsgUpload();
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => VwCouple(couple: coupleC,mode: 2,)
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 90),
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withOpacity(0.86),
                        blurRadius: 3,
                        spreadRadius: 1
                    )
                  ],
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    width: 0.36,
                    color: Colors.pink,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.forward,color: Colors.pink,size: 30,),
                    SizedBox(width: 16,),
                    Text(
                      'プレビュー',
                      style: TextStyle(
                          color: Colors.pink.withOpacity(0.86),
                          fontWeight: FontWeight.w900,
                          fontSize: 20
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
    ));
  }

  Widget wdBtnUpload(){
    return SafeArea(child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Spacer(),
          InkWell(
            onTap: _onUpload,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 90),
              padding: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.86),
                    blurRadius: 3,
                    spreadRadius: 1
                  )
                ],
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    width: 0.36,
                    color: Colors.white,
                  ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload,color: Colors.white,size: 30,),
                  SizedBox(width: 16,),
                  Text(
                      couple.listMsg.isEmpty ? '公開' : '更新',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      )
    ));
  }
}