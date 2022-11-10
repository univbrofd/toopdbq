
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/friend/FbFriend.dart';
import 'package:toopdbq/friend/SqFriend.dart';
import 'package:toopdbq/friend/VwFriendProfile.dart';

import '../common/VwCommon.dart';
import 'VwFriendRow.dart';

class StListFriend extends StateNotifier<List<UserMt>?>{
  StListFriend(): super(null);

  void set(List<UserMt> list){
    state = list;
  }

  void add(List<UserMt> list){
    if(state == null){
      state = list;
    }else if(list.isNotEmpty){
      state = [...list,...state!];
    }
  }
}
class StBlockFriend extends StateNotifier<bool>{
  StBlockFriend():super(false);
  void set(bool bol){
    state = bol;
  }
}

final pvListFriend = StateNotifierProvider<StListFriend,List<UserMt>?>((ref){return StListFriend();});
final pvBlockFriend = StateNotifierProvider<StBlockFriend,bool>((ref) => StBlockFriend());

class VwFriend extends HookConsumerWidget{
  late WidgetRef ref;
  late List<UserMt>? listFriend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    this.ref = ref;
    listFriend = ref.watch(pvListFriend);

    useEffect((){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getMatch(ref);
      });
    },[]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: listFriend == null ? glWdLoad() :
            (listFriend!.isEmpty) ? wdEmpty() : wdListFriend()
      )
    );
  }

  Future<void>getMatch(WidgetRef ref) async{
    bool blockChat = ref.watch(pvBlockFriend);
    if(blockChat || UserMt.mid == null) return;
    ref.read(pvBlockFriend.notifier).set(true);

    await FbFriend.getMatch();
    getFriend(ref);
  }

  Future<void> getFriend(WidgetRef ref) async{
    List<UserMt>? listFriend = ref.watch(pvListFriend);
    UserMt? userTop;
    String? strTimeTop;
    try{
      userTop = listFriend?.first;
      strTimeTop = userTop?.timeMatch;
    }catch(e){
      print(e);
    }

    List<Map> list = await SqFriend.selectAll(strTimeTop);
    List<UserMt> listFriendM = [];
    for(Map map in list){
      UserMt user = UserMt(map['uid']);
      await user.getData();
      user.timeMatch = map['time'];
      listFriendM.add(user);
      SqFriend.updateCheck(map['uid']);
    }
    ref.read(pvBlockFriend.notifier).set(false);
    ref.read(pvListFriend.notifier).add(listFriendM);
  }

  Widget wdEmpty(){
    return Container(
      alignment: Alignment.center,
      child: Text('まだ、友達がいません')
    );
  }

  Widget wdListFriend(){
    return ListView.builder(
      itemCount: listFriend!.length,
      itemBuilder: (context, index){
        UserMt user = listFriend![index];
        return Container(
            margin: const EdgeInsets.all(8),
            child: InkWell(
                onTap: (){
                  Navigator.push (context, MaterialPageRoute(
                    builder: (context) => VwFriendProfile(user),
                    //以下を追加
                    fullscreenDialog: true,
                  ));
                },
                child: VwFriendRow(user),
            ),
        );
      },
    );
  }
}
