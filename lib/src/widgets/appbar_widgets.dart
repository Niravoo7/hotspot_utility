import 'package:flutter/material.dart';
import 'package:hotspotutility/constant.dart';

// ignore: non_constant_identifier_names
Widget CommonAppBar(BuildContext context,Function onBackPress) {

  return AppBar(
    titleSpacing: 0.0,
    backgroundColor: AppConstants.clrWhite,
    elevation: 1,
    automaticallyImplyLeading: false,
    title: Container(
      padding: EdgeInsets.only(right: 20),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: onBackPress,
              child: Container(
                color: Colors.transparent,
                padding:EdgeInsets .all(15),
                child: Image.asset(
                  AppConstants.img_chevronLeftSolid,
                  color: AppConstants.clrBlue,
                ),
              )),
          Container(padding: EdgeInsets.symmetric(vertical: 12),child: Image.asset(AppConstants.img_kowopLogo, color: AppConstants.clrBlue)),
        ],
      ),
    ),
  );


}
