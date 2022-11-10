import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VwLoad extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      // theme: ThemeData(
      //     textTheme: GoogleFonts.orbitronTextTheme(
      //       Theme.of(context).textTheme,
      //     )
      // ),
        home: Scaffold(
            appBar: null,
            body: Stack(
              children: [
                Image.asset('images/back_load.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  margin: EdgeInsets.only(top: 80),
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Toopdbq',
                    textAlign: TextAlign.center,
                    style: TextStyle(//GoogleFonts.orbitron(
                      //textStyle: Theme.of(context).textTheme.headline4,
                      fontSize: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                createProgressIndicator()
              ],
            )
        )
    );
  }
  Widget createProgressIndicator() {
    return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: Colors.white,
        )
    );
  }
}