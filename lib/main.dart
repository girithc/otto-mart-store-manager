import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:store/inventory/inventory.dart';
import 'package:store/new-item/find-item/find-item.dart';
import 'package:store/shelf/shelf.dart';
import 'package:store/shelf/shelfhome.dart';
import 'package:store/store/item/items.dart';
import 'package:store/store/stores.dart';
import 'package:store/utils/login/page/phone_screen.dart';
import 'package:store/utils/login/provider/loginProvider.dart';
import 'package:store/utils/network/service.dart';
import 'package:store/vendor/vendor_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
      create: (context) => LoginProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scooter Animation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        // Assuming checkLogin() is an asynchronous method that returns a Future<bool>
        future: Provider.of<LoginProvider>(context, listen: false).checkLogin(),
        builder: (context, snapshot) {
          // Check if the future is complete
          if (snapshot.connectionState == ConnectionState.done) {
            // If the user is logged in
            if (snapshot.data == true) {
              return const MyHomePage();
            } else {
              // If the user is not logged in
              return const MyPhone();
            }
          } else {
            // Show loading indicator while waiting for login check
            return const CircularProgressIndicator();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _scanBarcodeResult;

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version';
      // TODO
    }

    if (!mounted) return;
    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version';
      // TODO
    }

    if (!mounted) return;
    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shadowColor: Colors.white,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VendorHomeScreen()),
                      )
                    },
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 7.5, top: 15, bottom: 7.5),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded borders
                          color: Colors.grey.shade100,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.2), // Shadow color
                              spreadRadius: 0,
                              blurRadius: 20, // Increased shadow blur
                              offset: const Offset(
                                  0, 10), // Increased vertical offset
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Vendor',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  ),
                  /*
                GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FindItem()),
                    )
                  },
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 15, right: 7.5, top: 7.5, bottom: 7.5),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded borders
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Shadow color
                            spreadRadius: 0,
                            blurRadius: 20, // Increased shadow blur
                            offset: const Offset(
                                0, 10), // Increased vertical offset
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'New Item',
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                ),
                */
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Stores()),
                      )
                    },
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 7.5, top: 7.5, bottom: 7.5),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded borders
                          color: Colors.grey.shade100,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.2), // Shadow color
                              spreadRadius: 0,
                              blurRadius: 20, // Increased shadow blur
                              offset: const Offset(
                                  0, 10), // Increased vertical offset
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Stores',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShelfHome()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded borders
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Shadow color
                            spreadRadius: 0,
                            blurRadius: 20, // Increased shadow blur
                            offset: const Offset(
                                0, 10), // Increased vertical offset
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Shelves',
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      TextEditingController cartIdController =
                          TextEditingController();
                      // Show dialog to enter cartId
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Enter Cart ID'),
                            content: TextField(
                              controller: cartIdController,
                              decoration:
                                  const InputDecoration(hintText: 'Cart ID'),
                              keyboardType: TextInputType
                                  .number, // Assuming cartId is numeric
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Submit'),
                                onPressed: () async {
                                  // Get cart ID from text field
                                  String cartId = cartIdController.text;
                                  if (cartId.isNotEmpty) {
                                    // Dismiss the dialog first
                                    Navigator.of(context).pop();
                                    final networkService = NetworkService();
                                    // Then send HTTP request with cartId
                                    Map<String, dynamic> body = {
                                      "cart_id": int.parse(cartId)
                                    };

                                    final response = await networkService
                                        .postWithAuth('/manager-create-order',
                                            additionalData: body);

                                    print("Response ${response.body}");

                                    if (response.statusCode == 200) {
                                    } else {
                                      // Handle error or show error message
                                    }
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 7.5, top: 7.5, bottom: 7.5),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Create Order (Paid)',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final networkService = NetworkService();
                        final response = await networkService.postWithAuth(
                            '/manager-item-store-combo',
                            additionalData: {});

                        print("Response: ${response.body}");
                        if (response.statusCode == 200) {
                          // Decode the response body

                          final result = json.decode(response.body);

                          // Check if the result is true or false
                          if (result == true) {
                            // Show success dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Success'),
                                  content:
                                      const Text('Operation was successful.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Dismiss dialog
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Show failure dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Failure'),
                                  content: const Text('Operation failed.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Dismiss dialog
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          // If the server did not return a 200 OK response,
                          // then throw an exception.
                          throw Exception('Failed to load data');
                        }
                      } catch (e) {
                        /*
                            // Handle exception by showing a dialog, snackbar, etc.
                            print(e); // For debugging purposes
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: Text('An error occurred: $e'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Dismiss dialog
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          */
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded borders
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Shadow color
                            spreadRadius: 0,
                            blurRadius: 20, // Increased shadow blur
                            offset: const Offset(
                                0, 10), // Increased vertical offset
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Item Store Combo',
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Show the dialog to ask for a phone number
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final TextEditingController phoneController =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Enter Phone Number'),
                            content: TextField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                  hintText: "Enter 10-digit phone number"),
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the phone number dialog
                                  String phoneNumber = phoneController.text;

                                  // Validate phone number length
                                  if (phoneNumber.length != 10) {
                                    // Show some error to the user
                                    return;
                                  }

                                  try {
                                    final networkService = NetworkService();
                                    final response = await networkService
                                        .postWithAuth('/manager-fcm-packer',
                                            additionalData: {
                                          'phone': phoneNumber,
                                        });

                                    print("Response: ${response.body}");
                                    if (response.statusCode == 200) {
                                      // Decode the response body
                                      final result = json.decode(response.body);

                                      // Check if the result is true or false
                                      if (result == true) {
                                        // Show success dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Success'),
                                              content: const Text(
                                                  'Operation was successful.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Dismiss success dialog
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        // Show failure dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Failure'),
                                              content: const Text(
                                                  'Operation failed.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Dismiss failure dialog
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      // Handle server errors or invalid responses
                                      throw Exception(
                                          'Failed to send notification');
                                    }
                                  } catch (e) {
                                    // Handle exceptions by showing an error dialog or logging
                                  }
                                },
                                child: const Text('Send'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the dialog without doing anything
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded borders
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Shadow color
                            spreadRadius: 0,
                            blurRadius: 20, // Increased shadow blur
                            offset: const Offset(
                                0, 10), // Increased vertical offset
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Send Notification (Packer)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Show the dialog to ask for a phone number
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final TextEditingController phoneController =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Enter Phone Number'),
                            content: TextField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                  hintText: "Enter 10-digit phone number"),
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the phone number dialog
                                  String phoneNumber = phoneController.text;

                                  // Validate phone number length
                                  if (phoneNumber.length != 10) {
                                    // Show some error to the user
                                    return;
                                  }

                                  try {
                                    final networkService = NetworkService();
                                    final response = await networkService
                                        .postWithAuth('/manager-fcm',
                                            additionalData: {
                                          'phone': phoneNumber,
                                        });

                                    print("Response: ${response.body}");
                                    if (response.statusCode == 200) {
                                      // Decode the response body
                                      final result = json.decode(response.body);

                                      // Check if the result is true or false
                                      if (result == true) {
                                        // Show success dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Success'),
                                              content: const Text(
                                                  'Operation was successful.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Dismiss success dialog
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        // Show failure dialog
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Failure'),
                                              content: const Text(
                                                  'Operation failed.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Dismiss failure dialog
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      // Handle server errors or invalid responses
                                      throw Exception(
                                          'Failed to send notification');
                                    }
                                  } catch (e) {
                                    // Handle exceptions by showing an error dialog or logging
                                  }
                                },
                                child: const Text('Send'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the dialog without doing anything
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15), // Rounded borders
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Shadow color
                            spreadRadius: 0,
                            blurRadius: 20, // Increased shadow blur
                            offset: const Offset(
                                0, 10), // Increased vertical offset
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Send Notification (Customer)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                  ),

                  /*
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListenBarcodePage()),
                    );
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // Rounded borders
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25), // Shadow color
                          spreadRadius: 0,
                          blurRadius: 20, // Increased shadow blur
                          offset:
                              const Offset(0, 10), // Increased vertical offset
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Add+ Item Detail',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: scanBarcode,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // Rounded borders
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25), // Shadow color
                          spreadRadius: 0,
                          blurRadius: 20, // Increased shadow blur
                          offset:
                              const Offset(0, 10), // Increased vertical offset
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Add+ Item Quick',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Scanner(),
                      ),
                    );
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // Rounded borders
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25), // Shadow color
                          spreadRadius: 0,
                          blurRadius: 20, // Increased shadow blur
                          offset:
                              const Offset(0, 10), // Increased vertical offset
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Scanner',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
                
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrderChecklistPage()),
                      );
                    },
                    child: Card(
                      elevation: 10,
                      color: Colors.grey.shade100,
                      surfaceTintColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center the contents vertically
                          children: [
                            const Center(
                                child:
                                    Text('Incoming Order')), // Your existing text
                            const Spacer(), // Pushes the button to the bottom
                            Hero(
                              tag: 'heroButton',
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const OrderChecklistPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width * 0.1,
                                      vertical: 15),
                                ),
                                child: const Text('Start Checklist',
                                    style: TextStyle(
                                        color: Colors.grey.shade100, fontSize: 20)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                */
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: GestureDetector(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyInventory()),
              )
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                  child: Text(
                "Get Inventory",
                style: TextStyle(
                    color: Colors.grey.shade100,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )),
            ),
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
