import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/common/ExDatetime.dart';

import '../common/user.dart';
import '../friend/FbFriend.dart';
import '../friend/VwFriend.dart';
import '../main.dart';
import 'FbCard.dart';
import 'SqCard.dart';
import 'Card.dart';
import 'VwCardItem.dart';

List<StackedCardViewItem> iniListCard = Iterable.generate(100).toList().map((e){
  return StackedCardViewItem(card: null,onSlideComplete: null,onSlideUpdate: null);
}).toList();

class NtCardListCard extends StateNotifier<List<StackedCardViewItem>>{
  NtCardListCard(): super(iniListCard as List<StackedCardViewItem>);

  void init(){
    state = iniListCard;
  }

  void add(List<StackedCardViewItem> list,int index) {
    if(index == 0){
      state = [...list,...state.sublist(list.length,state.length)];
    }else{
      state = [...state.sublist(0,index),...list,...state.sublist(index+list.length,state.length)];
    }
  }

  void setAt(int index,StackedCardViewItem card){
    state[index] = card;
  }

  void reset(){
    state = [];
  }
}

class NtCardListUid extends StateNotifier<List<String>>{
  NtCardListUid(): super([]);

  void set(List list){
    state = [...list];
  }

  void add(List list){
    state = [...state,...list];
  }

  void remove(){
    state.removeAt(0);
  }

  void removeAtFirst(){
    state.removeAt(0);
  }
}

class NtCardDate extends StateNotifier<DateTime?>{
  NtCardDate(): super(null);
  void set(DateTime time){state = time;}
  void pull(){state = DateTime(state!.year,state!.month - 1,state!.day);}
}

class NtCardNumAdd extends StateNotifier<int>{
  NtCardNumAdd(): super(0);
  void set(int num){state = num;}
  void add(int num){state = state + num;}
  void increment(){state = state + 1;}
}

class NtCardIndex extends StateNotifier<int>{
  NtCardIndex(): super(0);
  void set(int index){state = index;}
}

final pvCardListCard = StateNotifierProvider<NtCardListCard,List<StackedCardViewItem>>((ref){return NtCardListCard();});
final pvCardListUid = StateNotifierProvider<NtCardListUid,List<String>>((ref){return NtCardListUid();});
final pvCardDate = StateNotifierProvider<NtCardDate,DateTime?>((ref){return NtCardDate();});
final pvCardNumAdd = StateNotifierProvider<NtCardNumAdd,int>((ref){return NtCardNumAdd();});
final pvCardIndex = StateNotifierProvider<NtCardIndex,int>((ref){return NtCardIndex();});

class VwCard extends HookConsumerWidget{
  List<StackedCard> listCardInit;
  List<String> listUidInit;
  DateTime dateLogInit;

  VwCard({required this.listCardInit,required this.listUidInit,required this.dateLogInit}){
  }
  late WidgetRef ref;
  late BuildContext context;

  late ValueNotifier<double> nextCardScale;
  late ValueNotifier<bool> blockGetMessage;
  late ValueNotifier<bool> blockGetUser;
  late ValueNotifier<bool> blockAddCard;

  Future<void> setCardInit() async{
    List<StackedCardViewItem> listWidget = [];
    for(StackedCard card in listCardInit){
      StackedCardViewItem widget = StackedCardViewItem(card: card, onSlideUpdate: _onSlideUpdate, onSlideComplete: _onSlideComplete);
      listWidget.add(widget);
    }
    ref.read(pvCardListUid.notifier).set(listUidInit);
    ref.read(pvCardListCard.notifier).add(listWidget,0);
    ref.read(pvCardNumAdd.notifier).add(listWidget.length);
    ref.read(pvCardDate.notifier).set(dateLogInit);
    blockGetUser.value = false;
    blockAddCard.value = false;
  }

  static Future<void>getMatch(WidgetRef ref) async{
    bool blockChat = ref.watch(pvBlockFriend);
    if(blockChat || UserMt.mid == null) return;
    ref.read(pvBlockFriend.notifier).set(true);

    await FbFriend.getMatch(callback: (List<String> list) async{
      List<UserMt> listFriendM = [];
      for(String uid in list){
        UserMt user = UserMt(uid);
        await user.getData();
        user.timeMatch = DateTime.now().toFormString();
        listFriendM.add(user);
      }
      ref.read(pvListFriend.notifier).add(listFriendM);
    });
    ref.read(pvBlockFriend.notifier).set(false);
  }

  Future<void> getUser() async {
    DateTime dateLog = ref.watch(pvCardDate)!;
    if(blockGetUser.value || DateTime(2022,7).compareTo(dateLog) > 0)return;
    blockGetUser.value = true;

    final result = await FbCard.getUser(dateLog);
    if (result != null) {
      ref.read(pvCardListUid.notifier).add(result[0]);
    } else {
      print('VwCard getUser No data');
    }
    ref.read(pvCardDate.notifier).pull();
    blockGetUser.value = false;
  }

  Future<void> addCard() async{
    if(blockAddCard.value)return;
    List<StackedCardViewItem> listCard = ref.watch(pvCardListCard);
    List<StackedCardViewItem> listCardM = [];

    List<String> listUid = ref.watch(pvCardListUid);
    List<String> listUidM = listUid;

    int lenListUid = listUid.length;
    int numAddCard = ref.watch(pvCardNumAdd);
    int activeIndex = ref.watch(pvCardIndex);

    int numAddCardM = numAddCard;
    if(numAddCard >= 10 + activeIndex || numAddCardM >= listCard.length) return;
    blockAddCard.value = true;
    while(numAddCardM < 10 + activeIndex  && numAddCardM < listCard.length && listUidM.isNotEmpty){
      if(listUidM.isEmpty)break;
      String uid = listUidM.first;
      listUidM.removeAt(0);
      UserMt user = UserMt(uid);
      await user.getData();
      StackedCard? card = StackedCard.create(user);
      if (user.uid == null || user.urlIcon == null || user.name == null ||
          user.urlPoster == null || user.profile == null || card == null) continue;
      await card.getImgPoster();
      StackedCardViewItem widget = StackedCardViewItem(card: card, onSlideUpdate: _onSlideUpdate, onSlideComplete: _onSlideComplete);
      listCardM.add(widget);
      numAddCardM++;

    }

    if(listCardM.isNotEmpty) ref.read(pvCardListCard.notifier).add(listCardM,numAddCard);
    ref.read(pvCardNumAdd.notifier).set(numAddCardM);
    if(listUidM.length == lenListUid) ref.read(pvCardListUid.notifier).set(listUidM);
    blockAddCard.value = false;
  }

  Future<List> remUserMet(List list) async{
    List listM = list;
    await SqMetUser.getMetUser(callback:  (List<Map> list){
      List<String> listMet = list.map((Map map) => map['uid'] as String).toList();
      if(UserMt.mid != null)listMet.add(UserMt.mid!);
      listM = listM.toSet().difference(listMet.toSet()).toList();
    });
    return listM;
  }

  void resetCard(){
    ref.read(pvCardListCard.notifier).reset();
    ref.read(pvCardNumAdd.notifier).set(0);
    ref.read(pvCardIndex.notifier).set(0);
  }

  void _onSlideComplete(SlideDirection direction){
    int activeIndex = ref.watch(pvCardIndex);
    List<StackedCardViewItem> listCard = ref.watch(pvCardListCard);
    String? uid = listCard[activeIndex].card?.uid;
    if(uid != null)SqMetUser.addMetUser(uid);
    if(activeIndex+1 == listCard.length){
      resetCard();
    }else{
      ref.read(pvCardListCard.notifier).setAt(activeIndex,StackedCardViewItem(card: null,onSlideComplete: null,onSlideUpdate: null));
      ref.read(pvCardIndex.notifier).set(activeIndex+1);
    }
  }

  void _onSlideUpdate(double distance) {
    //nextCardScale.value = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    this.ref = ref;
    this.context = context;
    List<StackedCardViewItem> listCard = ref.watch(pvCardListCard);
    List<String> listUid = ref.watch(pvCardListUid);
    int numAddCard = ref.watch(pvCardNumAdd);
    DateTime? dateLog = ref.watch(pvCardDate);

    nextCardScale = useState(0);
    blockGetMessage = useState(false);
    blockGetUser= useState(true);
    blockAddCard = useState(true);

    WidgetsBinding.instance.addPostFrameCallback((_){
      if(dateLog == null){
        setCardInit();
      }else if(listCard.isEmpty){
        ref.watch(pvCardListCard.notifier).init();
      }else if(listUid.isEmpty){
        getUser();
      }else{
        addCard();
      }
    });

    return Scaffold(
        backgroundColor: Colors.white,
        body:SafeArea(
          child: Column(
            children: <Widget>[
              wdLogo(),
              Expanded(
                  child: Stack(
                      children: listCard.reversed.toList()
                  )
              )
            ],
          ),
        )
    );
  }
  Widget wdLogo(){
    return(Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      margin: EdgeInsets.only(top:4),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed('/vwMy');
            },
            child: glWdIconUser(UserMt.urlIconMy, 36),
          ),
          Spacer(),
          Icon(
            Icons.style,
            color: colorMain,
            size: 24,
          ),
          Text(
            'Toopdbq',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: colorMain,
            ),),
          Spacer(),
          SizedBox(width: 35,)
        ],
      ),
    ));
  }
}