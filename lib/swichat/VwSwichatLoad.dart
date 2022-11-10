import 'package:shared_preferences/shared_preferences.dart';
import 'package:toopdbq/swichat/StSwichat.dart';
import 'package:toopdbq/swichat/VwSwichat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'FbSwichat.dart';

extension VwSwichatMain on VwSwichat{

  void _onBlock() async{
    VwSwichat.timerSwichat?.cancel();
    FbSwichat.deleteLog();
    VwSwichat.setBlock(ref, true);
    VwSwichat.removeUser(ref);
  }

  Widget wdLoad(){
    return SafeArea(child: Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Spacer(),
          Text(
            "チャット相手を探しています。",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600
            ),
          ),
          SizedBox(height: 50,),
          CircularProgressIndicator(
            color: colorMain,
          ),
          Spacer(),
          wdBtnBlock(),
          Spacer(),
        ],
      ),
    ));
  }

  Widget wdBtnBlock(){
    return Container(
      child: ElevatedButton(
        onPressed: _onBlock,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Background color
        ),
        child: Text(
          'キャンセル',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black
          ),
        ),
      ),
    );
  }
}