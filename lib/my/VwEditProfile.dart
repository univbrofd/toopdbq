
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toopdbq/common/ExDatetime.dart';
import 'package:toopdbq/main.dart';

import '../common/user.dart';
import 'StMy.dart';
import 'FbMy.dart';

class VwEditProfile extends HookConsumerWidget{
  late TextEditingController conTextName;
  late TextEditingController conTextProfile;
  late BuildContext context;
  late ValueNotifier<File?> cropPoster;
  late ValueNotifier<File?> cropIcon;
  late WidgetRef ref;
  late UserMt userMy;
  late ValueNotifier<bool> loading;
  late ValueNotifier<DateTime?> birthday;
  late ValueNotifier<int?> sex;
  late ValueNotifier<int> sexTarget;
  late ValueNotifier<String?> live1;
  late ValueNotifier<String?> live2;
  late ValueNotifier<String?> live3;

  Future onTapIcon() async{
    if(loading.value)return;
    loading.value = true;
    File? file = await getImage(200,200);
    if(file != null) {
      cropIcon.value = await _cropImage(file,const CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
    }
    loading.value = false;
  }
  Future onTapImage() async{
    if(loading.value)return;
    loading.value = true;
    File? file = await getImage(1500,3000);
    if(file != null) {
      cropPoster.value = await _cropImage(file,const CropAspectRatio(ratioX: 1.0, ratioY: 1.6));
    }
    loading.value = false;
  }

  _onTapBirthday() async{

    DatePicker.showDatePicker(
        context,
        showTitleActions: true,
        minTime: DateTime(1900),
        maxTime: DateTime.now(),
        onChanged: (date) {
          //print('change $date');
        }, onConfirm: (date) {
          //print('confirm $date');
          birthday.value = date;
        },
        currentTime: birthday.value ?? DateTime.now(),
        locale: LocaleType.jp
    );
  }

  _onTapSex(BuildContext context) async{
    Picker picker = Picker(
        adapter: PickerDataAdapter<String>(
          pickerdata: [['未設定','男','女']],
          isArray: true
        ),
        selecteds: [
          sex.value == null ? 0 : (sex.value! + 1),
        ],
        changeToFirst: false,
        textAlign: TextAlign.left,
        textStyle: TextStyle(color: Colors.blue,),
        selectedTextStyle: TextStyle(
            color: Colors.red,
          fontSize: 20
        ),
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          int result = value[0];
          if(result == 0){
            sex.value = null;
          }else{
            sex.value = result - 1;
          }
        });
    picker.showBottomSheet(context);
  }

  _onTapSexTarget(BuildContext context) async{
    Picker picker = Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: [['異性','同性']],
            isArray: true,
        ),
        selecteds: [
          sexTarget.value
        ],
        changeToFirst: false,
        textAlign: TextAlign.left,
        textStyle: TextStyle(color: Colors.blue,),
        selectedTextStyle: TextStyle(
            color: Colors.red,
            fontSize: 20
        ),
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          int result = value[0];
          sexTarget.value = value[0];
        });
    picker.showBottomSheet(context);
  }

  List<String> listLive1 = ['未設定', '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県', '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県', '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県', '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府','兵庫県', '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県', '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県',];

  _onTapLive(BuildContext context) async{
    Picker picker = Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: [listLive1],
            isArray: true
        ),
        selecteds: [
          live1.value == null ? 0 : (listLive1.indexOf(live1.value!)),
        ],
        changeToFirst: false,
        textAlign: TextAlign.left,
        textStyle: TextStyle(color: Colors.blue,),
        selectedTextStyle: TextStyle(
            color: Colors.red,
            fontSize: 20
        ),
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          if(value[0] == 0){
            live1.value = null;
          }else {
            live1.value = picker.getSelectedValues()[0];
          }
        });
    picker.showBottomSheet(context);
  }

  Future<File?> getImage(double width,double height) async{
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: width,
        maxHeight: height
    );
    if(pickedImage == null)return null;
    return File(pickedImage.path);
  }

  Future<void> save() async{
    bool update = false;
    UserMt? userMyC = ref.watch(pvUserMy);
    if(userMyC == null)return;
    //String cho = 'pGg9QKmsymPaxd6whCMx8UMmfXA3';
    //final snap = await refFdb.child('user/$cho/cho').get();
    //List list = snap.value as List;
    //if(list.contains(UserMt.mid)){
      //userMyC.uid = 'cho_${DateTime.now().toFormString()}';
    //}
    if(userMyC.uid == null) return;
    if(cropPoster.value != null){
      update = true;
      EmUser em = EmUser.urlPoster;
      FbMy.setImage(cropPoster.value!, userMyC.uid!,em,(String url){
        FbMy.setData(url, userMyC.uid!, strEmUser(em));
      });
    }

    if(cropIcon.value != null){
      update = true;
      EmUser em = EmUser.urlIcon;
      FbMy.setImage(cropIcon.value!, userMyC.uid!,em,(String url){
        FbMy.setData(url, userMyC.uid!, strEmUser(em));
      });
    }

    if(userMyC.name != conTextName.text){
      update = true;
      String name = conTextName.text;
      userMyC.name = name;
      FbMy.setData(name, userMyC.uid!, 'name');
    }

    if(userMyC.profile != conTextProfile.text){
      update = true;
      String profile = conTextProfile.text;
      userMyC.profile = profile;
      FbMy.setData(profile, userMyC.uid!, 'profile');
    }

    if(birthday.value != null) {
      String strBirthday = birthday.value!.toFormString();
      if (userMyC.birthday != strBirthday) {
        update = true;
        userMyC.birthday = strBirthday;
        FbMy.setData(strBirthday, userMyC.uid!, 'birthday');
      }
    }

    if (userMyC.sex != sex.value) {
      update = true;
      userMyC.sex = sex.value;
      FbMy.setData(sex.value, userMyC.uid!, 'sex');
    }

    if(userMyC.sexTarget != sexTarget.value){
      update = true;
      userMyC.sexTarget = sexTarget.value;
      FbMy.setData(sexTarget.value, userMyC.uid!, 'sexTarget');
    }

    if (userMyC.live1 != live1.value) {
      update = true;
      userMyC.live1 = live1.value;
      FbMy.setData(live1.value, userMyC.uid!, 'live1');
    }

    if(!update)return;
    if(userMyC.uid == UserMt.mid){
      ref.read(pvUserMy.notifier).set(userMyC);
    }else{
      FbMy.setData(userMyC.uid!, userMyC.uid!, 'uid');
      if(UserMt.tokenMy != null) FbMy.setData(UserMt.tokenMy!, userMyC.uid!, 'token');
      FbMy.setLog(uidM: userMyC.uid);
    }
  }

  Future<File?> _cropImage(File imageFile,CropAspectRatio ratio) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: ratio,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if(croppedFile == null){
      return null;
    }else{
      File file = File(croppedFile.path);
      return file;
    }
  }

  @override
  Widget build(BuildContext context,WidgetRef ref){
    userMy = ModalRoute.of(context)?.settings.arguments as UserMt;
    this.context = context;
    this.ref = ref;
    cropPoster = useState(null);
    cropIcon = useState(null);
    loading = useState(false);
    conTextName = useTextEditingController(text: userMy.name ?? '');
    conTextProfile = useTextEditingController(text: userMy.profile ?? '');
    birthday = useState(
        userMy.birthday == null ? null :
        DateTimeExtension.fromString(userMy.birthday!)
    );
    sex = useState(userMy.sex);
    sexTarget = useState(userMy.sexTarget ?? 0);
    live1 = useState(userMy.live1);
    live2 = useState(userMy.live2);
    live3 = useState(userMy.live3);

    return Stack(
        children:[
          Scaffold(
            appBar: AppBar(
              backgroundColor: colorMain,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: (){
                  Navigator.pop(context,userMy);
                },
              ),
              title: const Text('編集',style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
              ),),
              actions: [
                Padding(padding: const EdgeInsets.fromLTRB(0, 14, 20, 0),
                child: GestureDetector(
                  onTap: () async{
                    await save();
                    ref.read(pvMyReload.notifier).toggle();
                    Navigator.pop(context,[cropIcon.value,cropPoster.value]);
                  },
                  child: const Text('保存',style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                  ),),
                ),
                )
              ],
            ),
            body: wdProfile()
          ),
          loading.value ? wdLoad() : Center(),
        ]
      );
  }

  Widget wdProfile(){
    String strSex = '未設定';
    if(sex.value == 0){
      strSex = '男';
    }else if(sex.value == 1){
      strSex = '女';
    }
    String strSexTarget = '未設定';
    if(sexTarget.value == 0){
      strSexTarget = '異性';
    }else if(sexTarget.value == 1){
      strSexTarget = '同性';
    }

    return Container(
      color: const Color.fromRGBO(245, 245, 245, 1),
      child: SingleChildScrollView(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            wdImage(context),
            wdIconName(context),
            wdBirthday(),
            wdFormStatus('性別', strSex, _onTapSex),
            sex.value != null ? wdFormStatus('恋愛対象', strSexTarget, _onTapSexTarget) : Center(),
            wdFormStatus('居住地', live1.value ?? '未設定', _onTapLive),
            wdTitle('自己紹介'),
            wdProfileText(),
            SizedBox(height: 200,)
          ],
        ),
      ),
    );
  }

  Widget wdTitle(String title){
    return(Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
      child: Text(title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800
      ),),
    ));
  }

  Widget wdIcon(BuildContext context) {
    return(GestureDetector(
      onTap: onTapIcon,
      child: Container(
        margin: const EdgeInsets.all(10),
        child: wdIconB(userMy.urlIcon,MediaQuery.of(context).size.width * 0.16),
      ),
    ));
  }

  Widget wdIconB(String? url,double size){
    try{
      return(SizedBox(
          height: size,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: cropIcon.value != null ? Image.file(
                  cropIcon.value!,
                width: MediaQuery.of(context).size.width * 0.16,
                height: MediaQuery.of(context).size.width * 0.16,
                fit: BoxFit.cover,
              ) :
              Image.network(
                url!,
                width: MediaQuery.of(context).size.width * 0.16,
                height: MediaQuery.of(context).size.width * 0.16,
                fit: BoxFit.cover,
              )
          ))
      );
    }catch(e){
      return(const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xff94d500),
        child: Icon(
          Icons.person,
          color: Colors.black,
        ),
      ));
    }
  }

  Widget wdImage(BuildContext context) {
    return(GestureDetector(
      onTap: onTapImage,
      child: Container(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: cropPoster.value != null ? Image.file(
              cropPoster.value!,
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7 * 1.6,
              fit: BoxFit.cover,
            ) :
            userMy.urlPoster != null ? Image.network(
                userMy.urlPoster!,
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7 * 1.6,
              fit: BoxFit.cover,
            ) : Image.asset('images/smpl_poster.jpg',
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7 * 1.6,
              fit: BoxFit.cover,
            ),
          )
      ),
    ));
  }

  Widget wdIconName(BuildContext context){
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          wdIcon(context),
          wdName(),
        ],
      ),
    );
  }

  Widget wdName(){
    return Expanded(child:Container(
      color: Colors.white,
      width: double.maxFinite,
      child:  TextField(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600
        ),
        controller: conTextName,
        onTap: (){
          List<int> list = [];
          int i = 0;
          while(i < conTextName.text.length){
            i = conTextName.text.indexOf('\n',i);
            if(i < 0)break;
            list.add(i);
            i++;
          }
          if(list.contains(conTextName.selection.baseOffset + 1)){
            conTextName.selection = TextSelection.fromPosition(TextPosition(offset: conTextName.selection.baseOffset + 1));
          }else if(conTextName.selection.baseOffset + 1 == conTextName.text.length){
            conTextName.selection = TextSelection.fromPosition(TextPosition(offset: conTextName.text.length));
          }
        },
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: 'なまえ',
          border: InputBorder.none
        ),
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter
        ],
      ),
    ));
  }

  Widget wdProfileText(){
    return(Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      color: Colors.white,
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: TextField(
        controller: conTextProfile,
        onTap: (){
          List<int> list = [];
          int i = 0;
          while(i < conTextProfile.text.length){
            i = conTextProfile.text.indexOf('\n',i);
            if(i < 0)break;
            list.add(i);
            i++;
          }
          if(list.contains(conTextProfile.selection.baseOffset + 1)){
            conTextProfile.selection = TextSelection.fromPosition(TextPosition(offset: conTextProfile.selection.baseOffset + 1));
          }else if(conTextProfile.selection.baseOffset + 1 == conTextProfile.text.length){
            conTextProfile.selection = TextSelection.fromPosition(TextPosition(offset: conTextProfile.text.length));
          }
        },
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: const InputDecoration(
            border: InputBorder.none
        ),

      ),
    ));
  }

  Widget wdBirthday(){

    return GestureDetector(
      onTap: _onTapBirthday,
      child: Container(
        margin: EdgeInsets.only(top: 16),
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Text(
                '正年月日',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            ),
            Spacer(),
            Text(
              birthday.value == null
                ? '未設定'
                : "${birthday.value!.year}/${birthday.value!.month.toString().padLeft(2,"0")}/${birthday.value!.day.toString().padLeft(2,'0')}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget wdFormStatus(String title,String value,Function(BuildContext) func){
    return Builder(builder: (context) => GestureDetector(
      onTap: (){
        func(context);
      },
      child: Container(
        margin: EdgeInsets.only(top: 16),
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Text(
                title,
              style: TextStyle(
                  fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            ),
            Spacer(),
            Text(value,style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600
            ),),
          ],
        ),
      ),
    ));
  }

  Widget wdLoad(){
    return Container(
      color: Colors.transparent,
      width: double.maxFinite,
      height: double.maxFinite,
      child: createProgressIndicator(),
    );
  }

  Widget createProgressIndicator() {
    return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: Color.fromRGBO(255, 70, 0, 1),
        )
    );
  }
}