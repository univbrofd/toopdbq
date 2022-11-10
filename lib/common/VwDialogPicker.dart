import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/template.dart';

class VwDdialogPicker extends HookConsumerWidget{
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

extension Layout on VwDdialogPicker{
  Widget wdBody(){
    return Container();
  }
}