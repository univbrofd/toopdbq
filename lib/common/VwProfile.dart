import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toopdbq/common/user.dart';

import '../main.dart';
import 'ExDatetime.dart';

class VwProfile extends StatelessWidget{
  UserMt userMt;
  double sizeBtm;
  Widget? actionBtn;
  VwProfile(this.userMt,this.sizeBtm,this.actionBtn);
  @override
  build(BuildContext context){
    return Scaffold(
      body: SingleChildScrollView(
          child: Stack(
            children: [
              wdImage(context),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 1.30,
                  ),
                  Container(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Row(
                        children: [
                          glWdIconUser(userMt.urlIcon,MediaQuery.of(context).size.width * 0.2),
                          Spacer(),
                          actionBtn != null ? actionBtn! : Container(),
                        ],
                      )
                  ),
                  wdName(),
                  wdStatus(),
                  wdProfile(),
                  SizedBox(height: sizeBtm,)
                ],
              ),
            ],
          )
      ),
    );
  }

  Widget wdImage(BuildContext context) {
    return(
        Container(
          child: userMt.urlPoster != null ? Image.network(
            userMt.urlPoster!,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 1.4,
            fit: BoxFit.cover,
          ) :
          Image.asset('images/smpl_poster.jpg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 1.4,
            fit: BoxFit.cover,
          ),
        )
    );
  }
  Widget wdName(){
    return(Container(
      padding: EdgeInsets.fromLTRB(16, 5, 0, 0),
      child: Text(
        userMt.name ?? 'no name',
        maxLines: 1,
        style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700
        ),
      ),
    ));
  }

  Widget wdStatus(){
    return Container(
      padding: EdgeInsets.fromLTRB(16, 4, 8, 0),
      child: Row(
        children: [
          wdSex(),
          SizedBox(width: 8,),
          wdAge(),
          SizedBox(width: 8,),
          wdLive()
        ],
      ),
    );
  }

  Widget wdSex(){
    int? sex = userMt?.sex;
    return Container(
        child: sex == null ? Center() : sex == 0 ? Icon(
          Icons.male_outlined,
          size: 30,
          color: colorMain,
        ) : Icon(
          Icons.female,
          size: 30,
          color: Colors.pink,
        )
    );
  }

  Widget wdAge(){
    int? age;
    if(userMt.birthday != null) {
      DateTime birthday = DateTimeExtension.fromString(userMt!.birthday!);
      age = birthday.getAge();
    }
    return Container(
      child: age == null ? Center()
          : Text(
        '$age',
        style: TextStyle(
            fontSize: 24,
            color: Colors.black54,
            fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  Widget wdLive(){
    String? live = userMt?.live1;
    return Container(
      child: live == null ? Center()
          : Text(
        live,
        style: TextStyle(
            fontWeight:FontWeight.w600,
            fontSize: 24,
            color: Colors.black54
        ),
      ),
    );
  }

  Widget wdProfile(){
    return(Container(
      padding: EdgeInsets.all(16),
      child: Text(
        userMt.profile ?? '初めまして　浅香ひろと申します　この度はプロフィ＝るを見ていただきありがとうがおざいます　そんな僕のことは知らないと思いますが　ここを見てたくさん知っていただけるといいです',
        style: TextStyle(
            fontSize: 16,
          fontWeight: FontWeight.w500
        ),
      ),
    ));
  }
}