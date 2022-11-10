import 'package:hooks_riverpod/hooks_riverpod.dart';

class StEvent extends StateNotifier<List<Map>>{
  StEvent(): super([]);

  void set(List<Map> list){
    state = list;
  }

  void add(List<Map> list){
    state = [...state,...list];
  }
}

class StEventLoad extends StateNotifier<bool>{
  StEventLoad(): super(false);

  void set(bool bol){
    state = bol;
  }
}

class StEventLike extends StateNotifier<List<String>>{
  StEventLike(): super([]);

  void set(List<String> list){
    state = list;
  }

  void add(String eid){
    state = [...state,eid];
  }
}

class StEventMy extends StateNotifier<Map?>{
  StEventMy(): super(null);

  void set(Map event){
    state = event;
  }
}

class StEventTag extends StateNotifier<List<String>>{
  StEventTag(): super([]);

  void set(List<String> list){
    state = list;
  }
}

final pvEvent = StateNotifierProvider<StEvent,List<Map>>((ref){return StEvent();});
final pvEventLoad = StateNotifierProvider<StEventLoad,bool>((ref){return StEventLoad();});
final pvEventLike = StateNotifierProvider<StEventLike,List<String>>((ref){return StEventLike();});
final pvEventMy = StateNotifierProvider<StEventMy,Map?>((ref){return StEventMy();});
final pvEventTag = StateNotifierProvider<StEventTag,List<String>>((ref){return StEventTag();});