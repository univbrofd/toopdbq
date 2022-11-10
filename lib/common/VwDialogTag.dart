import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toopdbq/FbMain.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/main.dart';

class VwDialogTag extends HookConsumerWidget{
  late BuildContext context;
  late WidgetRef ref;
  late TextEditingController conInpTag;
  late ValueNotifier<List<String>> listTag;
  late ValueNotifier<List<String>> listTagSample;
  late ValueNotifier<Map> mapTagSample;
  final focusNode = FocusNode();

  String theme;
  List<String> initListTag;
  int numMax;

  VwDialogTag({required this.theme,required this.numMax,required this.initListTag});

  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;
    this.ref = ref;
    conInpTag = useTextEditingController();
    listTagSample = useState([]);
    listTag = useState(initListTag);
    mapTagSample = useState({});

    useEffect((){
      getTagFromFb();
    },[]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: wdBody(),
    );
  }

  void getTagFromFb() async{
    Fb.getTag(theme,(Map<String,int> map){
      if(map.isNotEmpty){
        mapTagSample.value = map;
        listTagSample.value = map.keys.toList();
      }
    });
  }

  void _addTag(){
    if(conInpTag.text.isEmpty)return;
    String tagNew = conInpTag.text;
    conInpTag.clear();
    listTag.value = [...listTag.value,tagNew];
  }

  List<String> listTagTest = [
    '映画鑑賞','ダーツ','動物好き','料理','美術鑑賞','ドライブ','食べ歩き',
    '旅行','スノーボード','アウトドア','ゴルフ','カフェ巡り','スポーツ観戦',
    '音楽鑑賞','カラオケ','ファッション','読書','ビリヤード','漫画','ゲーム',
    'ランニング','登山','サイクリング','カメラ','バイク','釣り','サバゲー',
    'ダンス','楽器','DIY','インテリア','プラモデル','スポーツ','ダイビング','サーフィン',
  ];

  void _onSave() async{
    String strTime = DateTime.now().toFormString();
    final prefs = await SharedPreferences.getInstance();
    String? strTimeBefore = prefs.getString('saveTime$Theme');
    if(strTimeBefore == null || int.parse(strTime) - int.parse(strTimeBefore) > 1000000000) {
      Fb.addTag(theme,listTag.value);
      prefs.setString('saveTime$Theme', strTime);
    }
    Navigator.of(context).pop(listTag.value);
  }
}

extension Layout on VwDialogTag{
  Widget wdBody(){
    return Focus(
      focusNode: focusNode,
      child: GestureDetector(
        onTap: (){
          focusNode.unfocus();
        },
        child: Container(
          child: Stack(
            children: [
              wdMain(),
              wdSearch()
            ],
          ),
        )
      )
    );
  }
  Widget wdMain(){
    return Container(
      child: Column(
        children: [
          wdTitle(),
          wdListTag(),
          wdListTagSample(),
        ],
      ),
    );
  }

  Widget wdTitle(){
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            'Select Tags',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w900,
              fontSize: 18
            ),
          ),
          SizedBox(width: 16,),
          Text('${listTag.value.length} / $numMax',style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: listTag.value.length == numMax ? Colors.grey : colorMain
          ),),
          Spacer(),
          wdBtnSave()
        ]
      )
    );
  }
  Widget wdBtnSave(){
    return InkWell(
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 0),
        child: FloatingActionButton.extended(
          backgroundColor: colorMain,
            onPressed: _onSave,
            label: Text(
              '保存',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16
              ),
            ),
        )
      ),
    );
  }

  Widget wdListTag(){
    return Container(
      height: 56,
      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
      alignment: Alignment.centerLeft,
      child: listTag.value.isEmpty ? wdRowListTag(tag: 'タグ',color: Colors.black12):
      ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: listTag.value.length,
        itemBuilder: (context,index){
          String tag = listTag.value[index];
          return wdRowListTag(tag: tag,color: colorMain);
        },
      )
    );
  }

  Widget wdListTagSample(){
    return Flexible(child: Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 100),
      width: double.maxFinite,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Colors.grey
          )
        )
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: listTagSample.value.map((tag) => wdRowListTag(tag: tag,border: true)).toList(),
        ),
      ),
    ));
  }

  Widget wdRowListTag({required String tag,bool border = false,Color? color}){
    return InkWell(
      onTap: (){
        var listTagC = listTag.value;
        var listTagSampleC = listTagSample.value;
        if(listTag.value.contains(tag) && listTag.value.isNotEmpty){
          listTagC.remove(tag);
          listTag.value = listTagC;
          listTagSample.value = [tag,...listTagSample.value];
        }else if(listTag.value.length < numMax){
          listTagSampleC.remove(tag);
          listTagSample.value = listTagSampleC;
          listTag.value = [tag,...listTag.value];
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: !border ? null : Border.all(
            color: Colors.grey,
            width: 2
          )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color == null ? Colors.grey : Colors.white
              ),
            ),
            Text(
              '  (${mapTagSample.value[tag] ?? 0}) ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color == null ? Colors.grey : Colors.white
              ),
            )
          ],
        )
      )
    );
  }

  Widget wdSearch(){
    return  Column(
        children: [
          Spacer(),
          Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(220, 220, 220, 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 3.0,
                      spreadRadius: 1.0,
                    )
                  ]
              ),
              padding: EdgeInsets.fromLTRB(18, 8, 12, 4),
              child: SafeArea(
                  top: false,
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
          )
      ]
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