import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/src/widgets/appbar_widgets.dart';
import 'package:hotspotutility/src/widgets/button_widget.dart';
import 'package:hotspotutility/src/widgets/custom_dialog.dart';
import 'package:hotspotutility/src/widgets/text_widget.dart';
import 'package:share/share.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:http/http.dart' as http;
import 'package:hotspotutility/gen/hotspotutility.pb.dart' as protos;

import 'package:url_launcher/url_launcher.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({
    Key key,
    this.device,
    this.hotspotDiagnosticsChar,
    this.hotspotName,
    this.hotspotPublicKey,
  }) : super(key: key);
  final BluetoothDevice device;
  final BluetoothCharacteristic hotspotDiagnosticsChar;
  final String hotspotName;
  final String hotspotPublicKey;

  _DiagnosticsScreenState createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  StreamController<String> ethMacStreamController = StreamController<String>();
  StreamController<String> wifiMacStreamController = StreamController<String>();
  StreamController<String> fwStreamController = StreamController<String>();
  StreamController<String> ipStreamController = StreamController<String>();
  StreamController<String> natTypeStreamController = StreamController<String>();

  StreamController<String> outboundConnectionStreamController =
      StreamController<String>();
  StreamController<String> inboundConnectionStreamController =
      StreamController<String>();
  StreamController<String> lastChallengeStreamController =
      StreamController<String>();
  StreamController<String> blockchainHeightStreamController =
      StreamController<String>();
  StreamController<bool> dataRequestCompleteStreamController =
      StreamController<bool>.broadcast();

  Map<String, String> diagnosticsResults;
  int blockchainHeight;
  Map<String, String> shareData = new Map();

  @override
  void dispose() {
    super.dispose();
    ethMacStreamController.close();
    wifiMacStreamController.close();
    fwStreamController.close();
    ipStreamController.close();
    natTypeStreamController.close();
    outboundConnectionStreamController.close();
    inboundConnectionStreamController.close();
    lastChallengeStreamController.close();
    blockchainHeightStreamController.close();
    dataRequestCompleteStreamController.close();
  }

  Future getLastChallenge() {
    return http
        .get(
        Uri.parse("https://api.helium.io/v1/hotspots/" +
          widget.hotspotPublicKey +
          "/challenges"),
    )
        .then((value) {
      var parsed = json.decode(value.body);
      if (parsed['data'].length != 0) {
        var difMilli = new DateTime.now().millisecondsSinceEpoch -
            parsed['data'][0]['time'] * 1000;
        var result = new DateTime.fromMillisecondsSinceEpoch(
                    parsed['data'][0]['time'] * 1000)
                .toString()
                .split('.')[0] +
            '  |  ' +
            new Duration(milliseconds: difMilli).toString().split('.')[0] +
            ' ago';
        lastChallengeStreamController.add(result);
        shareData['Last Challenged'] = result;
      } else {
        print("Using Cursor");
        return http
            .get(
            Uri.parse( "https://api.helium.io/v1/hotspots/" +
              widget.hotspotPublicKey +
              "/challenges?cursor=" +
              parsed['cursor']),
        )
            .then((value) {
          var parsed = json.decode(value.body);
          if (parsed['data'].length != 0) {
            var difMilli = new DateTime.now().millisecondsSinceEpoch -
                parsed['data'][0]['time'] * 1000;
            var result = new DateTime.fromMillisecondsSinceEpoch(
                        parsed['data'][0]['time'] * 1000)
                    .toString()
                    .split('.')[0] +
                '  |  ' +
                new Duration(milliseconds: difMilli).toString().split('.')[0] +
                ' ago';
            lastChallengeStreamController.add(result);
            shareData['Last Challenged'] = result;
          }
        });
      }
    });
  }

  @protected
  @mustCallSuper
  void initState() {
    super.initState();

    // Hide share button to start
    dataRequestCompleteStreamController.add(false);

    shareData['Hotspot'] = widget.hotspotName;

    // Read Diagnostics Char
    widget.hotspotDiagnosticsChar.read().then((value) {
      if (new String.fromCharCodes(value) != "failed") {
        diagnosticsResults =
            protos.diagnostics_v1.fromBuffer(value).diagnostics;
        print(diagnosticsResults);
      }
      // blockchain height http
      http
          .get(Uri.parse("https://api.helium.io/v1/blocks/height"))
          .then((value) {
        var parsed = json.decode(value.body);
        blockchainHeight = parsed['data']['height'];

        // Add data to streams
        diagnosticsResults.forEach((key, value) {
          switch (key) {
            case 'height':
              var heightString = value +
                  ' sync: ' +
                  ((double.parse(value) / blockchainHeight) * 100)
                      .round()
                      .toString() +
                  '%';
              blockchainHeightStreamController.add(heightString);
              shareData['Blockchain Height'] = heightString;
              break;
            case 'eth':
              ethMacStreamController.add(value);
              shareData['Ethernet MAC'] = value;
              break;
            case 'wifi':
              wifiMacStreamController.add(value);
              shareData['Wi-Fi MAC'] = value;
              break;
            case 'fw':
              fwStreamController.add(value);
              shareData['Firmware Version'] = value;
              break;
            case 'ip':
              ipStreamController.add(value);
              shareData['IP'] = value;
              break;
            case 'nat_type':
              natTypeStreamController.add(value);
              shareData['NAT Type'] = value;
              break;
            case 'connected':
              if (value == 'yes') {
                outboundConnectionStreamController.add('OK');
                shareData['Outbound Connection'] = 'OK';
              } else {
                outboundConnectionStreamController.add('No Connection');
                shareData['Outbound Connection'] = 'No Connection';
              }
              break;
            case 'dialable':
              if (value == 'yes') {
                inboundConnectionStreamController.add('OK');
                shareData['Inbound Connection'] = 'OK';
              } else {
                inboundConnectionStreamController.add('No Connection');
                shareData['Inbound Connection'] = 'No Connection';
              }
              break;
            default:
              print("no key match");
              break;
          }
        });

        shareData['Report Generated'] =
            new DateTime.now().toString().split('.')[0];

        getLastChallenge().then((value) {
          dataRequestCompleteStreamController.add(true);
        }).catchError((e) {
          print(
              "Helium Blockchain Hotspot Challenges API Error: ${e.toString()}");
          lastChallengeStreamController.add('No Challenge Found');
          shareData['Last Challenged'] = 'No Challenge Found';
          dataRequestCompleteStreamController.add(true);
        });
      }).catchError((e) {
        print("Helium Blockchain Height API Error");
      });
    }).catchError((e) {
      print("Error: hotspotDiagnosticsChar Read Failure: ${e.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar(context,() {

          Navigator.pop(context);

        }),
        body: SingleChildScrollView(
            child: Container(
          margin: EdgeInsets.only(left: 25, right: 25),
          child: Column(children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 5),
                      child: TextWidget(
                        "Diagnostics Report",
                        color: AppConstants.clrGreen,
                        fontSize: AppConstants.size_double_extra_large,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      )),
                  Text(
                    widget.hotspotName,
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
            Container(
              child: StreamBuilder<String>(
                  stream: outboundConnectionStreamController.stream,
                  initialData: '',
                  builder: (c, snapshot) {
                    return Column(children: <Widget>[
                      ListTile(
                        title: Text('Outbound Peer-to-Peer Connection',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.clrBlack)),
                        subtitle: Text(snapshot.data.toString(),
                            style: TextStyle(color: AppConstants.clrBlack)),
                      )
                    ]);
                  }),
            ),
            Container(
              child: StreamBuilder<String>(
                  stream: inboundConnectionStreamController.stream,
                  initialData: '',
                  builder: (c, snapshot) {
                    return Column(children: <Widget>[
                      ListTile(
                        title: Text('Inbound Peer-to-Peer Connection',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.clrBlack)),
                        subtitle: Text(snapshot.data.toString(),
                            style: TextStyle(color: AppConstants.clrBlack)),
                      )
                    ]);
                  }),
            ),
            Container(
              child: StreamBuilder<String>(
                  stream: blockchainHeightStreamController.stream,
                  initialData: '',
                  builder: (c, snapshot) {
                    return Column(children: <Widget>[
                      ListTile(
                        title: Text('Blockchain Height',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.clrBlack)),
                        subtitle: Text(snapshot.data.toString(),
                            style: TextStyle(color: AppConstants.clrBlack)),
                      )
                    ]);
                  }),
            ),
            Container(
              child: StreamBuilder<String>(
                  stream: lastChallengeStreamController.stream,
                  initialData: '',
                  builder: (c, snapshot) {
                    return Column(children: <Widget>[
                      ListTile(
                        title: Text('Last Challenged',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.clrBlack)),
                        subtitle: Text(snapshot.data.toString(),
                            style: TextStyle(color: AppConstants.clrBlack)),
                      )
                    ]);
                  }),
            ),
            Container(
              child: StreamBuilder<String>(
                  stream: fwStreamController.stream,
                  initialData: '',
                  builder: (c, snapshot) {
                    return Column(children: <Widget>[
                      ListTile(
                        title: Text('Hotspot Firmware',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.clrBlack)),
                        subtitle: Text(snapshot.data.toString(),
                            style: TextStyle(color: AppConstants.clrBlack)),
                      )
                    ]);
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    child: StreamBuilder<String>(
                        stream: wifiMacStreamController.stream,
                        initialData: '',
                        builder: (c, snapshot) {
                          return Column(children: <Widget>[
                            ListTile(
                              title: Text('Wi-Fi MAC',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.clrBlack)),
                              subtitle: Text(snapshot.data.toString(),
                                  style: TextStyle(color: AppConstants.clrBlack)),
                            )
                          ]);
                        }),
                  ),flex: 1,
                ),
                Flexible(
                  child: Container(
                    child: StreamBuilder<String>(
                        stream: ethMacStreamController.stream,
                        initialData: '',
                        builder: (c, snapshot) {
                          return Column(children: <Widget>[
                            ListTile(
                              title: Text('Ethernet MAC',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.clrBlack)),
                              subtitle: Text(snapshot.data.toString(),
                                  style: TextStyle(color: AppConstants.clrBlack)),
                            )
                          ]);
                        }),
                  ),flex: 1,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    child: StreamBuilder<String>(
                        stream: natTypeStreamController.stream,
                        initialData: '',
                        builder: (c, snapshot) {
                          return Column(children: <Widget>[
                            ListTile(
                              title: Text('NAT Type',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.clrBlack)),
                              subtitle: Text(snapshot.data.toString(),
                                  style: TextStyle(color: AppConstants.clrBlack)),
                            )
                          ]);
                        }),
                  ),flex: 1,
                ),
                Flexible(
                  child: Container(
                    child: StreamBuilder<String>(
                        stream: ipStreamController.stream,
                        initialData: '',
                        builder: (c, snapshot) {
                          return Column(children: <Widget>[
                            ListTile(
                              title: Text('IP Address',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.clrBlack)),
                              subtitle: Text(snapshot.data.toString(),
                                  style: TextStyle(color: AppConstants.clrBlack)),
                            )
                          ]);
                        }),
                  ),flex: 1,
                )
              ],
            ),
            Container(
              child: StreamBuilder<bool>(
                  stream: dataRequestCompleteStreamController.stream,
                  initialData: false,
                  builder: (c, snapshot) {
                    if (snapshot.data == true) {
                      return ButtonWidget(context, AppConstants.strSendToKowop,
                          ()async {

                            final Uri params = Uri(
                              scheme: 'mailto',
                              path: 'Support@kowop.com',
                              query: 'subject=Hotspot Diagnostic Report&body=$shareData', //add subject and body here
                            );

                            var url = params.toString();
                            if (await canLaunch(url)) {
                            await launch(url);
                            showCustomDialog(
                                context,
                                "Success!",
                                "Your diagnostic report was sent successfully to KOWOP.",
                                "OK");
                            } else {
                            showCustomDialog(
                                context,
                                "Sending Failed!",
                                "Please check your internet connection and try again.",
                                "OK");
                            throw 'Could not launch $url';
                            }

                        /*Share.share(prettyJson(shareData, indent: 2))
                            .then((value) {
                          showCustomDialog(
                              context,
                              "Success!",
                              "Your diagnostic report was sent successfully to KOWOP.",
                              "OK");
                        }).catchError(() {
                          showCustomDialog(
                              context,
                              "Sending Failed!",
                              "Please check your internet connection and try again.",
                              "OK");
                        });*/

                      }, AppConstants.clrGreen, null);
                    } else {
                      return Icon(null);
                    }
                  }),
            )
          ]),
        )));
  }
}
