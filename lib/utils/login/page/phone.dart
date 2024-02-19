import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:store/utils/login/legal/privacy.dart';
import 'package:store/utils/login/legal/terms.dart';
import 'package:store/utils/login/page/verify.dart';
import 'package:store/utils/network/service.dart';
import 'package:pinput/pinput.dart';
import 'package:upgrader/upgrader.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({super.key});

  @override
  _MyPhoneState createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  bool isTesterVersion = false; // To track the state of the checkbox

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    countryController.text = "+91";
    super.initState();
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Message"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> sendOTP(String phoneNumber) async {
    try {
      final networkService = NetworkService();
      // Send the HTTP request to send OTP
      final Map<String, dynamic> requestData = {"phone": phoneNumber};

      final response = await networkService.postWithAuth('/send-otp-packer',
          additionalData: requestData);

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['type'];
      } else {
        // Handle HTTP request error
        return response.reasonPhrase;
      }
    } catch (error) {
      print('Error(Send OTP): $error');
      return null;
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: UpgradeAlert(
        dialogStyle: Platform.isIOS
            ? UpgradeDialogStyle.cupertino
            : UpgradeDialogStyle.material,
        canDismissDialog: false,
        showIgnore: false,
        showLater: false,
        child: Form(
          key: formKey,
          child: Container(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icon/icon.jpeg',
                    height: 250,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Center(
                          child: Text(
                            'no image',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Phone Verification",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Let's Start Saving!",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 80, // Increased height for a larger input area
                    child: Pinput(
                      separatorBuilder: (index) => Container(
                        height: 80,
                        width: 2,
                        color:
                            Colors.transparent, // Use a transparent separator
                      ),
                      length: 10, // Set the length of the input
                      controller: phoneNumberController,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      onSubmitted: (pin) {
                        // Handle submission logic here
                      },
                      defaultPinTheme: PinTheme(
                        width: 70, // Increased width for larger input boxes
                        height:
                            60, // Add some spacing around each input box for the floating effect
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Colors
                              .deepPurpleAccent, // Uniform color for each input box
                          border: Border.all(
                            color: Colors.deepPurpleAccent, // Border color
                            width: 1, // Border width
                          ),
                          borderRadius:
                              BorderRadius.circular(25), // More rounded borders
                          boxShadow: [
                            // Shadow for the floating effect
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        textStyle: const TextStyle(
                          fontSize:
                              26, // Larger font size for better visibility
                          color: Colors.white, // Text color
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width:
                            70, // Keep the width consistent with defaultPinTheme
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // Color of the input box when focused
                          border: Border.all(
                            color:
                                Colors.greenAccent, // Border color when focused
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                              10), // Consistent border radius with defaultPinTheme
                          boxShadow: [
                            // Enhanced shadow for the floating effect when focused
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(
                                  0, 4), // changes position of shadow
                            ),
                          ],
                        ),
                        textStyle: const TextStyle(
                          fontSize: 28,
                          color: Colors.black, // Text color when focused
                        ),
                      ),
                      // Add more customization to Pinput as needed
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        String phoneNumber = phoneNumberController.text;
                        if (phoneNumber.length == 10) {
                          sendOTP(phoneNumber).then((value) {
                            if (value == "success") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyVerify(
                                    number: phoneNumber,
                                    isTester: false,
                                  ),
                                ),
                              );
                            } else if (value == "test") {
                              print("TEST");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyVerify(
                                    number: '1234567890',
                                    isTester: true,
                                  ),
                                ),
                              );
                            } else {
                              _showDialog(value ?? 'Failed to send OTP');
                            }
                          });
                        } else {
                          _showDialog("Phone number must be 10 digits");
                        }
                      },
                      child: const Text(
                        "Send OTP code",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.0,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Terms()),
                    );
                  },
                  child: const Text('Terms'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Privacy()),
                    );
                  },
                  child: const Text('Privacy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
