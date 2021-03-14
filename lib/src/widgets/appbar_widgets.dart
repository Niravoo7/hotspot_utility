import 'package:flutter/material.dart';
import 'package:hotspotutility/constant.dart';

// ignore: non_constant_identifier_names
Widget CommonAppBar(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: 28),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    height: 60,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
            onTap: () {
            //  Navigator.pop(context);
            },
            child: Image.asset(
              AppConstants.img_chevronLeftSolid,
              color: AppConstants.clrBlue,
            )),
        Image.asset(AppConstants.img_kowopLogo, color: AppConstants.clrBlue),
      ],
    ),
  );
}
