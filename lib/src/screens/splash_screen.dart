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
        context, MaterialPageRoute(builder: (context) => ParentWidget()));
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
        body: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: AppConstants.clrBlue,
          ),
          child: Image.asset(AppConstants.img_logo),
        ),
      ),
    );
  }
}
