import 'package:hooks_riverpod/hooks_riverpod.dart';

class StListLikeUid extends StateNotifier<List<String>>{
  StListLikeUid(): super([]);

  void add(List<String> list){
    state = [...state,...list];
  }

}

final pvListLikeUid = StateNotifierProvider<StListLikeUid,List<String>>((ref) => StListLikeUid());