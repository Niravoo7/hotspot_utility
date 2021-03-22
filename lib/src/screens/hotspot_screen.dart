import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/src/screens/wifi_available_ssid_screen.dart';
import 'package:hotspotutility/src/screens/diagnostics_screen.dart';
import 'package:hotspotutility/src/widgets/appbar_widgets.dart';
import 'package:hotspotutility/src/widgets/button_widget.dart';
import 'package:hotspotutility/src/widgets/text_widget.dart';
import 'package:http/http.dart' as http;

class HotspotScreen extends StatefulWidget {
  const HotspotScreen({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  _HotspotScreenState createState() => _HotspotScreenState();
}

class _HotspotScreenState extends State<HotspotScreen> {
  BluetoothCharacteristic wifiServicesChar;
  BluetoothCharacteristic wifiConfiguredServicesChar;
  BluetoothCharacteristic wifiSsidChar;
  BluetoothCharacteristic wifiConnectChar;
  BluetoothCharacteristic wifiRemoveChar;
  BluetoothCharacteristic ethernetOnlineChar;
  BluetoothCharacteristic hotspotFirmwareChar;
  BluetoothCharacteristic hotspotSerialChar;
  BluetoothCharacteristic hotspotDiagnosticsChar;
  BluetoothCharacteristic publicKeyChar;

  bool wifiSsidBuilt = false;
  bool foundChars = true;
  String wifiSsidResult = 'None';
  String hotspotName = 'None';
  String publicKeyResult = 'None';

  StreamController<String> hotspotNameStreamController =
      StreamController<String>();
  StreamController<String> wifiSsidStreamController =
      StreamController<String>();
  StreamController<bool> charReadStatusStreamController =
      StreamController<bool>.broadcast();
  StreamController<String> ethernetStatusStreamController =
      StreamController<String>();
  StreamController<String> hotspotFirmwareStreamController =
      StreamController<String>();
  StreamController<String> hotspotSerialStreamController =
      StreamController<String>();

  @override
  void dispose() {
    super.dispose();
    hotspotNameStreamController.close();
    wifiSsidStreamController.close();
    charReadStatusStreamController.close();
    ethernetStatusStreamController.close();
    hotspotFirmwareStreamController.close();
    hotspotSerialStreamController.close();
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    hotspotNameStreamController.add('');
    wifiSsidStreamController.add('');
    charReadStatusStreamController.add(false);
    ethernetStatusStreamController.add('');
    hotspotFirmwareStreamController.add('');
    hotspotSerialStreamController.add('');

    widget.device.state.listen((connectionState) {
      if (connectionState == BluetoothDeviceState.connected) {
        widget.device.discoverServices().then((services) {
          _findChars(services);
          // public key
          publicKeyChar.read().then((value) {
            publicKeyResult = new String.fromCharCodes(value);
            // hotspot info http
            http
                .get(Uri.parse(
                    "https://api.helium.io/v1/hotspots/" + publicKeyResult))
                .then((value) {
              var parsed = json.decode(value.body);
              hotspotNameStreamController.add(parsed['data']['name']);
              hotspotName = parsed['data']['name'];
            }).catchError((e) {
              print("Helium API Error");
            });
            // current wifi ssid
            wifiSsidChar.read().then((value) {
              wifiSsidResult = new String.fromCharCodes(value);
              // add result to stream
              wifiSsidStreamController.add(wifiSsidResult);
              // ethernet status
              ethernetOnlineChar.read().then((value) {
                var ethernetStatusResult = new String.fromCharCodes(value);
                // add result to stream
                if (ethernetStatusResult == 'true') {
                  ethernetStatusStreamController.add('Connected');
                } else {
                  ethernetStatusStreamController.add('Disconnected');
                }
                // hotspot firmware version
                hotspotFirmwareChar.read().then((value) {
                  // add result to stream
                  hotspotFirmwareStreamController
                      .add(new String.fromCharCodes(value));
                  // hotspot serial number
                  hotspotSerialChar.read().then((value) {
                    // indicate last char read is done
                    charReadStatusStreamController.add(true);
                    // add result to stream
                    hotspotSerialStreamController
                        .add(new String.fromCharCodes(value));
                  });
                });
              });
            });
          });
        });
      }
    });
  }

  void _findChars(List<BluetoothService> services) {
    if (services != null) {
      var hotspotService = services.singleWhere(
          (s) => s.uuid.toString() == "0fda92b2-44a2-4af2-84f5-fa682baa2b8d",
          orElse: () => null);
      var deviceInformationService = services.singleWhere(
          (s) => s.uuid.toString() == "0000180a-0000-1000-8000-00805f9b34fb",
          orElse: () => null);
      if (hotspotService != null) {
        wifiSsidChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "7731de63-bc6a-4100-8ab1-89b2356b038b",
            orElse: () => null);
        wifiServicesChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "d7515033-7e7b-45be-803f-c8737b171a29",
            orElse: () => null);
        wifiConfiguredServicesChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "e125bda4-6fb8-11ea-bc55-0242ac130003",
            orElse: () => null);
        wifiConnectChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "398168aa-0111-4ec0-b1fa-171671270608",
            orElse: () => null);
        wifiRemoveChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "8cc6e0b3-98c5-40cc-b1d8-692940e6994b",
            orElse: () => null);
        ethernetOnlineChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "e5866bd6-0288-4476-98ca-ef7da6b4d289",
            orElse: () => null);
        hotspotFirmwareChar = deviceInformationService.characteristics
            .singleWhere(
                (c) =>
                    c.uuid.toString() == "00002a26-0000-1000-8000-00805f9b34fb",
                orElse: () => null);
        hotspotSerialChar = deviceInformationService.characteristics
            .singleWhere(
                (c) =>
                    c.uuid.toString() == "00002a25-0000-1000-8000-00805f9b34fb",
                orElse: () => null);
        hotspotDiagnosticsChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "b833d34f-d871-422c-bf9e-8e6ec117d57e",
            orElse: () => null);
        publicKeyChar = hotspotService.characteristics.singleWhere(
            (c) => c.uuid.toString() == "0a852c59-50d3-4492-bfd3-22fe58a24f01",
            orElse: () => null);
      }
    } else {
      print("Error: Services is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: CommonAppBar(context,() {

            Navigator.pop(context);

          }),
          body: Container(
            padding: EdgeInsets.only(left: 25, right: 25),
            child: Column(children: <Widget>[
              StreamBuilder<BluetoothDeviceState>(
                stream: widget.device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (c, snapshot) => Container(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: TextWidget(
                          AppConstants.strHotspotSettings,
                          color: AppConstants.clrGreen,
                          fontSize: AppConstants.size_double_extra_large,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(AppConstants.img_bluetooth,
                                color: (snapshot.data ==
                                        BluetoothDeviceState.connected)
                                    ? AppConstants.clrBlue
                                    : AppConstants.clrGrey,
                                height: 25),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                (snapshot.data == BluetoothDeviceState.connected)
                                    ? 'Connected via Bluetooth'
                                    : 'Disconnected from Bluetooth',
                                style: TextStyle(
                                    color: (snapshot.data ==
                                            BluetoothDeviceState.connected)
                                        ? AppConstants.clrBlue
                                        : AppConstants.clrGrey,
                                    fontSize: AppConstants.size_medium_large),
                              ),
                            ),
                            StreamBuilder<bool>(
                                stream: charReadStatusStreamController.stream,
                                initialData: false,
                                builder: (c, snapshot) {
                                  if (snapshot.data == false) {
                                    return CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.grey),
                                    );
                                  } else {
                                    return Icon(null);
                                  }
                                })
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      child: StreamBuilder<String>(
                          stream: ethernetStatusStreamController.stream,
                          initialData: '',
                          builder: (c, snapshot) {
                            return Column(children: <Widget>[
                              ListTile(
                                title: Text('Ethernet',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppConstants.clrBlack)),
                                subtitle: Text(snapshot.data,
                                    style: TextStyle(
                                        color: AppConstants.clrBlack)),
                              )


                            ]);
                          }),
                    ),flex: 1,
                  ),
                  Flexible(
                    child: Container(
                      child: StreamBuilder<String>(
                          stream: hotspotFirmwareStreamController.stream,
                          initialData: '',
                          builder: (c, snapshot) {
                            return Column(children: <Widget>[
                              ListTile(
                                title: Text('Firmware Version',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppConstants.clrBlack)),
                                subtitle: Text(snapshot.data,
                                    style: TextStyle(
                                        color: AppConstants.clrBlack)),
                              )
                            ]);
                          }),
                    ),flex: 1,
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        child: StreamBuilder<String>(
                            stream: wifiSsidStreamController.stream,
                            initialData: '',
                            builder: (c, snapshot) {
                              return Column(children: <Widget>[
                                ListTile(
                                  title: Text('WiFi Network',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.clrBlack)),
                                  subtitle: Text(snapshot.data,
                                      style: TextStyle(
                                          color: AppConstants.clrBlack)),
                                )
                              ]);
                            }),
                      ),flex: 1,
                    ),
                    Flexible(
                      child: Container(
                        child: StreamBuilder<String>(
                            stream: hotspotSerialStreamController.stream,
                            initialData: '',
                            builder: (c, snapshot) {
                              return Column(children: <Widget>[
                                ListTile(
                                  title: Text('Serial Number',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.clrBlack)),
                                  subtitle: Text(snapshot.data,
                                      style: TextStyle(
                                          color: AppConstants.clrBlack)),
                                )
                              ]);
                            }),
                      ),flex: 1,
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: StreamBuilder<bool>(
                    stream: charReadStatusStreamController.stream,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data == true) {
                        return ButtonWidget(
                            context, AppConstants.strConfigureWiFi, () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return WifiAvailableScreen(
                                currentWifiSsid: wifiSsidResult,
                                device: widget.device,
                                wifiServicesChar: wifiServicesChar,
                                wifiConfiguredServicesChar:
                                    wifiConfiguredServicesChar,
                                wifiSsidChar: wifiSsidChar,
                                wifiConnectChar: wifiConnectChar,
                                wifiRemoveChar: wifiRemoveChar);
                          }));
                        }, AppConstants.clrGreen, null);
                      } else {
                        return Icon(null);
                      }
                    }),
              ),
              Flexible(child: Container(color: Colors.transparent,),),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return DiagnosticsScreen(
                            device: widget.device,
                            hotspotDiagnosticsChar: hotspotDiagnosticsChar,
                            hotspotName: hotspotName,
                            hotspotPublicKey: publicKeyResult);
                      }));
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.only(top: 15,bottom: 15),
                      child: Wrap(
                        children: [
                          Text('Diagnostic Report',
                              style: TextStyle(
                                  color: AppConstants.clrBlack,fontSize: 16)),
                          SizedBox(width: 20,),
                          Icon(Icons.arrow_forward_ios,color: Colors.blue,)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50,)
            ]),
          )),
    );
  }
}
