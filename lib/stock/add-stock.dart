import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:store/store/item-detail/item-detail.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:store/main.dart';
import 'package:store/utils/constants.dart';

class AddStock extends StatefulWidget {
  final ItemTruncated item;
  const AddStock({Key? key, required this.item}) : super(key: key);

  @override
  State<AddStock> createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  int _current = 0; // Current index of the slider
  final CarouselController _controller = CarouselController();
  final TextEditingController myController = TextEditingController();
  bool isKeyboardVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Stock'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              items: widget.item.imageURLs.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                      ),
                      child: Image.network(url, fit: BoxFit.cover),
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 1.0,
                  height: 300.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
              carouselController: _controller,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.item.imageURLs.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
            ),
            InkWell(
              onTap: () => {},
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.deepPurpleAccent),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction
                      .done, // Adds a "Done" button on the keyboard
                  onFieldSubmitted: (value) {
                    // Optional: Define what happens when "Done" is pressed
                    // For example, you can unfocus the text field or move to the next field
                    FocusScope.of(context).unfocus();
                  },
                  controller: myController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.add_circle_outline_outlined,
                        color: Colors.deepPurpleAccent),
                    hintText: 'Enter Stock',
                    labelText: 'Add To Stock Quantity',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20), // Set text color to black
                  enabled: true, // Disable editing directly in the text field
                ),
              ),
            ),
            Visibility(
              visible: isKeyboardVisible,
              child: Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => FocusScope.of(context).unfocus(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.14,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
        child: ElevatedButton(
          onPressed: () async {
            int addStock = int.tryParse(myController.text) ?? 0;
            int itemId = widget.item.id; // assign your item_id value here

            // Define the URL and the body of the POST request
            var url = Uri.parse('$baseUrl/item-add-stock');
            var body = json.encode({
              'add_stock': addStock,
              'item_id': itemId,
              'store_id': 1,
            });

            // Make the HTTP POST request
            var response = await http.post(url,
                body: body, headers: {"Content-Type": "application/json"});

            // Check if the request was successful
            if (response.statusCode == 200) {
              // If successful, navigate to MyHomePage with a success SnackBar
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyHomePage()));

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Stock added successfully'),
                backgroundColor: Colors.green,
              ));
            } else {
              // If the request failed, show an error SnackBar
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Failed to add stock'),
                backgroundColor: Colors.red,
              ));
              print(response.body);
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurpleAccent, // Text color
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold), // Text style
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
            ),
            // Button size
          ),
          child: const Text(
            'Add To Stock',
            style: TextStyle(color: Colors.white, fontSize: 24), // Text color
          ),
        ),
      ),
    );
  }
}
