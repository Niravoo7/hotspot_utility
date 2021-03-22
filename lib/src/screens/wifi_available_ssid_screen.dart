import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/gen/hotspotutility.pb.dart' as protos;
import 'package:hotspotutility/src/app.dart';
import 'package:hotspotutility/src/screens/wifi_connect_screen.dart';
import 'package:hotspotutility/src/widgets/appbar_widgets.dart';
import 'package:hotspotutility/src/widgets/text_widget.dart';

class WifiAvailableScreen extends StatefulWidget {
  const WifiAvailableScreen(
      {Key key,
      this.currentWifiSsid,
      this.device,
      this.wifiServicesChar,
      this.wifiConfiguredServicesChar,
      this.wifiSsidChar,
      this.wifiConnectChar,
      this.wifiRemoveChar})
      : super(key: key);
  final String currentWifiSsid;
  final BluetoothDevice device;
  final BluetoothCharacteristic wifiServicesChar;
  final BluetoothCharacteristic wifiConfiguredServicesChar;
  final BluetoothCharacteristic wifiSsidChar;
  final BluetoothCharacteristic wifiConnectChar;
  final BluetoothCharacteristic wifiRemoveChar;

  _WifiAvailableScreenState createState() => _WifiAvailableScreenState();
}

class _WifiAvailableScreenState extends State<WifiAvailableScreen> {
  StreamController<List<String>> wifiSsidListStreamController =
      StreamController<List<String>>();

  List<String> configuredSsidResults;

  @override
  void dispose() {
    super.dispose();
    wifiSsidListStreamController.close();
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    wifiSsidListStreamController.add([]);

    widget.wifiConfiguredServicesChar.read().then((value) {
      configuredSsidResults =
          protos.wifi_services_v1.fromBuffer(value).services.toList();

      widget.wifiServicesChar.read().then((value) {
        if (new String.fromCharCodes(value) != "failed") {
          var availableSsidResults =
              protos.wifi_services_v1.fromBuffer(value).services;
          wifiSsidListStreamController.add(availableSsidResults);
        }
      });
    }).catchError((e) {
      print("Error: wifiConfiguredServices Failure: ${e.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar(context,() {

          Navigator.pop(context);

        }),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                alignment: Alignment.center,
                child: TextWidget(
                  "AVAILABLE NETWORKS",
                  color: AppConstants.clrGreen,
                  fontSize: AppConstants.size_double_extra_large,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                )),
            Container(
              margin:  EdgeInsets.only(top: 15,left: 10,right: 10),
              child: StreamBuilder<List<String>>(
                  stream: wifiSsidListStreamController.stream,
                  initialData: [],
                  builder: (c, snapshot) {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.only(
                                left: 25, right: 25, top: 10, bottom: 10),
                            width: MediaQuery.of(context).size.width,
                            child: Row(children: [
                              Image.asset(
                                AppConstants.img_wifi,
                                height: 20,
                                color: snapshot.data[index].toString() ==
                                        widget.currentWifiSsid
                                    ? AppConstants.clrBlue
                                    : AppConstants.clrGrey,
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child: Text(snapshot.data[index].toString())),
                              Flexible(
                                  child: Container(
                                color: Colors.transparent,
                              )),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: AppConstants.clrBlue,
                              )
                            ]),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return WifiConnectScreen(
                                  currentWifiSsid: widget.currentWifiSsid,
                                  device: widget.device,
                                  wifiNetworkSelected:
                                      snapshot.data[index].toString(),
                                  wifiSsidChar: widget.wifiSsidChar,
                                  wifiConfiguredServices: configuredSsidResults,
                                  wifiConnectChar: widget.wifiConnectChar,
                                  wifiRemoveChar: widget.wifiRemoveChar);
                            }));
                          },
                        );
                      },
                    );
                  }),
            ),
          ],
        )));
  }
}
