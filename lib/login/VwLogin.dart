import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toopdbq/my/VwMy.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../FbMain.dart';
import '../common/user.dart';
import '../firebase_options.dart';
import 'package:flutter/services.dart';

import '../my/StMy.dart';


class VwLogin extends ConsumerWidget{
  late WidgetRef ref;
  late BuildContext context;

  Future<void> _onSignInWithApple() async {
    UserMt? userMt = ref.watch(pvUserMy);
    try{
      // AuthorizationCredentialAppleIDのインスタンスを取得
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // OAthCredentialのインスタンスを作成
      OAuthProvider oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      if (userMt != null && userMt.isAnonymous()) {
        await ref.read(pvUserMy.notifier).linkWithCredential(credential);
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);
        await Fb.authUser(credential,(User user){
          ref.read(pvUserMy.notifier).setUser(user);
        });
      }
    } catch(e) {
      print(e.toString());
    }
  }

  Future<void> _onSignInGoogle() async {
    try{
      final googleLogin = GoogleSignIn(clientId: DefaultFirebaseOptions.currentPlatform.iosClientId);

      GoogleSignInAccount? signinAccount = await googleLogin.signIn();
      if (signinAccount == null) return;

      GoogleSignInAuthentication auth = await signinAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );
      Fb.authUser(credential, (User user){
        ref.read(pvUserMy.notifier).setUser(user);
      });
      print('login sucsess');
    } catch(e) {
      print('failed login');
      print(e.toString());
    }
  }



  @override
  Widget build(BuildContext context, WidgetRef ref){
    this.ref = ref;
    this.context = context;
    return(MaterialApp(
      title: 'login',
      home: Scaffold(
        body: Stack(
          children: [
            Image.asset('images/back_login.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,),
            Container(
              width: double.maxFinite,
                height: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 9,),
                    Text('トゥープドゥック',
                      style: TextStyle(//GoogleFonts.kaiseiDecol(
                          //textStyle: Theme.of(context).textTheme.headline4,
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w900
                      ),
                    ),
                    Text('Toopdbq',
                      textAlign: TextAlign.center,
                      style: TextStyle(//GoogleFonts.orbitron(
                        //textStyle: Theme.of(context).textTheme.headline4,
                        fontSize: 64,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(flex: 9,),
                    wdBtnLogin(
                      'Googleでログイン','images/logo_google.png',42,Colors.black,Colors.white,_onSignInGoogle
                    ),
                    const Spacer(flex: 1,),
                    wdBtnLogin(
                      'Appleでログイン','images/logo_apple.png',40,Colors.white,Colors.black,_onSignInWithApple
                    ),
                    const Spacer(flex: 3,),
                  ],
                ),

            ),
          ],
        ),
      )
    ));
  }

  Widget wdBtnLogin(
      String title,
      String logo,
      double sizeLogo,
      Color colorText,
      Color colorBack,
      Function() func
      ){
    return GestureDetector(
      onTap: func,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colorBack,
          borderRadius: BorderRadius.circular(10),
        ),
        width: 320,
        height: 60,
        child: Row(
          children: [
            SizedBox(width: 10),
            Image.asset(
              logo,
              width: sizeLogo
            ),
            SizedBox(width: 10),
            Spacer(),
            Container(
              alignment: Alignment.center,
              width: 200,
              child: Text(
                title,
                style: TextStyle(
                    color: colorText,
                    fontSize: 20
                ),),
            ),

            Spacer(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

