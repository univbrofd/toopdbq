import '../main.dart';

class SqMain{
  static Future<void> deleteTableAll() async{
    print('deleteTableAll');
    var list = (await App.sdb!.rawQuery('SELECT * FROM sqlite_master WHERE TYPE="table" '));
    print(list.toString());
    for(Map map in list){
      String table = map['name'];
      await App.sdb!.delete(table);
    }
  }
}