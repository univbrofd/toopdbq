import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/event/FbEvent.dart';
import 'package:toopdbq/main.dart';
import 'package:toopdbq/template.dart';

import '../common/user.dart';
import '../friend/VwFriendProfile.dart';

class VwEventListLike extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  String eid;
  late ValueNotifier<List<String>> listUid;

  VwEventListLike(this.eid);

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    listUid = useState([]);

    useEffect((){
      getListUid();
    },[]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorMain,
        title: Text(
            'いいねしたユーザー',
          style: TextStyle(
            fontWeight: FontWeight.w700
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: wdBody(),
    );
  }

  Future<void> getListUid() async{
    listUid.value = await FbEvent.getListLike(eid);
  }
}

extension Layout on VwEventListLike{
  Widget wdBody(){
    return Container(
      child: ListView.builder(
          itemCount: listUid.value.length,
          itemBuilder: (context,index){
            String uid = listUid.value[index];
            return VwEventRowListLike(uid);
          }),
    );
  }
}

class VwEventRowListLike extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  String uid;
  late ValueNotifier<UserMt?> user;

  VwEventRowListLike(this.uid);

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    user = useState(null);

    useEffect((){
      UserMt user = UserMt(uid);
      user.getData(callback: (UserMt user){
        this.user.value = user;
      });
    },[]);

    return wdBody();
  }
}

extension LayoutRow on VwEventRowListLike{
  Widget wdBody(){
    return user.value == null ? Center() : GestureDetector(
      onTap: (){
        Navigator.push (context, MaterialPageRoute(
          builder: (context) => VwFriendProfile(user.value!),
          //以下を追加
          fullscreenDialog: true,
        ));
      },
      child: Container(
        margin: EdgeInsets.all(8),
        child: Row(
          children: [
            wdIcon(user.value!.urlIcon),
            wdContent(user.value!)
          ],
        ),
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
}