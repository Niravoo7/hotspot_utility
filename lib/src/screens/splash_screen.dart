import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/src/app.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;


  startTime() async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  Future navigationPage() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) =>ParentWidget()));
  }


  @override
  initState() {
    super.initState();
    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: AppConstants.clrBlue,
               ),
            ),
            Column(
              children: <Widget>[
                Flexible(
                  flex: 37,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                Image.asset(AppConstants.img_kowopLogo,color: AppConstants.clrWhite),
                Flexible(
                  flex: 37,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
