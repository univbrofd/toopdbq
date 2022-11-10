import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toopdbq/common/user.dart';
import 'package:toopdbq/event/FbEvent.dart';
import 'package:toopdbq/event/StEvent.dart';
import 'package:toopdbq/common/VwDialogTag.dart';
import 'package:toopdbq/main.dart';

class VwEventPost extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  late ValueNotifier<DateTime?> inpTime;
  late ValueNotifier<int> inpNumMax;
  late TextEditingController conInpPlace;
  late TextEditingController conInpTitle;
  late TextEditingController conInpComment;
  late ValueNotifier<List<String>> listTag;
  late ValueNotifier<String> strListTag;
  late ValueNotifier<bool> activeNum;

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    inpTime = useState(null);
    inpNumMax = useState(2);
    conInpPlace = useTextEditingController();
    conInpTitle = useTextEditingController();
    conInpComment = useTextEditingController();
    listTag = useState([]);
    strListTag = useState('');
    activeNum = useState(false);

    return Stack(
      children: [
        Scaffold(
        appBar: AppBar(
        backgroundColor: colorMain,
          title: Text('イベントを開く',style: TextStyle(
              fontWeight: FontWeight.w600
          ),),
          actions: [
            GestureDetector(
              onTap: () async{
                await _onPost();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 20, 0),
                child: Text('投稿',style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                )
                ),),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: wdBody(),
        ),
        activeNum.value ? wdNumPicker() : Center()
      ],
    );
  }

  void _onTapTime(){
    DatePicker.showDateTimePicker(
        context,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: DateTime.now().add(Duration(days: 365)), onChanged: (date) {
          //print('change $date');
        }, onConfirm: (date) {
          //print('confirm $date');
          inpTime.value = date;
        }, currentTime: DateTime.now(), locale: LocaleType.jp
    );
  }

  void _onTapNum(){
    activeNum.value = true;
  }

  void _onTapTag() async{
    var result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: VwDialogTag(initListTag: listTag.value,numMax: 5,theme: 'event'),
          );
        }
    );

    try{
      listTag.value = result as List<String>;
      strListTag.value = listTag.value.join(' ');
    }catch(e){}
  }

  Future<void> _onPost() async{
    if(conInpTitle.text.isEmpty){
      _onAllert('タイトルを入力してください');
    }else if(inpTime.value == null){
      _onAllert('時間を設定してください');
    }else if(conInpPlace.text.isEmpty){
      _onAllert('場所を入力してください');
    }else if(listTag.value.isEmpty){
      _onAllert('タグを設定してください');
    }else if(conInpTitle.text.isEmpty){
      _onAllert('コメントを入力してください');
    }else{
      Map event = await FbEvent.setEvent(
        title:conInpTitle.text,
        numMax:inpNumMax.value,
        time:inpTime.value!,
        place:conInpPlace.text,
        listTag:listTag.value,
        comment:conInpComment.text
      );
      ref.read(pvEventMy.notifier).set(event);
    }
  }

  void _onAllert(String text){

  }
}

extension Layout on VwEventPost{
  Widget wdBody(){
    return Container(
      child:Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                wdTitle(),
                wdNum(),
                wdTime(),
                wdPlace(),
                wdTag(),
                wdComment()
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget wdTitle(){
    return wdForm(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8,vertical: 0),
          alignment: Alignment.center,
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: conInpTitle,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(0),
              hintText: '${UserMt.nameMy} のイベント',
              border: InputBorder.none
            ),
            inputFormatters: [
              FilteringTextInputFormatter.singleLineFormatter
            ],
          ),
        ),
        icon: Icons.sports_kabaddi,
        label: 'タイトル',
    );
  }
  Widget wdNum(){
    return wdForm(
        child: Container(
          alignment: Alignment.center,
          child: Text(
              inpNumMax.value.toString() + ' 人',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16
            ),
          ),
        ),
        icon: Icons.group,
        label: '参加人数',
        onTap: _onTapNum,
    );
  }

  Widget wdNumPicker(){
    return SafeArea(
      top: false,
      child: Container(
        child:Column(
          children: [
            Expanded(child: GestureDetector(
              onTap: (){
                activeNum.value = false;
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            )),
            Container(
              padding: EdgeInsets.symmetric(vertical: 40),
              width: double.maxFinite,
              color: Colors.white,
              child: NumberPicker(
                value: inpNumMax.value,
                minValue: 2,
                maxValue: 99,
                onChanged: (value){
                  inpNumMax.value = value;
                },
              ),
            )
          ],
        )
      )
    );
  }

  Widget wdTime() {
    String strTime = inpTime.value == null ? 'YY / MM / DD   hh:mm' :
    '${inpTime.value!.year} / ${inpTime.value!.month} / ${inpTime.value!.day}   ${inpTime.value!.hour} : ${inpTime.value!.minute.toString().padLeft(2,'0')}';
    return wdForm(
      onTap: _onTapTime,
      icon: Icons.calendar_month,
      label: '開始時間',
      child: Container(
        alignment: Alignment.center,
        child: Text(strTime,
          style: TextStyle(
              color: inpTime.value == null ? Colors.grey : Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16
          ),
        ),
      )
    );
  }

  Widget wdPlace(){
    return wdForm(
        child: TextField(
          textAlign: TextAlign.center,
          controller: conInpPlace,
          onTap: (){
            List<int> list = [];
            int i = 0;
            while(i < conInpPlace.text.length){
              i = conInpPlace.text.indexOf('\n',i);
              if(i < 0)break;
              list.add(i);
              i++;
            }
            if(list.contains(conInpPlace.selection.baseOffset + 1)){
              conInpPlace.selection = TextSelection.fromPosition(TextPosition(offset: conInpPlace.selection.baseOffset + 1));
            }else if(conInpPlace.selection.baseOffset + 1 == conInpPlace.text.length){
              conInpPlace.selection = TextSelection.fromPosition(TextPosition(offset: conInpPlace.text.length));
            }
          },
          decoration: const InputDecoration(
            hintText: '東京 渋谷 ハチ公前集合',
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
              border: InputBorder.none
          ),
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter
          ],
        ),
        icon: Icons.place,
        label: '開催場所',
        onTap: _onTapNum,
    );
  }

  Widget wdTag(){
    return wdForm(
        onTap: _onTapTag,
        icon: Icons.sell,
        label: 'キーワード',
        child: Container(
          alignment: Alignment.center,
          child: Text(
            strListTag.value,
            maxLines:1,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16
            ),
          ),
        )
    );
  }

  Widget wdComment(){
    return wdForm(
      height: 50,
        onTap: _onTapTag,
        icon: Icons.edit,
        label: 'コメント',
        child: Container(
          alignment: Alignment.center,
          child: TextField(
            controller: conInpComment,
            onTap: (){
              List<int> list = [];
              int i = 0;
              while(i < conInpComment.text.length){
                i = conInpComment.text.indexOf('\n',i);
                if(i < 0)break;
                list.add(i);
                i++;
              }
              if(list.contains(conInpComment.selection.baseOffset + 1)){
                conInpComment.selection = TextSelection.fromPosition(TextPosition(offset: conInpComment.selection.baseOffset + 1));
              }else if(conInpComment.selection.baseOffset + 1 == conInpComment.text.length){
                conInpComment.selection = TextSelection.fromPosition(TextPosition(offset: conInpComment.text.length));
              }
            },
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
                border: InputBorder.none
            ),

          ),
        )
    );
  }

  Widget wdForm({
    required Widget child,
    Function()? onTap,
    required IconData icon,
    required String label,
    Color color = Colors.grey,
    double height = 50
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 16,horizontal: 16),
          child: Column(
            children: [
              Container(
                child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: height
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.fromLTRB(16, 0, 32, 0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.5
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3), //色
                          spreadRadius: 0.5,
                          blurRadius: 4,
                          offset: Offset(1,1),
                        )
                      ]
                  ),
                  child: Row(
                    children: [
                      Icon(icon,color: color,size: 20,),
                      Expanded(child: child),
                    ],
                  )
              ))
            ],
          )
        )
    );
  }

  Widget wdSymbol(IconData icon,Color color,double size){
    return Container(
        width: size,
        height: size,
        child: CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: size * 0.5,
          ),
        )
    );
  }
}