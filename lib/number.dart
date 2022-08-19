import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/instance.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileNumbers extends StatefulWidget {
  MobileNumbers({Key key}) : super(key: key);

  @override
  State<MobileNumbers> createState() => _MobileNumbersState();
}

class _MobileNumbersState extends State<MobileNumbers> {
  TextEditingController controller1;
  TextEditingController controller2;
  TextEditingController controller3;
  TextEditingController controller4;
  TextEditingController controller5;

  List<String> numbers;
  bool numbersStored = false;
  String num1, num2, num3, num4, num5;
  @override
  void initState() {
    super.initState();

    if (Instance.numbers == null || Instance.numbers.isEmpty) {
      numbersStored = false;
      print("Numbers are not saved in SharedPreference.");
      controller1 = new TextEditingController(text: "");
      controller2 = new TextEditingController(text: "");
      controller3 = new TextEditingController(text: "");
      controller4 = new TextEditingController(text: "");
      controller5 = new TextEditingController(text: "");
    } else {
      numbersStored = true;
      print("Numbers are saved in SharedPreference.");
      try {
        controller1 = new TextEditingController(text: Instance.numbers[0]);
      } catch (e) {
        controller1 = new TextEditingController(text: "");
      }
      try {
        controller2 = new TextEditingController(text: Instance.numbers[1]);
      } catch (e) {
        controller2 = new TextEditingController(text: "");
      }
      try {
        controller3 = new TextEditingController(text: Instance.numbers[2]);
      } catch (e) {
        controller3 = new TextEditingController(text: "");
      }
      try {
        controller4 = new TextEditingController(text: Instance.numbers[3]);
      } catch (e) {
        controller4 = new TextEditingController(text: "");
      }
      try {
        controller5 = new TextEditingController(text: Instance.numbers[4]);
      } catch (e) {
        controller5 = new TextEditingController(text: "");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          backgroundColor: Colors.white,
          title: Text(
            "Enter Numbers",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Card(
                child: TextField(
                  controller: controller1,
                  keyboardAppearance: Brightness.dark,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    num1 = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Mobile number 1',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Card(
                child: TextField(
                  controller: controller2,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    num2 = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Mobile number 2',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Card(
                child: TextField(
                  controller: controller3,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    num3 = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Mobile number 3',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Card(
                child: TextField(
                  controller: controller4,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    num4 = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Mobile number 4',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Card(
                child: TextField(
                  controller: controller5,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    num5 = val;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Mobile number 5',
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        if (num1 == null &&
                            num2 == null &&
                            num3 == null &&
                            num4 == null &&
                            num5 == null) {
                          ShowToast("Please enter numbers.", Icons.error,
                              GFToastPosition.TOP,
                              success: false);
                          return;
                        }
                        numbers = [];
                        numbers.add(num1);
                        numbers.add(num2);
                        numbers.add(num3);
                        numbers.add(num4);
                        numbers.add(num5);
                        numbers.remove(null);
                        numbers.remove(null);
                        numbers.remove(null);
                        numbers.remove(null);
                        numbers.remove(null);
                        print(numbers);
                        Instance.numbers =
                            Instance.numbers == null ? [] : Instance.numbers;
                        Instance.numbers.addAll(numbers);
                        print(Instance.numbers);
                        await Instance.ClearSharedPreference();
                        await Instance.SaveNumbers();
                        ShowToast("Successfully Saved all numbers.",
                            Icons.check, GFToastPosition.TOP);
                      },
                      child: Text("Save")),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButtonTheme(
                    data: ElevatedButtonThemeData(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith(getColor))),
                    child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            controller1 = new TextEditingController(text: "");
                            controller2 = new TextEditingController(text: "");
                            controller3 = new TextEditingController(text: "");
                            controller4 = new TextEditingController(text: "");
                            controller5 = new TextEditingController(text: "");
                          });
                          await Instance.ClearSharedPreference();
                          ShowToast("Successfully cleared all numbers.",
                              Icons.check, GFToastPosition.TOP);
                        },
                        child: Text("Clear")),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void ShowToast(String text, IconData I, GFToastPosition position,
      {bool success = true}) async {
    GFToast.showToast(text, context,
        toastPosition: position,
        textStyle: TextStyle(fontSize: 16, color: GFColors.WHITE),
        backgroundColor: success ? GFColors.SUCCESS : GFColors.DANGER,
        trailing: Icon(
          I,
          color: GFColors.SUCCESS,
        ));
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    return Colors.deepOrange;
  }
}
