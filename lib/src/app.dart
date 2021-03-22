import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotspotutility/constant.dart';
import 'package:hotspotutility/src/screens/hotspots_screen.dart';
import 'package:hotspotutility/src/screens/more_screen.dart';
import 'package:hotspotutility/src/screens/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotspot Utility',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: SplashScreen(),
    );
  }
}

class ParentWidget extends StatefulWidget {
  ParentWidget({Key key}) : super(key: key);

  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[HotspotsScreen(), MoreScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  Future<void> getPermission() async {
    var status = await Permission.bluetooth.status;
    if (!status.isGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.location,
      ].request();
      print(statuses[Permission.storage]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppConstants.clrBlue,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth, color: AppConstants.clrWhite, size: 30),
            title: Padding(
              padding: EdgeInsets.only(top: 5),
              child:
                  Text('SETUP', style: TextStyle(color: AppConstants.clrWhite)),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu, color: AppConstants.clrWhite, size: 30),
            title: Text('MORE', style: TextStyle(color: AppConstants.clrWhite)),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppConstants.clrWhite,
        onTap: _onItemTapped,
      ),
    );
  }
}
