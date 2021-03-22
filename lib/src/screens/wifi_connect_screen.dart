import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/gen/hotspotutility.pb.dart' as protos;
import 'package:hotspotutility/src/widgets/appbar_widgets.dart';
import 'package:hotspotutility/src/widgets/button_widget.dart';
import 'package:hotspotutility/src/widgets/custom_dialog.dart';
import 'package:hotspotutility/src/widgets/password_text_field_widget.dart';
import 'package:hotspotutility/src/widgets/text_widget.dart';

class WifiConnectScreen extends StatefulWidget {
  const WifiConnectScreen(
      {Key key,
      this.currentWifiSsid,
      this.device,
      this.wifiNetworkSelected,
      this.wifiSsidChar,
      this.wifiConfiguredServices,
      this.wifiConnectChar,
      this.wifiRemoveChar})
      : super(key: key);
  final String currentWifiSsid;
  final BluetoothDevice device;
  final String wifiNetworkSelected;
  final BluetoothCharacteristic wifiSsidChar;
  final List<String> wifiConfiguredServices;
  final BluetoothCharacteristic wifiConnectChar;
  final BluetoothCharacteristic wifiRemoveChar;

  _WifiConnectScreenState createState() => _WifiConnectScreenState();
}

class _WifiConnectScreenState extends State<WifiConnectScreen> {
  List<int> availableSsidResults;

  // Initially password is obscure
  bool _obscureText = true;
  StreamController<String> wifiConnectionStatusStreamController =
      StreamController<String>.broadcast();
  StreamController<bool> wifiConnectionSuccessStreamController =
      StreamController<bool>();
  bool _seenConnecting = false;

  bool isPasswordVisible = false;

  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    wifiConnectionStatusStreamController.close();
    wifiConnectionSuccessStreamController.close();

    widget.wifiSsidChar.setNotifyValue(false).then((value) {
      print("WiFi SSID Char Notification Enabled Result: " + value.toString());

      widget.wifiConnectChar.setNotifyValue(false).then((value) {
        print("WiFi Connect Char Notification Enabled Result: " +
            value.toString());
      });
    });
  }

  @protected
  @mustCallSuper
  void initState() {
    if (widget.currentWifiSsid == widget.wifiNetworkSelected) {
      wifiConnectionStatusStreamController.add('Connected');
      wifiConnectionSuccessStreamController.add(true);
    } else {
      wifiConnectionStatusStreamController.add('');
      wifiConnectionSuccessStreamController.add(false);
    }
  }

  readChars(List<BluetoothCharacteristic> chars) async {
    await Future.forEach(chars, (char) async {
      await char.read();
    });
  }

  _writeWifiCredentials(String password) async {
    var wifiCredentials = protos.wifi_connect_v1.create();
    var wifiSsidRemove = protos.wifi_remove_v1.create();

    wifiCredentials.service = widget.wifiNetworkSelected;
    wifiCredentials.password = password;

    print("current WiFi ssid: " + widget.currentWifiSsid);

    widget.wifiSsidChar.setNotifyValue(true).then((value) {
      print("WiFi SSID Char Notification Enabled Result: " + value.toString());

      widget.wifiConnectChar.setNotifyValue(true).then((value) {
        print("WiFi Connect Char Notification Enabled Result: " +
            value.toString());

        if (widget.currentWifiSsid != "" && widget.currentWifiSsid != null) {
          // Remove Currently Connected WiFi Network
          wifiSsidRemove.service = widget.currentWifiSsid;
          print("network to remove: " + wifiSsidRemove.service.toString());
          widget.wifiRemoveChar
              .write(wifiSsidRemove.writeToBuffer())
              .then((value) {
            print("Remove Current WiFi SSID Write Result: " + value.toString());

            // Check if there are any other WiFi Configure Services
            print("Configured Services: " +
                widget.wifiConfiguredServices.toString());

            // Check if any WiFi Networks are already Configured
            if (widget.wifiConfiguredServices.length > 0) {
              // Remove WiFi Configured Services
              wifiSsidRemove.service = widget.wifiConfiguredServices[0];
              print("configured network to remove: " +
                  wifiSsidRemove.service.toString());
              widget.wifiRemoveChar
                  .write(wifiSsidRemove.writeToBuffer())
                  .then((value) {
                print("Remove Configured WiFi SSID Write Result: " +
                    value.toString());

                // Connect to new WiFi Network
                wifiConnectionStatusStreamController.add("Connecting...");
                widget.wifiConnectChar
                    .write(wifiCredentials.writeToBuffer())
                    .then((value) {
                  print("WiFi Connect Char Result: " + value.toString());

                  // Wait for connection result
                  StreamSubscription<String> subscription;
                  subscription = wifiConnectionStatusStreamController.stream
                      .listen((value) {
                    if (value.toLowerCase() == "failed") {
                      subscription.cancel();
                      // Remove WiFi Network After Failure
                      var wifiSsidRemove = protos.wifi_remove_v1.create();
                      wifiSsidRemove.service = widget.wifiNetworkSelected;
                      print("network to remove after failure 1: " +
                          wifiSsidRemove.service.toString());
                      widget.wifiRemoveChar
                          .write(wifiSsidRemove.writeToBuffer())
                          .then((value) {});

                      showCustomDialog(
                          context,
                          "Cannot Connect to Network",
                          "Please check your password and try to connect again.",
                          "OK");
                    }else if(value.toLowerCase() == "success" || value.toLowerCase() == "connected" ){
                      showCustomDialog(
                          context,
                          "Success!",
                          "You have connected to your WiFi network.",
                          "OK",onOkClick: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      });
                    }else{
                      print("else -> $value");
                    }

                  });
                });
              });
            } else {
              // Connect to new WiFi Network
              wifiConnectionStatusStreamController.add("Connecting...");
              widget.wifiConnectChar
                  .write(wifiCredentials.writeToBuffer())
                  .then((value) {
                print("WiFi Connect Char Result: " + value.toString());

                // Wait for connection result
                StreamSubscription<String> subscription;
                subscription =
                    wifiConnectionStatusStreamController.stream.listen((value) {
                  if (value.toLowerCase() == "failed") {
                    subscription.cancel();
                    // Remove WiFi Network After Failure
                    var wifiSsidRemove = protos.wifi_remove_v1.create();
                    wifiSsidRemove.service = widget.wifiNetworkSelected;
                    print("network to remove after failure 2: " +
                        wifiSsidRemove.service.toString());
                    widget.wifiRemoveChar
                        .write(wifiSsidRemove.writeToBuffer())
                        .then((value) {});

                    showCustomDialog(
                        context,
                        "Cannot Connect to Network",
                        "Please check your password and try to connect again.",
                        "OK");
                  }else if(value.toLowerCase() == "success" || value.toLowerCase() == "connected" ){
                    showCustomDialog(
                        context,
                        "Success!",
                        "You have connected to your WiFi network.",
                        "OK",onOkClick: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    });
                  }else{
                    print("else -> $value");
                  }

                    });
              });
            }
          });
        } else {
          //
          // Check if there are any other WiFi Configure Services
          print("Configured Services: " +
              widget.wifiConfiguredServices.toString());

          // Check if any WiFi Networks are already Configured
          if (widget.wifiConfiguredServices.length > 0) {
            // Remove WiFi Configured Services
            wifiSsidRemove.service = widget.wifiConfiguredServices[0];
            print("configured network to remove: " +
                wifiSsidRemove.service.toString());
            widget.wifiRemoveChar
                .write(wifiSsidRemove.writeToBuffer())
                .then((value) {
              print("Remove Configured WiFi SSID Write Result: " +
                  value.toString());

              // Connect to new WiFi Network
              wifiConnectionStatusStreamController.add("Connecting...");
              widget.wifiConnectChar
                  .write(wifiCredentials.writeToBuffer())
                  .then((value) {
                print("WiFi Connect Char Result: " + value.toString());

                // Wait for connection result
                StreamSubscription<String> subscription;
                subscription =
                    wifiConnectionStatusStreamController.stream.listen((value) {
                  if (value.toLowerCase() == "failed") {
                    subscription.cancel();
                    // Remove WiFi Network After Failure
                    var wifiSsidRemove = protos.wifi_remove_v1.create();
                    wifiSsidRemove.service = widget.wifiNetworkSelected;
                    print("network to remove after failure 3: " +
                        wifiSsidRemove.service.toString());
                    widget.wifiRemoveChar
                        .write(wifiSsidRemove.writeToBuffer())
                        .then((value) {});


                    showCustomDialog(
                        context,
                        "Cannot Connect to Network",
                        "Please check your password and try to connect again.",
                        "OK");

                  }else if(value.toLowerCase() == "success" || value.toLowerCase() == "connected" ){
                    showCustomDialog(
                        context,
                        "Success!",
                        "You have connected to your WiFi network.",
                        "OK",onOkClick: (){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    });
                  }else{
                    print("else -> $value");
                  }

                    });
              });
            });
          } else {
            // Connect to new WiFi Network
            wifiConnectionStatusStreamController.add("Connecting...");
            widget.wifiConnectChar
                .write(wifiCredentials.writeToBuffer())
                .then((value) {
              print("WiFi Connect Char Result: " + value.toString());

              // Wait for connection result
              StreamSubscription<String> subscription;
              subscription =
                  wifiConnectionStatusStreamController.stream.listen((value) {
                if (value.toLowerCase() == "failed") {
                  subscription.cancel();
                  // Remove WiFi Network After Failure
                  var wifiSsidRemove = protos.wifi_remove_v1.create();
                  wifiSsidRemove.service = widget.wifiNetworkSelected;
                  print("network to remove after failure 4: " +
                      wifiSsidRemove.service.toString());
                  widget.wifiRemoveChar
                      .write(wifiSsidRemove.writeToBuffer())
                      .then((value) {});

                  showCustomDialog(
                      context,
                      "Cannot Connect to Network",
                      "Please check your password and try to connect again.",
                      "OK");
                }else if(value.toLowerCase() == "success" || value.toLowerCase() == "connected" ){
                  showCustomDialog(
                      context,
                      "Success!",
                      "You have connected to your WiFi network.",
                      "OK",onOkClick: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                  });
                }else{
                  print("else -> $value");
                }


              });
            });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context,() {

        Navigator.pop(context);

      }),
      body: Column(children: <Widget>[
        Container(
            padding: const EdgeInsets.only(top: 15, bottom: 5),
            child: TextWidget(
              "CONNECT TO NETWORK",
              color: AppConstants.clrGreen,
              fontSize: AppConstants.size_double_extra_large,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            )),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10.0, left: 30.0, right: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<bool>(
                    stream: wifiConnectionSuccessStreamController.stream,
                    initialData: false,
                    builder: (c, snapshot) {
                      return Image.asset(
                        AppConstants.img_wifi,
                        height: 30,
                        color: (snapshot.data == true)
                            ? AppConstants.clrBlue
                            : AppConstants.clrGrey,
                      );
                    }),
                SizedBox(width: 20,),
                Text(
                  widget.wifiNetworkSelected,
                  style: TextStyle(fontSize: 22),
                ),  SizedBox(width: 20,),
                StreamBuilder<String>(
                    stream: wifiConnectionStatusStreamController.stream,
                    initialData: "",
                    builder: (c, snapshot) {
                      if(snapshot.data=="Connecting...")
                        {
                          return Container(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation(Colors.grey),
                            ),
                          );
                        }else{
return Container(width: 40,height: 40,);
                      }

                    }),
              ],
            )),

        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 30,left: 30),
          child: TextWidget(
            "Password",
            color: AppConstants.clrBlack,
            fontSize: 16
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 30,right: 30),
          child: PasswordTextFieldWidget(passwordController, isPasswordVisible, () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          }),
        ),
        StreamBuilder<List<int>>(
            stream: widget.wifiSsidChar.value,
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              if (snapshot.hasData) {
                print("WiFi SSID: " + new String.fromCharCodes(snapshot.data));
                return Container();
              } else
                return Container();
            }),
        StreamBuilder<List<int>>(
            stream: widget.wifiConnectChar.value,
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              if (snapshot.hasData) {
                print(
                    "WiFi Connect: " + new String.fromCharCodes(snapshot.data));
                if ("connected" == new String.fromCharCodes(snapshot.data) &&
                    _seenConnecting) {
                  wifiConnectionStatusStreamController.add("Connected");
                  wifiConnectionSuccessStreamController.add(true);
                  _seenConnecting = false;
                } else if ("not_found" ==
                        new String.fromCharCodes(snapshot.data) ||
                    "error" == new String.fromCharCodes(snapshot.data) ||
                    "failed" == new String.fromCharCodes(snapshot.data) ||
                    "invalid" == new String.fromCharCodes(snapshot.data)) {
                  wifiConnectionStatusStreamController.add("Failed");
                  wifiConnectionSuccessStreamController.add(false);
                } else if ("connecting" ==
                    new String.fromCharCodes(snapshot.data)) {
                  _seenConnecting = true;
                }
                return Container();
              } else
                return Container();
            }),
        Container(
          margin: const EdgeInsets.only(top: 30, left: 30.0, right: 30.0),
          child: ButtonWidget(
              context,
              "CONNECT",
              () => _writeWifiCredentials(passwordController.text),
              AppConstants.clrGreen,
              null),
        ),
        /*Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10.0, left: 40.0, right: 40.0),
            child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text(
                  "Back to Hotspots",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button
                      .copyWith(color: Colors.black),
                )))*/
      ]),
    );
  }
}
