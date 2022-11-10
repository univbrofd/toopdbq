import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common/user.dart';

class VwCardMatch extends StatelessWidget{
  UserMt user;
  VwCardMatch(this.user);

  @override
  Widget build(BuildContext context){
    return(Scaffold(
      body: Stack(
        children: [
          wdPoster(),
          wdTitle(),
        ],
      ),
    ));
  }

  Widget wdPoster(){
    return(user.urlPoster == null ? const Center() :
        Image.network(
        user.urlPoster!,
      width: double.maxFinite,
      height: double.maxFinite,
    ));
  }

  Widget wdTitle(){
    return(Container(
      child: Column(
        children: [
          Text("IT'S A"),
          Text('MATCH!')
        ],
      )
    ));
  }
}