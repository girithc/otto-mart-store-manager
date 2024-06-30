import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:store/main.dart';
import 'package:store/utils/login/page/phone_screen.dart';
import 'package:store/utils/network/service.dart';

class MyVerify extends StatefulWidget {
  const MyVerify({Key? key, required this.number, required this.isTester})
      : super(key: key);
  final String number; // Mark this as final
  final bool isTester;
  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  late CustomerApiClient apiClient; // Declare apiClient here
  late Customer customer;

  final storage = const FlutterSecureStorage();
  String? fcmToken;
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  bool isPinCorrect = false; // State variable to track pin correctness
  bool isLoggedIn = false;

  Timer? _timer;
  int _start = 60; // Countdown time in seconds

  @override
  void initState() {
    super.initState();
    apiClient = CustomerApiClient(widget.number);
    _retrieveFCMToken();
    startTimer();
  }

  Future<void> _retrieveFCMToken() async {
    String deviceToken = await getDeviceToken();
    await storage.write(key: 'fcm', value: deviceToken);

    try {
      fcmToken = await storage.read(key: 'fcm');
    } catch (e) {
      print('Error retrieving FCM token: $e');
    }
  }

  Future getDeviceToken() async {
    //request user permission for push notification
    FirebaseMessaging.instance.requestPermission();

    if (Platform.isIOS) {
      var iosToken = await FirebaseMessaging.instance.getAPNSToken();
      print("aps : $iosToken");
    }
    FirebaseMessaging firebaseMessage = FirebaseMessaging.instance;
    String? deviceToken = await firebaseMessage.getToken();
    return (deviceToken == null) ? "" : deviceToken;
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    _timer?.cancel();

    super.dispose();
  }

  Future<void> checkLoginStatus() async {
    const storage = FlutterSecureStorage();
    final customerId = await storage.read(key: 'managerId');

    setState(() {
      isLoggedIn = customerId != null;
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void resendOTP() {
    // Implement the logic to resend OTP
    // After sending the OTP, restart the timer
    setState(() {
      _start = 60; // Reset timer to 60 seconds
    });
    startTimer();
    // Show a message to the user that OTP has been resent
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP has been resent.'),
      ),
    );
  }

  Future<bool> loginCustomer() async {
    try {
      final loggedCustomer = await apiClient.loginCustomer();
      setState(() {
        customer = loggedCustomer;
        isLoggedIn = true;
      });

      // Store the user's credentials securely
      await storage.write(key: 'managerId', value: customer.id.toString());
      await storage.write(key: 'phone', value: customer.phone.toString());

      return true; // Login was successful
    } catch (err) {
      return false; // Login failed
    }
  }

  Future<ManagerLoginResponse?> verifyOTP(
      String phoneNumber, String otp) async {
    try {
      //final fcm = await storage.read(key: 'fcm');
      final Map<String, dynamic> requestData = {
        "phone": phoneNumber,
        "otp": int.parse(otp),
        "fcm": fcmToken ?? ""
      };

      final networkService = NetworkService();
      final response = await networkService.postWithAuth('/verify-otp-manager',
          additionalData: requestData);

      print("Response: ${response.body} ${response.body}");
      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.body);
        // Successfully verified OTP, parse the response
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        final customerLoginResponse =
            ManagerLoginResponse.fromJson(jsonResponse);
        await storage.write(
            key: 'authToken', value: customerLoginResponse.customer?.token);
        await storage.write(
            key: 'managerId',
            value: customerLoginResponse.customer?.id.toString());
        await storage.write(
            key: 'phone', value: customerLoginResponse.customer?.phone);

        return customerLoginResponse;
      } else {
        // Handle HTTP request error by creating a response with the error message
        return ManagerLoginResponse(
          message: response.reasonPhrase ?? "Unknown error",
          type: "error",
        );
      }
    } catch (error) {
      print('Error(Verify OTP): $error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Colors.greenAccent;
    const fillColor = Colors.greenAccent;
    const borderColor = Colors.white;

    final defaultPinTheme = PinTheme(
      width: 40,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Text(fcmToken ?? 'FCM Token not found'),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
              ),
              const Text(
                "OTP Verification",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              const Text(
                "Enter OTP sent to your phone number",
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              AutofillGroup(
                child: Pinput(
                  onChanged: (value) {
                    if (value.length == 4) {
                      String otp = pinController.text;
                      isPinCorrect
                          ? verifyOTP(widget.number, otp).then((value) {
                              if (value!.type == 'success') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyHomePage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('OTP Invalid'),
                                  backgroundColor: Colors.deepOrangeAccent,
                                ));
                              }
                            })
                          : null;
                    }
                  },
                  controller: pinController,
                  focusNode: focusNode,
                  keyboardType:
                      TextInputType.number, // Restrict to number input
                  androidSmsAutofillMethod:
                      AndroidSmsAutofillMethod.smsUserConsentApi,
                  autofillHints: const [
                    AutofillHints.oneTimeCode
                  ], // Suggest iOS this is for OTP
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  validator: (value) {
                    if (value?.length == 4) {
                      setState(() {
                        isPinCorrect =
                            true; // Set flag to true if pin is correct
                      });

                      String otp = pinController.text;
                      isPinCorrect
                          ? verifyOTP(widget.number, otp).then((value) {
                              if (value!.type == 'success') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyHomePage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('OTP Invalid'),
                                  backgroundColor: Colors.deepOrangeAccent,
                                ));
                              }
                            })
                          : null; // Button is disabled if isPinCorrect is false
                    } else {
                      setState(() {
                        isPinCorrect =
                            false; // Set flag to false if pin is incorrect
                      });
                    }
                    return null;
                  },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    debugPrint('onCompleted: $pin');

                    String otp = pinController.text;
                    isPinCorrect
                        ? verifyOTP(widget.number, otp).then((value) {
                            if (value!.type == 'success') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyHomePage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('OTP Invalid'),
                                backgroundColor: Colors.deepOrangeAccent,
                              ));
                            }
                          })
                        : null; // Button is disabled if isPinCorrect is false
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: focusedBorderColor,
                      ),
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    textStyle: const TextStyle(color: Colors.black),
                    decoration: defaultPinTheme.decoration!.copyWith(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white),
                        color: Colors.greenAccent),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    textStyle: const TextStyle(color: Colors.black),
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: isPinCorrect
                          ? Colors.greenAccent
                          : fillColor, // Change color based on pin correctness
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: Colors.redAccent),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 11, 128),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    onPressed: () {
                      String otp = pinController.text;
                      isPinCorrect
                          ? verifyOTP(widget.number, otp).then((value) {
                              if (value!.type == 'success') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyHomePage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('OTP Invalid'),
                                  backgroundColor: Colors.deepOrangeAccent,
                                ));
                              }
                            })
                          : null; // Button is disabled if isPinCorrect is false
                    },
                    child: const Text(
                      "Submit Code",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    )),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.05,
                    left: MediaQuery.of(context).size.width * 0.04),
                alignment: Alignment.centerLeft,
                child: (_start > 0)
                    ? TextButton(
                        onPressed: () => {},
                        child: Text(
                          "Resend OTP: $_start seconds",
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ))
                    : TextButton(
                        onPressed: () => resendOTP(),
                        child: const Text(
                          "Resend OTP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.04),
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyPhone(),
                          ),
                        );
                      },
                      child: Text(
                        "Edit Phone Number ${widget.number} ? ",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}

class ManagerLoginResponse {
  final String message;
  final String type;
  ManagerLogin? customer;

  ManagerLoginResponse({
    required this.message,
    required this.type,
    this.customer,
  });

  factory ManagerLoginResponse.fromJson(Map<String, dynamic> json) {
    return ManagerLoginResponse(
      message: json['message'],
      type: json['type'],
      customer: ManagerLogin.fromJson(json['Manager']),
    );
  }
}

class ManagerLogin {
  final int id;
  final String name;
  final String phone;
  final DateTime createdAt;
  final String
      token; // Adjusted for Dart, as it doesn't have a built-in UUID type

  ManagerLogin({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    required this.token,
  });

  factory ManagerLogin.fromJson(Map<String, dynamic> json) {
    return ManagerLogin(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      token: json['token'],
    );
  }
}

class CustomerApiClient {
  CustomerApiClient(this.phone);

  final String phone; // Assuming phone is an integer

  Future<Customer> loginCustomer() async {
    final Map<String, dynamic> requestData = {
      "phone": phone,
    };
    final networkService = NetworkService();

    final response = await networkService.postWithAuth('login-customer',
        additionalData: requestData);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final Customer customer = Customer.fromJson(responseBody);
      return customer;
    } else {
      throw Exception('Failed to login Customer');
    }
  }
}

class Customer {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'],
    );
  }
}
