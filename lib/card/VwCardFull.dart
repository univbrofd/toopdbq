import 'package:flutter/material.dart';
import '../common/VwProfile.dart';
import '../common/user.dart';
import 'Card.dart';

class VwCardFull extends StatelessWidget{
  StackedCard card;
  Function(SlideDirection)? onFromExternal;
  VwCardFull({required this.card, this.onFromExternal});
  late BuildContext context;

  @override
  Widget build(BuildContext context){
    this.context = context;
    return(Scaffold(
      body:Stack(
        children: [
          VwProfile(card.user,100,wdActionBtnUp()),
          Column(
            children: [
              Spacer(),
              wdRowBtn(),
            ],
          )
        ],
      )
    ));
  }

  Widget wdActionBtnUp(){
    return(FloatingActionButton(
      heroTag: 'card btn up',
      onPressed: (){
        Navigator.pop(context,null);
      },
      backgroundColor: Colors.lightBlue,
      child: Icon(
          Icons.arrow_drop_up_outlined,
        color: Colors.white,
        size: 50,
      ),
    ));
  }

  Widget wdRowBtn(){
    return(Container(
      color: Colors.transparent,
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          Spacer(),
          wdBtnNope(),
          Spacer(),
          wdBtnLike(),
          Spacer()
        ],
      ),
    ));
  }

  Widget wdBtnLike(){
    return(FloatingActionButton(
        heroTag: 'cardFull btn like',
        onPressed:(){
          if(onFromExternal != null) onFromExternal!(SlideDirection.Right);
          Navigator.pop(context,true);
        },
        backgroundColor: Colors.greenAccent,
        child: Icon(
          Icons.favorite,
          color: Colors.white,
          size: 30,
        )
    ));
  }

  Widget wdBtnNope(){
    return(FloatingActionButton(
      heroTag: 'card btn nope',
      onPressed:(){
        if(onFromExternal != null) onFromExternal!(SlideDirection.Left);
        Navigator.pop(context,false);
      },
        backgroundColor: Colors.pink,
      child: Icon(
        Icons.close_outlined,
        color: Colors.white,
        size: 30,
      )
    ));
  }
}
