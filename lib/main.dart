import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/instance.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:geolocator_platform_interface/src/models/position.dart' as Pos;
import 'number.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karna Adhar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OnBoardingPage(),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BluetoothApp()),
    );
  }

  Widget _buildFullscreenImage() {
    return Image.asset(
      'assets/fullscreen.jpg',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,

      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: const Text(
            'Let\'s go right away!',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          body: "Fall Detection using ADXL335",
          title: "karna Adhar",
          image: Icon(Icons.check, color: Colors.green[400], size: 100),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Saving Lifes",
          body: "Connect your app to Hardware using Bluetooth (HC-05).",
          image: Icon(Icons.bluetooth_connected,
              color: Colors.blue[400], size: 100),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Get notified.",
          body: "Get Notified by SMS whenever your loved ones are in trouble.",
          image: Icon(Icons.sms, color: Colors.amber[400], size: 100),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  BluetoothApp({Key key}) : super(key: key);

  @override
  State<BluetoothApp> createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  bool alertRecieved = false;
  Timer timer;
  bool isDisconnecting = false;
  List<BluetoothDevice> _devicesList = [];
  String dropdownValue;
  int groupValue = 12, groupValue1 = 12, groupValue2 = 12;
  static const platform = const MethodChannel('sendSms');
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  bool get isConnected => connection != null && connection.isConnected;
  String incomingData = "";
  bool showLoader = false;
  bool showSendMessageButton = false;
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
    });

    await connection.close();
    await ShowToast(
        'Device disconnected.', Icons.error, GFToastPosition.BOTTOM);
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
      alertRecieved = false;
    });
    if (_device == null) {
      await ShowToast(
          'No device selected', Icons.error, GFToastPosition.BOTTOM);
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });
        });

        await ShowToast(
            'Device Connected', Icons.error, GFToastPosition.BOTTOM);
        //getPairedDevices();
        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    //print(items);
    return items;
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
    print(devices.length);
    _devicesList.forEach((element) {
      print(element.name);
    });
  }

  Future<bool> sendSms() async {
    print("SendSMS");
    try {
      await Instance.FetchNumbers();
      if (Instance.numbers.isEmpty || Instance.numbers == null) {
        ShowToast("SMS cannot be sent. Mobile numbers are not provided",
            Icons.error, GFToastPosition.BOTTOM);
        return false;
      }
      Pos.Position position;
      try {
        position = await Instance.determinePosition();
        print(position);
      } catch (e) {
        print(e);
      }
      for (var i = 0; i < Instance.numbers.length; i++) {
        print(Instance.numbers[i]);
        final String result =
            await platform.invokeMethod('send', <String, dynamic>{
          "phone": Instance.numbers[i],
          "msg":
              "Fall has been detected!\r\n\r\nLocation - \r\nhttps://maps.google.com/?q=" +
                  (position != null ? position.latitude.toString() : "") +
                  "," +
                  (position != null ? position.longitude.toString() : "")
        });
        ShowToast(
            result, Icons.perm_device_information, GFToastPosition.BOTTOM);
        print(result);
      }
      //Replace a 'X' with 10 digit phone number

      return true;
    } on PlatformException catch (e) {
      print(e.toString());
      return false;
    }
  }

  Timer _timer;
  int _start;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);

    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            showLoader = false;
            sendSms();
            timer.cancel();
            showSendMessageButton = false;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 15), (Timer t) => CheckBluetoothData());
  }

  bool isButtonPressed = false;
  Future CheckBluetoothData() async {
    try {
      _connect();
      connection.input.listen((Uint8List data) {
        print(data);
        incomingData = new String.fromCharCodes(data);
        if (data.isNotEmpty) {
          print("Value received");
          setState(() {
            alertRecieved = true;
            showLoader = true;
            showSendMessageButton = true;
            startTimer();
          });
        }
        print('Data incoming: ${incomingData}');
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (exception) {
      print(exception);
      print('Cannot connect, exception occured');
    }
  }

  TextEditingController Controller;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          onPressed: () async {
            _start = await Instance.fetchTime();
            print(_start);
            if (_start == 0 || _start == null) {
              _start = 0;
              setState(() {
                Controller = new TextEditingController(text: "");
              });
            } else {
              setState(() {
                Controller = new TextEditingController(text: _start.toString());
              });
            }

            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Center(child: const Text('Enter Timer (in sec)')),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Card(
                                child: TextField(
                                  controller: Controller,
                                  onChanged: (val) {
                                    _start = int.parse(val);
                                  },
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Time (in sec)',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        Center(
                          child: TextButton(
                            child: const Text('Save'),
                            onPressed: () async {
                              print("saving time - " + Controller.text);
                              await Instance.saveTime(_start);
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ));
          },
          child: const Icon(
            Icons.timer,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: GFAppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Text(
            "Fallout Alert",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            GFIconButton(
              icon: Icon(
                Icons.call,
                color: Colors.black,
              ),
              onPressed: () async {
                await Instance.FetchNumbers();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MobileNumbers()),
                );
              },
              type: GFButtonType.transparent,
            ),
          ],
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Enable Bluetooth"),
                    GFToggle(
                      onChanged: (value) async {
                        print(value);
                        future() async {
                          // async lambda seems to not working
                          if (!value)
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                        }

                        await getPairedDevices();
                        _isButtonUnavailable = false;

                        future().then((_) {
                          setState(() {});
                        });
                      },
                      value: true,
                      type: GFToggleType.custom,
                      enabledText: "ON",
                      disabledText: "OFF",
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.45,
                      margin: EdgeInsets.all(20),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: _getDeviceItems(),
                          onChanged: (value) => setState(() => _device = value),
                          value: _devicesList.isNotEmpty ? _device : null,
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: _isButtonUnavailable
                          ? null
                          : _connected
                              ? _disconnect
                              : _connect,
                      child: Text(_connected ? 'Disconnect' : 'Connect'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Card(
                  color: Colors.white,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("X-Axis"),
                              GFRadio(
                                autofocus: true,
                                type: GFRadioType.custom,
                                activeIcon: Icon(alertRecieved
                                    ? Icons.dangerous
                                    : Icons.check),
                                radioColor: Colors.red,
                                size: GFSize.LARGE,
                                activeBgColor: alertRecieved
                                    ? GFColors.DANGER
                                    : GFColors.SUCCESS,
                                inactiveBorderColor: GFColors.DARK,
                                activeBorderColor: alertRecieved
                                    ? GFColors.DANGER
                                    : GFColors.SUCCESS,
                                value: 12,
                                groupValue: groupValue,
                                onChanged: (value) {
                                  setState(() {
                                    groupValue = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Y-Axis"),
                              GFRadio(
                                autofocus: true,
                                type: GFRadioType.custom,
                                activeIcon: Icon(alertRecieved
                                    ? Icons.dangerous
                                    : Icons.check),
                                radioColor: Colors.red,
                                size: GFSize.LARGE,
                                activeBgColor: alertRecieved
                                    ? GFColors.DANGER
                                    : GFColors.SUCCESS,
                                inactiveBorderColor: GFColors.DARK,
                                activeBorderColor: alertRecieved
                                    ? GFColors.DANGER
                                    : GFColors.SUCCESS,
                                value: 12,
                                groupValue: groupValue1,
                                onChanged: (value) {
                                  setState(() {
                                    groupValue1 = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Z-Axis"),
                              GFRadio(
                                autofocus: true,
                                type: GFRadioType.custom,
                                activeIcon: Icon(alertRecieved
                                    ? Icons.dangerous
                                    : Icons.check),
                                radioColor: Colors.red,
                                size: GFSize.LARGE,
                                activeBgColor: alertRecieved
                                    ? GFColors.DANGER
                                    : GFColors.SUCCESS,
                                inactiveBorderColor: GFColors.DARK,
                                activeBorderColor: alertRecieved
                                    ? GFColors.DANGER
                                    : GFColors.SUCCESS,
                                value: 12,
                                groupValue: groupValue2,
                                onChanged: (value) {
                                  setState(() {
                                    groupValue2 = value;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              showLoader
                  ? GFLoader(
                      type: GFLoaderType.android,
                      size: 150,
                    )
                  : SizedBox(
                      height: 0,
                    ),
              showLoader
                  ? Text(
                      "$_start sec remaining",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              showSendMessageButton
                  ? Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: GFButton(
                              highlightElevation: 2,
                              elevation: 2,
                              onPressed: () {
                                setState(() {
                                  showLoader = false;
                                  _timer.cancel();
                                  showSendMessageButton = false;
                                });
                                ShowAlert();
                              },
                              text: "Safe",
                              textStyle:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              shape: GFButtonShape.square,
                              color: Colors.blueGrey[400],
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ShowAlert() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Safe'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('I am Safe!'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Okay'),
                  onPressed: () {
                    setState(() {
                      alertRecieved = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<Null> ShowToast(
      String text, IconData I, GFToastPosition position) async {
    GFToast.showToast(text, context,
        toastPosition: position,
        textStyle: TextStyle(fontSize: 16, color: GFColors.WHITE),
        backgroundColor: GFColors.DARK,
        trailing: Icon(
          I,
          color: GFColors.SUCCESS,
        ));
    return Null;
  }
}
