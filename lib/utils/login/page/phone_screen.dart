import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:store/utils/constants.dart';
import 'package:store/utils/login/legal/privacy.dart';
import 'package:store/utils/login/legal/terms.dart';
import 'package:store/utils/login/page/verify_screen.dart';
import 'package:store/utils/network/service.dart';

// Main widget for phone number verification
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
    phoneNumberController.addListener(() {
      String text = phoneNumberController.text;
      if (text.length == 10) {
        // Call your method to handle form submission here
        _submitForm();
      }
    });
  }

  @override
  void dispose() {
    // Don't forget to dispose the controller when the widget is removed
    phoneNumberController.dispose();
    super.dispose();
  }

  void _submitForm() {
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

      final response = await networkService.postWithAuth('/send-otp-manager',
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurpleAccent, // Start color of the gradient
                    Colors.lightBlueAccent, // End color of the gradient
                  ],
                  stops: [
                    0.55,
                    1.0,
                  ]),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Form(
                  key: formKey,
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.04),
                          width: MediaQuery.of(context).size.width * 0.40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            // Set the radius for rounded corners
                            child: Transform.scale(
                              scale:
                                  1.0, // Adjust the scale to zoom in. 1.0 is the original size, so 1.1 zooms in slightly.
                              child: Image.asset(
                                'assets/icon.jpeg',
                                height: 140,
                                fit: BoxFit
                                    .cover, // Ensure the image covers the scaled area
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.04),
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                "Groceries \ndelivered in\n5 minutes",
                                style: GoogleFonts.ubuntu(
                                  // Tinos is a serif font similar to Times New Roman
                                  textStyle: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Container(
                          height:
                              48, // Increased height for a larger input area
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 2,
                              ),
                              const SizedBox(
                                width: 50,
                                child: Text(
                                  "+91",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                                ),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  keyboardType: TextInputType.phone,
                                  controller: phoneNumberController,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter phone number',
                                      hintStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      counterText: ""),
                                  maxLength: 10, // Limit the input to 10 digits
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 11, 128),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
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
                              "Continue",
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Terms()),
                            );
                          },
                          child: const Text(
                            'Terms',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Privacy()),
                            );
                          },
                          child: const Text(
                            'Privacy',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Guest',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        /*
        bottomNavigationBar: BottomAppBar(
          color: Colors.amberAccent,
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
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SkipHomePage(
                                  title: 'Otto Mart',
                                )),
                      );
                    },
                    child: const Text(
                      'Guest User',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        */
      ),
    );
  }
}
