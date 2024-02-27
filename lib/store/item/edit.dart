import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:store/store/category/category.dart';
import 'package:store/store/item/items.dart';
import 'package:store/store/item/view.dart';
import 'package:store/utils/network/service.dart';

class EditItemPage extends StatefulWidget {
  final Item item;

  const EditItemPage({Key? key, required this.item}) : super(key: key);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  // Assuming CategoryApiClient and Brand are defined elsewhere in your code
  final CategoryApiClient apiClient = CategoryApiClient();
  List<Category> categories = [];
  List<Brand> brands = [];
  List<String> _selectedCategories = [];
  double lineSpacing = 10;

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

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchBrands();
    _selectedCategories = widget.item.categoryNames;
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await apiClient.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        //print(categories[1].name);
      });
    } catch (err) {
      print('(catalog)fetchCategories error $err');
    }
  }

  Future<void> fetchBrands() async {
    try {
      final fetchedBrands = await apiClient.fetchBrands();
      setState(() {
        brands = fetchedBrands;
        //print(brands);
      });
    } catch (err) {
      print('(catalog)fetchCategories error $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Name",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FormBuilderTextField(
                    name: 'editname',
                    decoration: inputDecoration(""),
                    validator: _requiredValidator,
                    initialValue: widget.item.name,
                  ),
                  SizedBox(height: lineSpacing),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Categories",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 2),
                  MultiSelectDialogField(
                    backgroundColor: const Color.fromARGB(255, 189, 235, 255),
                    items: categories
                        .map((car) =>
                            MultiSelectItem<String>(car.name, car.name))
                        .toList(),
                    title: const Text("Categories"),
                    initialValue: widget.item.categoryNames,
                    onConfirm: (List<String> values) {
                      setState(() {
                        _selectedCategories = values;
                      });
                    },
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 189, 235, 255),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    buttonText: const Text(
                      "",
                      style: TextStyle(fontSize: 16),
                    ),
                    listType: MultiSelectListType.CHIP,
                  ),
                  SizedBox(height: lineSpacing),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Brand",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FormBuilderDropdown(
                    name: 'editbrand',
                    decoration: inputDecoration(''),
                    initialValue: widget.item.brandId,
                    validator: (value) {
                      if (value == null) {
                        return 'Brand';
                      }
                      return null;
                    },
                    items: brands
                        .map((brand) => DropdownMenuItem(
                              value: brand.id,
                              child: Text(brand.name),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: lineSpacing),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Description",
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FormBuilderTextField(
                    name: 'editdescription',
                    initialValue: widget.item.description ?? "",
                    decoration: inputDecoration(''),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Item Description.';
                      }
                      return null;
                    },
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            FormBuilderTextField(
                              name: 'editsize',
                              initialValue: widget.item.quantity.toString(),
                              decoration: inputDecoration(''),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Size.';
                                }
                                return null;
                              },
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            FormBuilderDropdown(
                              name: 'editunit',
                              decoration: inputDecoration(''),
                              initialValue: widget.item.unitOfQuantity,
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a unit';
                                }
                                return null;
                              },
                              items: const [
                                DropdownMenuItem(
                                    value: 'kg', child: Text('kg')),
                                DropdownMenuItem(value: 'g', child: Text('g')),
                                DropdownMenuItem(
                                    value: 'mg', child: Text('mg')),
                                DropdownMenuItem(
                                    value: 'ct', child: Text('ct')),
                                DropdownMenuItem(
                                    value: 'ml', child: Text('ml')),
                                DropdownMenuItem(value: 'l', child: Text('l')),
                              ],
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
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 25.0, top: 10, left: 20, right: 20),
        child: ElevatedButton(
          onPressed: _saveItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _saveItem() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Extract the form data
      final formData = _formKey.currentState?.value;
      // Construct the request payload
      Map<String, dynamic> payload = {
        'id': widget.item.id,
        'name': formData?['editname'],
        'brand_id': formData?['editbrand'],
        'description': formData?['editdescription'],
        'size': int.tryParse(formData?['editsize'] ?? '0'),
        'unit': formData?['editunit'],
        'categories': _selectedCategories,
      };

      // Send the HTTP request
      try {
        final networkService = NetworkService();
        final response = await networkService.postWithAuth(
          '/manager-item-edit',
          additionalData: payload,
        );

        // Check if the request was successful
        if (response.statusCode == 200) {
          // Parse the response body if needed
          final responseData = json.decode(response.body);
          print("Response: $responseData  ");

          // Show a success dialog
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Item updated successfully.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewItemPage(
                          itemId: widget.item.id,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          // Handle errors or unsuccessful responses
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (e) {
        // Handle any exceptions
        print('An error occurred: $e');
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }
}
