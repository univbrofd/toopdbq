import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Vw extends HookConsumerWidget{
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

extension Layout on Vw{
  Widget wdBody(){
    return Container();
  }
}