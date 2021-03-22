import 'package:flutter/material.dart';
import 'package:hotspotutility/constant.dart';

// ignore: non_constant_identifier_names
Widget PasswordTextFieldWidget(
    TextEditingController controller, bool isVisible, Function onVisibleClick) {
  return Container(
    margin: EdgeInsets.only(top: 5),
    padding: EdgeInsets.only(left: 15),
    decoration: BoxDecoration(
        color: AppConstants.clrWhite,
        border: Border.all(width: 1, color: AppConstants.clrBlack)),
    child: Row(
      children: [
        Flexible(
          child: new TextFormField(
            controller: controller,
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              labelText: "",
              filled: false,
              contentPadding: EdgeInsets.only(left:10,bottom: 12),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            style: TextStyle(fontSize: 18),
            obscureText: (isVisible) ? false : true,
          ),
          flex: 1,
        ),
        GestureDetector(
          child: Container(
            color: Colors.transparent,
            width: 60,height: 50,
            child: Icon(
              (isVisible) ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: AppConstants.clrBlack,
            ),
          ),
          onTap: onVisibleClick,
        )
      ],
    ),
  );
}
