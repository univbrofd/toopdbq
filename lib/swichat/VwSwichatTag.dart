import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toopdbq/common/VwCommon.dart';

import '../common/VwDialogTag.dart';
import '../main.dart';
import 'SqSwichat.dart';
import 'VwSwichat.dart';

extension VwSwichatTag on VwSwichat{

  void _addTag(){
    if(conInpTag.text.isEmpty)return;
    String tagNew = conInpTag.text;
    conInpTag.clear();
    if(!listTag.value.contains(tagNew)) {
      listTag.value = [...listTag.value, tagNew];
    }
  }

  void _onTapTag() async {
    var result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: VwDialogTag(initListTag: listTag.value,theme: 'swichat',numMax: 20),
          );
        }
    );
    print('swichat newListTag num ${result}');
    if(result != null) {
      SqSwichat.setTag(result);
      listTag.value = [...result];
    }
  }

  Widget wdTag() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wdTitleTag(),
          wdToolTag(),

        ],
      ),
    );
  }

  Widget wdToolTag(){
    return Container(
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          wdListTag(),
          SizedBox(width: 16,),
          wdBtnEditTag(),
        ],
      ),
    );
  }

  Widget wdTitleTag(){
    return Container(
      child: Text(
        '興味のあるタグ',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900
        ),
      ),
    );
  }

  Widget wdBtnEditTag(){
    return GestureDetector(
      onTap: _onTapTag,
      child: Container(
        child: Icon(Icons.settings,size: 32,color: Colors.white,),
      ),
    );
  }

  Widget wdListTag() {
    return Expanded(child: Container(
        height: 46,
        alignment: Alignment.centerLeft,
        child: listTag.value.isEmpty ? wdRowListTag(
            tag: '未設定', color: Colors.black12) :
        ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listTag.value.length,
          itemBuilder: (context, index) {
            String tag = listTag.value[index];
            return wdRowListTag(tag: tag);
          },
        )
    ));
  }

  Widget wdRowListTag({required String tag,bool border = false,Color? color}){
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white,
              width: 1
          )
      ),
      child: Text(
        tag,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white
        ),
      ),
    );
  }

  Widget wdTagEdit(){
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          wdTopBarTag(),
          wdSearch(),
          listTagSample.value.isEmpty ? glWdLoad() :
          wdListTagSample(listTagSample.value),
        ],
      ),
    );
  }

  Widget wdTopBarTag(){
    return Container(
      margin: EdgeInsets.all(8),
      width: 100,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(100)
      ),
    );
  }

  Widget wdListTagSample(List listTagSampleM){
    return Container(
      padding: EdgeInsets.all(8),
      width: double.maxFinite,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          for(String tag in listTagSampleM)
            wdRowListTagSample(tag: tag,)
        ]
      ),
    );
  }

  Widget wdRowListTagSample({required String tag}){
    return InkWell(
        onTap: (){
          var listTagC = listTag.value;
          var listTagSampleC = mapTagSample.value.keys;
          if(listTag.value.contains(tag)){
            listTagC.remove(tag);
            listTag.value = listTagC;
          }else if(listTag.value.length < 5){
            listTag.value = [tag,...listTag.value];
          }
        },
        child: Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: listTag.value.contains(tag) ? colorMain : Colors.grey,
              borderRadius: BorderRadius.circular(10),
              border: listTag.value.contains(tag) ? null : Border.all(
                  color: Colors.grey,
                  width: 2
              )
          ),
          child: Text(
            tag,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: listTag.value.contains(tag)  ? Colors.grey : Colors.white
            ),
          ),
        )
    );
  }

  Widget wdSearch(){
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: Offset(0,3),
                color: Colors.black12,
                blurRadius: 1.0,
                spreadRadius: 1.0,
              )
            ]
        ),
        padding: EdgeInsets.fromLTRB(18, 8, 12, 4),
        child: SafeArea(
            bottom: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                wdSearchText(),
                SizedBox(width: 4,),
                Container(
                  child: IconButton(
                      onPressed: _addTag,
                      icon: Icon(
                        Icons.add_circle,
                        color: colorMain,
                        size: 34,
                      )
                  ),
                )
              ],
            )
        )
    );
  }

  Widget wdSearchText(){
    return Flexible(
        child:Container(
          child:  TextField(
            controller: conInpTag,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 16),
              fillColor: Colors.white,
              filled: true,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.5,
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.5,
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
            ),
          ),
        )
    );
  }
}