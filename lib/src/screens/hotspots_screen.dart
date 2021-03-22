import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/src/screens/hotspot_screen.dart';
import 'package:hotspotutility/src/widgets/appbar_widgets.dart';
import 'package:hotspotutility/src/widgets/bluetooth_device_widgets.dart';
import 'package:hotspotutility/src/widgets/button_widget.dart';
import 'package:hotspotutility/src/widgets/text_widget.dart';

import 'package:flutter/services.dart';

final List<Guid> scanFilterServiceUuids = [
  Guid('0fda92b2-44a2-4af2-84f5-fa682baa2b8d')
];

class HotspotsScreen extends StatelessWidget {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          return FindDevicesScreen();
        });
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);
  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state.toString().substring(15)}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key key}) : super(key: key);

  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}

/*Stream<List<ScanResult>> getScanResults() {
  return Stream.fromFuture(Future.delayed(Duration(seconds: 1), () {
    List<ScanResult> scanResults = [];
    AdvertisementData advertisementData = new AdvertisementData(
        connectable: true,
        localName: "test",
        txPowerLevel: 83,
        serviceUuids: ["123", "456", "789"],
        manufacturerData: null,
        serviceData: null);
    BluetoothDevice bluetoothDevice = new BluetoothDevice.fromProto(null);

    ScanResult scanResult = new ScanResult(
        rssi: 1, advertisementData: advertisementData, device: bluetoothDevice);
    scanResults.add(scanResult);
    scanResults.add(scanResult);
    return scanResults;
  }));
}*/

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  StreamController<bool> showTipCardStreamController = StreamController<bool>();
  bool scanned = false;

  @override
  void dispose() {
    super.dispose();
    showTipCardStreamController.close();
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    showTipCardStreamController.add(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        if (scanned) {
          scanned = false;
          setState(() {});
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.clrWhite,
        /* appBar: AppBar(
          title: Text('Find Hotspots'),
        ),*/
        body: RefreshIndicator(
          onRefresh: () => FlutterBlue.instance.startScan(
              timeout: Duration(seconds: 3),
              withServices: scanFilterServiceUuids),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: showTipCardStreamController.stream,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data == true) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppConstants.img_kowopLogo,
                                height: 50,
                                color: AppConstants.clrBlue,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 30, bottom: 25),
                                child: TextWidget(AppConstants.strHotspotSetup,
                                    color: AppConstants.clrGreen,
                                    fontSize:
                                        AppConstants.size_double_extra_large1,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.bluetooth,
                                      color: AppConstants.clrBlue,
                                      size: 50,
                                    ),
                                  ),
                                  TextWidget(AppConstants.strHotspotSetupDetail,
                                      color: AppConstants.clrBlue,
                                      fontSize: AppConstants.size_medium_large,
                                      fontWeight: FontWeight.normal),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.width *
                                        0.10),
                                child: TextWidget(AppConstants.strStep1,
                                    color: AppConstants.clrBlack,
                                    fontSize: AppConstants.size_large,
                                    fontWeight: FontWeight.normal,
                                    textAlign: TextAlign.center,
                                    height: 1.50),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.width *
                                        0.09),
                                child: TextWidget(AppConstants.strStep2,
                                    color: AppConstants.clrBlack,
                                    fontSize: AppConstants.size_large,
                                    fontWeight: FontWeight.normal,
                                    textAlign: TextAlign.center,
                                    height: 1.50),
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                      left: 18,
                                      right: 18,
                                      top: MediaQuery.of(context).size.width *
                                          0.18,
                                      bottom: 35),
                                  child: ButtonWidget(
                                      context, AppConstants.strScan, () {
                                    showTipCardStreamController.add(false);
                                    scanned = true;
                                    FlutterBlue.instance.startScan(
                                        timeout: Duration(seconds: 3),
                                        withServices: scanFilterServiceUuids);
                                  },
                                      AppConstants.clrGreen,
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Icon(
                                          Icons.bluetooth,
                                          color: AppConstants.clrWhite,
                                          size: 33,
                                        ),
                                      )))
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
                 StreamBuilder<List<ScanResult>>(
                  stream: FlutterBlue.instance.scanResults,
                  initialData: [],
                  builder: (c, snapshot) {
                    print("StreamBuilder -> ${snapshot.data.length}");
                    if(scanned)
                      {
                        return Column(
                            children: snapshot.data.isEmpty == true
                                ? [
                              CommonAppBar(context, () {
                                scanned = false;
                                showTipCardStreamController.add(true);
                                setState(() {});
                              }),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 18, right: 18, top: 25, bottom: 30),
                                child: TextWidget(
                                  AppConstants.strSelectYourHotspot,
                                  color: AppConstants.clrGreen,
                                  fontSize:
                                  AppConstants.size_double_extra_large,
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 18, right: 18, bottom: 10),
                                child: TextWidget(
                                  AppConstants.strNoHotspotFound,
                                  color: AppConstants.clrBlack,
                                  fontSize: AppConstants.size_extra_large,
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]
                                : [
                              CommonAppBar(context, () {
                                scanned = false;
                                showTipCardStreamController.add(true);
                                setState(() {});
                              }),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 18, right: 18, top: 25),
                                child: TextWidget(
                                  AppConstants.strSelectYourHotspot,
                                  color: AppConstants.clrGreen,
                                  fontSize:
                                  AppConstants.size_double_extra_large,
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                child: Column(
                                  children: snapshot.data
                                      .map(
                                        (r) => ScanResultTile(
                                      result: r,
                                      onTap: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                          builder: (context) {
                                            r.device.state.listen(
                                                    (connectionState) {
                                                  print(
                                                      "connectionState Hotspots Screen: " +
                                                          connectionState
                                                              .toString());
                                                  if (connectionState ==
                                                      BluetoothDeviceState
                                                          .disconnected) {
                                                    r.device.connect();
                                                  }
                                                }, onDone: () {
                                              print(
                                                  "Connection State Check Complete");
                                            }, onError: (error) {
                                              print("Connection Error: " +
                                                  error);
                                            });
                                            return HotspotScreen(
                                                device: r.device);
                                          })),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                            ]);
                      }else{
                      return Container();
                    }

                  },
                ),
              ],
            ),
          ),
        ),
        /* floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBlue.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => FlutterBlue.instance.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () {
                    showTipCardStreamController.add(false);
                    scanned = true;
                    FlutterBlue.instance.startScan(
                        timeout: Duration(seconds: 3),
                        withServices: scanFilterServiceUuids);
                  });
            }
          },
        ),*/
      ),
    );
  }
}
