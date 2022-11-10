import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VwNetworkError extends ConsumerWidget{
  late BuildContext context;
  @override
  Widget build(BuildContext context,WidgetRef ref){
    this.context = context;

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        Navigator.of(context).pop();
      }
    });

    return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          children: [
            Spacer(),
            Text('インターネットに\n接続されていません',
              textAlign: TextAlign.center,
              style: TextStyle(

                  color: Colors.grey,
                  fontSize: 20
              ),),
            Spacer(),
          ],
        )
    );
  }
  Future<void> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print(connectivityResult);
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => VwNetworkError(),
        fullscreenDialog: true,
      ));
    }
  }
}