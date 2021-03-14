
import 'package:flutter/material.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/src/widgets/text_widget.dart';

// ignore: non_constant_identifier_names
Widget ButtonWidget(BuildContext context, String name, Function onClick,Color bgColor,Widget icon) {
  return ButtonTheme(
    minWidth: MediaQuery.of(context).size.width,
    height: 60,
  // shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
    child: FlatButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: onClick,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon !=null? icon:Container(height: 1),
          TextWidget(name,
              color: AppConstants.clrWhite,
              fontSize: AppConstants.size_double_extra_large,
              fontWeight: FontWeight.bold),
        ],
      ),
      color:bgColor,
    ),
  );
}
