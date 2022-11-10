import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/VwHome.dart';
import 'package:toopdbq/card/VwCard.dart';
import 'package:toopdbq/chat/VwChat.dart';
import 'package:toopdbq/event/VwEventPost.dart';
import 'package:toopdbq/chat/SqChat.dart';
import 'package:toopdbq/my/VwMy.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toopdbq/swichat/VwSwichat.dart';

import 'FbMain.dart';
import 'VwNetworkError.dart';

import 'card/VwMatch.dart';
import 'chat/VwTalk.dart';
import 'my/VwEditProfile.dart';

const Color colorMain = Color.fromRGBO(6, 199, 85, 1);
const LinearGradient gradientMain = LinearGradient(
  begin: FractionalOffset.topRight,
    end: FractionalOffset.bottomLeft,
    colors: [
      Color.fromRGBO(106, 255, 69, 1),
      colorMain,
    ]
);

void appName = 'Toopdbq';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  FlutterAppBadger.updateBadgeCount(1);
  print("バックグラウンドでメッセージを受け取りました");
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,//縦固定
  ]);
  Fb.init(_firebaseMessagingBackgroundHandler);
  runApp(ProviderScope(child: App()));//Scaffold(body: VwMatch());
}
enum AppLifecycleState {
  resumed,
  inactive,
  paused,
  detached,
}

final appLifecycleProvider = Provider<AppLifecycleState>((ref) {
  final observer = _AppLifecycleObserver((value) => ref.state = value);

  final binding = WidgetsBinding.instance..addObserver(observer);
  ref.onDispose(() => binding.removeObserver(observer));

  return AppLifecycleState.resumed;
});

class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver(this._didChangeState);

  final ValueChanged<AppLifecycleState> _didChangeState;

  @override
  void didChangeAppLifecycleState(stateM) {
    late AppLifecycleState state;
    switch(stateM.toString()){
      case 'AppLifecycleState.resumed':
        state = AppLifecycleState.resumed;
        break;
      case 'AppLifecycleState.inactive':
        state = AppLifecycleState.inactive;
        break;
      case 'AppLifecycleState.paused':
        state = AppLifecycleState.paused;
        break;
      case 'AppLifecycleState.detached':
        state = AppLifecycleState.detached;
        break;
    }
    _didChangeState(state);
    super.didChangeAppLifecycleState(stateM);
  }
}

class App extends HookConsumerWidget{
  static Database? sdb;
  late BuildContext context;
  late WidgetRef ref;

  App(){
    initSqlite();
  }

  onResumed() async{
    if(await checkNetwork(context)) {
      FlutterAppBadger.removeBadge();
      VwCard.getMatch(ref);
      VwChat.getChat(ref);
      VwSwichat.resume(ref);
    }
  }

  static Future<bool> checkNetwork(BuildContext context) async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      print(connectivityResult);
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => VwNetworkError(),
        //以下を追加
        fullscreenDialog: true,
      )).then((value){

      });
      return false;
    }else{
      return true;
    }
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    print('build');
    this.context = context;
    this.ref = ref;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        checkNetwork(context);
      }
    });

    ref.listen<AppLifecycleState>(
        appLifecycleProvider,
            (previous, state){
          debugPrint('Previous: $previous, Next: $state');

          switch(state){
            case AppLifecycleState.resumed:
              onResumed();
              break;
            case AppLifecycleState.inactive:
              FlutterAppBadger.removeBadge();
              VwSwichat.inactive(ref);
              break;
            case AppLifecycleState.paused:

              break;
            case AppLifecycleState.detached:

              break;
          }
        }
    );

    return MaterialApp(
        title: 'Toopdbq',
        // theme: ThemeData(
        //     textTheme: GoogleFonts.orbitronTextTheme(
        //       Theme.of(context).textTheme,
        //     )
        // ),
        initialRoute: '/',
        routes: <String,WidgetBuilder> {
          '/talk':(BuildContext context) => VwTalk(),
          '/vwMy':(BuildContext contex) => VwMy(),
          '/editProfile':(BuildContext context) => VwEditProfile(),
          '/vwMatch':(BuildContext context) => VwMatch(),
          '/vwNetworkError':(BuildContext context) => VwNetworkError(),
          '/vwEventPost':(BuildContext context) => VwEventPost(),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) =>
            const Scaffold(body: Center(child: Text('Not Found'))),
          );
        },
        home:Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: null,
            body: VwHome()
        )
    );
  }

  static Future<void> initSqlite() async {
    var databasePath = await getDatabasesPath();
    var path = join(databasePath, 'toopdbq.db');
    const scripts = {
      '5':['CREATE TABLE likeEvent (eid TEXT PRIMARY KEY,time TEXT)'],
      '6':['CREATE TABLE likeUid (uid TEXT PRIMARY KEY,time TEXT)'],
    };
    App.sdb = await openDatabase(
        path,
        version: 6,
        onCreate: (Database db, int version) async {
          await SqChat.create(db);
          await db.execute('CREATE TABLE friend (uid TEXT PRIMARY KEY,time TEXT,new INTEGER)');
          await db.execute('CREATE TABLE metUser (uid TEXT PRIMARY KEY,time TEXT)');
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          for (var i = oldVersion + 1; i <= newVersion; i++) {
            var queries = scripts[i.toString()];
            if(queries != null && queries.isNotEmpty) {
              for (String query in queries) {
                await db.execute(query);
              }
            }
          }
        }
    );
    bool delete = false;
    if(delete){
      await App.sdb!.transaction((txn) async {
        await txn.execute('drop table friend');
        await txn.execute('drop table chat');
        await txn.execute('drop table metUser');
      });
      await deleteDatabase(path);
      return;
    }
  }
}

enum EmStatus{
  network,
  login,
  load,
  start,
}

class NtStatus extends StateNotifier<EmStatus>{
  NtStatus(): super(EmStatus.load);
  void set(EmStatus status){
    state = status;
  }
}

final pvStatus = StateNotifierProvider<NtStatus,EmStatus>((ref){
  return NtStatus();
});



