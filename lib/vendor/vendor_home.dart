import 'package:flutter/material.dart';
import 'package:store/vendor/vendor%20list/vendorlist.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Home'),
        centerTitle: true,
      ),
      body: Material(
        color: Colors.white,
        child: Column(children: [
          GestureDetector(
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VendorListScreen()),
              )
            },
            child: Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Rounded borders
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25), // Shadow color
                      spreadRadius: 0,
                      blurRadius: 20, // Increased shadow blur
                      offset: const Offset(0, 10), // Increased vertical offset
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Vendor List',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
