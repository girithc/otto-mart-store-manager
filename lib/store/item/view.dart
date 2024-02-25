import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:store/store/item/edit.dart';
import 'package:store/store/item/image.dart';
import 'package:store/store/item/items.dart';

class ViewItemPage extends StatefulWidget {
  final Item item; // Assuming 'item' is a data model or structure you have

  const ViewItemPage({Key? key, required this.item}) : super(key: key);

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

  double lineSpacing = 15;
  @override
  void dispose() {
    //_viewFormKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              height: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_outlined)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemImage(item: widget.item),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: widget.item.imageUrls.isNotEmpty
                        ? CarouselSlider(
                            options: CarouselOptions(
                              enlargeCenterPage: true,
                              viewportFraction:
                                  0.6, // Adjust the fraction to suit your design
                              initialPage: 0,
                              autoPlay: true,
                            ),
                            items: widget.item.imageUrls.map((imageUrl) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.3, // Set the height to 30% of the screen height
                                    width: double.infinity,
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
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
                                          child:
                                              Center(child: Icon(Icons.error)),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: FormBuilder(
                    //key: _viewFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Name",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        FormBuilderTextField(
                          name: 'editname',
                          decoration: inputDecoration('Name'),
                          initialValue: widget.item.name,
                          readOnly: true,
                        ),
                        SizedBox(height: lineSpacing),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Categories",
                            style: TextStyle(color: Colors.black, fontSize: 12),
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
                            children: widget.item.categoryNames
                                .map<Widget>((String name) {
                              return Chip(
                                  label: Text(name),
                                  backgroundColor:
                                      const Color.fromARGB(255, 189, 235, 255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Colors.white),
                                  ));
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: lineSpacing),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Brand",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        FormBuilderTextField(
                          name: 'editbrand',
                          decoration: inputDecoration('Brand'),
                          initialValue: widget.item.brandName,
                          validator: (value) {
                            if (value == null) {
                              return 'Brand';
                            }
                            return null;
                          },
                          readOnly: true,
                        ),
                        SizedBox(height: lineSpacing),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Description",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        FormBuilderTextField(
                          name: 'editdescription',
                          initialValue: widget.item.description ?? "",
                          decoration: inputDecoration('Description'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Item Description.';
                            }
                            return null;
                          },
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
                                  FormBuilderTextField(
                                    name: 'editsize',
                                    initialValue: widget.item.quantity
                                        .toString(), // Use actual initial value
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
                                  FormBuilderTextField(
                                    name: 'editunit',
                                    initialValue: widget.item
                                        .unitOfQuantity, // Use actual initial value
                                    decoration: inputDecoration('Unit'),
                                    readOnly: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 25.0, top: 10, left: 20, right: 20),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditItemPage(item: widget.item),
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
