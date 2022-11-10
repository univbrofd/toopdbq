import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toopdbq/card/VwCard.dart';
import 'package:toopdbq/common/ExDatetime.dart';

import '../main.dart';

Widget glWdLoad(){
  return Container(
    color: Colors.transparent,
    width: double.maxFinite,
    height: double.maxFinite,
    child: Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: colorMain,
        )
    ),
  );
}
