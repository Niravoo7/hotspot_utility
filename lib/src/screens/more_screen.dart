import 'package:flutter/material.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/src/widgets/custom_dialog.dart';
import 'package:hotspotutility/src/widgets/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppConstants.clrWhite,
        /*appBar: AppBar(
          actions: <Widget>[],
        ),*/
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50, bottom: 30),
                    child: Image.asset(
                      AppConstants.img_kowopLogo,
                      height: 50,
                      color: AppConstants.clrBlue,
                    ),
                  ),
                  onTap: () {
                    /*showCustomDialog(
                        context,
                        "Cannot Connect to Network",
                        "Please check your password and try to connect again.",
                        "OK");*/
                  },
                ),
                TextWidget(AppConstants.strHotspotSetup,
                    color: AppConstants.clrGreen,
                    fontSize: AppConstants.size_double_extra_large1,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center),
                Padding(
                  padding: EdgeInsets.only(top: 25, bottom: 35),
                  child: TextWidget(AppConstants.strVersion,
                      color: AppConstants.clrBlack,
                      fontSize: AppConstants.size_large,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center),
                ),
                GestureDetector(
                  onTap: () {
                    launch('https://github.com/kent-williams/hotspot-utility');
                  },
                  child: TextWidget(AppConstants.strOriginalCode,
                      color: AppConstants.clrBlue,
                      fontSize: AppConstants.size_large,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 25),
                  child: TextWidget(AppConstants.strCopyright,
                      color: AppConstants.clrBlack,
                      fontSize: AppConstants.size_medium_large,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center),
                ),
                TextWidget(AppConstants.strCopyrightDetail,
                    color: AppConstants.clrBlack,
                    fontSize: AppConstants.size_medium,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                    height: 1.50),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: GestureDetector(
                    onTap: () {
                      launch('https://kowop.com/support');
                    },
                    child: TextWidget(AppConstants.strSupportLink,
                        color: AppConstants.clrBlue,
                        fontSize: AppConstants.size_medium_large,
                        fontWeight: FontWeight.normal,
                        textAlign: TextAlign.center),
                  ),
                ),
              ],
              /* children: ListTile.divideTiles(context: context, tiles: [
                ListTile(title: Text('Version'), trailing: Text("0.1.3")),
                ListTile(
                  title: Text('Source Code - Git Hub'),
                  onTap: () {
                    launch('https://github.com/Niravoo7/hotspot_utility');
                  },
                ),
              ]).toList(),*/
            ),
          ),
        ));
  }
}
