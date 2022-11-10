import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toopdbq/common/ExDatetime.dart';

import 'common/user.dart';
import 'firebase_options.dart';

final auth = FirebaseAuth.instance;
final refFdb = FirebaseDatabase.instance.ref();
final messaging = FirebaseMessaging.instance;
final storage = FirebaseStorage.instance;
final refRsr = storage.ref();
final store = FirebaseFirestore.instance;

class Fb{
  static Future<void> init(Future<void> Function(RemoteMessage) _firebaseMessagingBackgroundHandler) async{
    print('firebase init');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
    await messaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true,);
    await messaging.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> authUser(OAuthCredential credential,Function(User) callback) async{
    await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      String uid = user.uid;
      refFdb.child('user/$uid/$uid').set(user.uid);
      callback(user);
    }
  }

  static getTag(String theme,Function(Map<String,int>) callback) async{
    print('getTag');
    final docRef = store.collection("tag").doc(theme);
    docRef.get().then((DocumentSnapshot doc) {
      Map<String, int> data = Map<String, int>.from(doc.data() as Map);
        callback(data);
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  static addTag(String theme,List<String> list){
    print('Fb addTag');
    store.collection('tag').doc(theme).get().then((value){
      Map<String, int> data = Map<String, int>.from(value.data() as Map);
      for(String tag in list){
        data[tag] = (data[tag] ?? 0) + 1;
      }
      store.collection('tag').doc(theme).set(data);
    });
  }
}
