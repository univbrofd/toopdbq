import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget wdCounter({
  required String text,
  required Color color,
  required IconData icon,
  String? unit,
  required String title,
}){
  return Container(
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 0),
            child: wdCounterContent(title: title,text: text,color: color,unit: unit),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 40,right: 16),
            child: wdCounterName(title: title,color: color),
          ),
          Padding(
            padding: EdgeInsets.only(top: 28),
            child: wdCounterUnit(unit: unit,color: color),
          )
        ],
      )
  );
}

Widget wdCounterContent({
  String? title,
  required String text,
  required Color color,
  String? unit,
}){
  return Container(
      width: 50,
      height: 50,
      margin: EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration:BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              width: 0.5,
              color: Colors.white
          ),
          boxShadow: [BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 3,
            spreadRadius: 1,
          )]
      ),
      child: FittedBox(
        fit: BoxFit.cover,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              height: 1,
              color: Colors.white,
              fontWeight: FontWeight.w900
          ),
        ),
      )
  );
}

Widget wdCounterUnit({String? unit,required Color color}){
  return unit == null ? Container() : Container(
      width: 20,
      height: 20,
      margin: EdgeInsets.only(bottom: 0),
      alignment: Alignment.center,
      decoration:BoxDecoration(
          borderRadius: BorderRadius.circular(100),

          boxShadow: [BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 3,
            spreadRadius: 1,
          )]
      ),
      child: Text(
        unit,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white
        ),
      )
  );
}

Widget wdCounterName({
  String? title,
  required Color color
}){
  return title == null ? Container() : Container(
      padding: EdgeInsets.symmetric(horizontal: 2,vertical: 1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow:[
            BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 2,
                spreadRadius: 0
            )
          ]
      ),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w900
        ),
      )
  );
}