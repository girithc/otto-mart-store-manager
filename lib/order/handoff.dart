import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:store/main.dart';

class HandOffPage extends StatefulWidget {
  const HandOffPage({super.key});

  @override
  State<HandOffPage> createState() => _HandOffPageState();
}

class _HandOffPageState extends State<HandOffPage> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool isPinCorrect = false; // State variable to track pin correctness

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Colors.deepPurpleAccent;
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Colors.greenAccent;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'handoffbutton',
          child: Text(
            'Hand Off',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white, //Theme.of(context).colorScheme.primary,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.deepPurpleAccent, // Shadow color
                  blurRadius: 10, // Blur radius
                  spreadRadius: 2, // Spread radius
                  offset: Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: Card(
              elevation: 10,
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 10.0),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Center the contents vertically
                  children: [
                    ExpansionTile(
                      leading: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors
                                    .white, // Set the background color to white
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      20.0), // Add padding around the dialog content
                                  child: Column(
                                    mainAxisSize: MainAxisSize
                                        .min, // Use minimum space needed by children
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4, // Adjust size as needed
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              20), // Spacing between image and button
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors
                                              .deepPurpleAccent, // Set the button color
                                          shape: RoundedRectangleBorder(
                                            // Make the button shape squarish
                                            borderRadius: BorderRadius.circular(
                                                8), // Adjust the corner radius to make it more or less squarish
                                          ),
                                        ), // Close the dialog
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
                          ),
                        ),
                      ),
                      title: const Text('Rohan Joshi',
                          style: TextStyle(fontSize: 22)),
                      children: const [
                        ListTile(
                          title: Text('Phone:'),
                        ),
                        // Additional children...
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(left: 35.0, bottom: 10),
                        child: const Text(
                          'Verification Code',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ), // Pushes the button to the bottom
                    Center(
                      child: Pinput(
                        onChanged: (value) {
                          bool correct = value == '1234';
                          if (isPinCorrect != correct) {
                            setState(() {
                              isPinCorrect = correct;
                            });
                          }
                        },
                        controller: pinController,
                        focusNode: focusNode,
                        keyboardType:
                            TextInputType.number, // Restrict to number input
                        androidSmsAutofillMethod:
                            AndroidSmsAutofillMethod.smsUserConsentApi,
                        listenForMultipleSmsOnAndroid: true,
                        defaultPinTheme: defaultPinTheme,
                        separatorBuilder: (index) => const SizedBox(width: 8),
                        validator: (value) {
                          if (value == '1234') {
                            setState(() {
                              isPinCorrect =
                                  true; // Set flag to true if pin is correct
                            });
                            return null;
                          } else {
                            setState(() {
                              isPinCorrect =
                                  false; // Set flag to false if pin is incorrect
                            });
                            return 'Pin is incorrect'; // Validation message
                          }
                        },
                        // onClipboardFound: (value) {
                        //   debugPrint('onClipboardFound: $value');
                        //   pinController.setText(value);
                        // },
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          debugPrint('onCompleted: $pin');
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
                          decoration: defaultPinTheme.decoration!.copyWith(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        submittedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            color: isPinCorrect
                                ? Colors.lightGreenAccent
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
                    const Divider(),

                    const Spacer(),
                    Hero(
                      tag: 'heroButton',
                      child: ElevatedButton(
                        onPressed: isPinCorrect
                            ? () {
                                // Code to execute when the button is pressed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyHomePage()),
                                );
                              }
                            : null, // Button is disabled if isPinCorrect is false
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
                        child: const Text('Complete Handoff', // Changed text
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
