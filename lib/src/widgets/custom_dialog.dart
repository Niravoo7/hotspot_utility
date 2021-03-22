import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/src/widgets/text_widget.dart';

void showCustomDialog(
    BuildContext context, String title, String message, String btnName,
    {Function onOkClick}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
                height: 200,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                          child: Container(color: Colors.transparent), flex: 5),
                      Container(
                        padding: EdgeInsets.only(left: 25, right: 25),
                        child: TextWidget(title,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.clrBlack,
                            textAlign: TextAlign.center),
                      ),
                      Flexible(
                          child: Container(color: Colors.transparent), flex: 2),
                      Container(
                        padding: EdgeInsets.only(left: 25, right: 25),
                        child: TextWidget(message,
                            fontSize: 16,
                            color: AppConstants.clrBlack,
                            textAlign: TextAlign.center),
                      ),
                      Flexible(
                          child: Container(color: Colors.transparent), flex: 3),
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width,
                        color: AppConstants.clrGrey,
                      ),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: TextWidget(btnName,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.clrBlue,
                              textAlign: TextAlign.center),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          if (onOkClick != null) {
                            onOkClick();
                          }
                        },
                      ),
                    ])));
      });
}
