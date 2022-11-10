import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VwSwichatMatch extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;

    return Scaffold(
      backgroundColor: Colors.white,
      body: wdBody(),
    );
  }
}

extension Layout on VwSwichatMatch{
  Widget wdBody(){
    return Container();
  }
}