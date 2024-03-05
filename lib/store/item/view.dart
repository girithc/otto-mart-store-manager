import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:store/new-item/find-item/find-item.dart';
import 'package:store/store/item/edit.dart';
import 'package:store/new-item/finance/finance.dart';
import 'package:store/store/item/items.dart';
import 'package:store/utils/network/service.dart';

class ViewItemPage extends StatefulWidget {
  final int itemId; // Assuming 'item' is a data model or structure you have

  const ViewItemPage({Key? key, required this.itemId}) : super(key: key);

  @override
  _ViewItemPageState createState() => _ViewItemPageState();
}

class _ViewItemPageState extends State<ViewItemPage> {
  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: "",
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      fillColor: const Color.fromARGB(255, 189, 235, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  Item? item;
  double lineSpacing = 15;

  @override
  void initState() {
    super.initState();
    fetchItem();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchItem() async {
    // Fetch the item from the server

    Map<String, dynamic> data = {
      "id": widget.itemId,
    };
    final networkService = NetworkService();
    final response = await networkService.postWithAuth('/manager-get-item',
        additionalData: data);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        item = Item.fromJson(jsonResponse);
      });
    } else {
      print("error ${response.statusCode} ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: item != null
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FindItem(),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.only(
                            top: 20, left: 20, right: 20, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        height: MediaQuery.of(context).size.height * 0.12,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FindItem(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_outlined,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              // Wrap the Text widget with Expanded
                              child: Text(
                                item == null ? "Go Back" : item!.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.20,
                        child: item!.imageUrls.isNotEmpty
                            ? CarouselSlider(
                                options: CarouselOptions(
                                  enlargeCenterPage: true,
                                  viewportFraction:
                                      1, // Adjust the fraction to suit your design
                                  initialPage: 0,
                                  autoPlay: true,
                                ),
                                items: item!.imageUrls.map((imageUrl) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.white),
                                        height: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.3, // Set the height to 30% of the screen height
                                        width: double.infinity,
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            return const SizedBox(
                                              height: 50,
                                              child: Center(
                                                  child: Icon(Icons.error)),
                                            ); // Error icon when image fails to load
                                          },
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              )
                            : const Center(
                                child: Icon(Icons
                                    .image_not_supported), // Show a "no image" icon when there are no images
                              ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.only(
                                bottom: 0.0, top: 0, left: 5, right: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                if (item != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemFinance(itemId: item!.id),
                                    ),
                                  );
                                } else {
                                  // Optionally, show an error message or a loading indicator
                                  print('Item is still loading...');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: const Text(
                                'Financials',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Name",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          TextField(
                            decoration: inputDecoration('Name'),
                            controller: TextEditingController(text: item!.name),
                            readOnly: true,
                          ),
                          SizedBox(height: lineSpacing),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Categories",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8.0, // Gap between adjacent chips
                              runSpacing: 4.0, // Gap between lines
                              children: item!.categoryNames
                                  .map<Widget>((String name) {
                                return Chip(
                                    label: Text(name),
                                    backgroundColor: const Color.fromARGB(
                                        255, 189, 235, 255),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side:
                                          const BorderSide(color: Colors.white),
                                    ));
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: lineSpacing),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Brand",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          TextField(
                            decoration: inputDecoration('Brand'),
                            controller:
                                TextEditingController(text: item!.brandName),
                            readOnly: true,
                          ),
                          SizedBox(height: lineSpacing),
                          Row(
                            children: [
                              Expanded(
                                // Wrap each Column with Expanded
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Size",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    TextField(
                                      controller: TextEditingController(
                                          text: item!.quantity.toString()),
                                      decoration: inputDecoration('Size'),
                                      keyboardType: TextInputType.number,
                                      readOnly: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                // Wrap each Column with Expanded
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Unit",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    TextField(
                                      controller: TextEditingController(
                                          text: item!.unitOfQuantity),
                                      decoration: inputDecoration('Unit'),
                                      readOnly: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: lineSpacing),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Description",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          TextField(
                            controller:
                                TextEditingController(text: item!.description),
                            decoration: inputDecoration('Description'),
                            keyboardType: TextInputType
                                .multiline, // Change to multiline to handle more content
                            maxLines:
                                5, // Increase this value as needed to accommodate your content
                            readOnly: true,
                          ),
                          SizedBox(height: lineSpacing),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const CircularProgressIndicator(),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 25.0, top: 10, left: 20, right: 20),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditItemPage(item: item!),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Edit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
