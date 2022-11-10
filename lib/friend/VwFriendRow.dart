import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/user.dart';

class VwFriendRow extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  UserMt userInit;
  late ValueNotifier<UserMt> user;

  VwFriendRow(this.userInit);

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    user = useState(userInit);

    useEffect(() => user.value.getData,[]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: wdBody(),
    );
  }
}

extension Layout on VwFriendRow{
  Widget wdBody(){
    return user.value.name == null ? Container(): Container(
      child: Row(
        children: [
          wdIcon(user.value.urlIcon),
          wdContent(user.value)
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
}