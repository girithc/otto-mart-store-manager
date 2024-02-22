import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:store/utils/constants.dart';
import 'package:store/utils/network/service.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<Map<String, dynamic>> _brands = [];
  List<String> _selectedBrands = []; // State variable for selected brands
  List<String> _selectedDeliveryDays = [];
  List<String> _selectMOC = [];
  String communicationMode = '';

  List<Vendor> _vendors = []; // Add this line

  final List<String> _deliveryDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<MultiSelectItem<String>> _modeOfCommunicationOptions = [
    MultiSelectItem<String>('whatsapp', 'WhatsApp'),
    MultiSelectItem<String>('email', 'Email'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    getVendorList();
  }

  Future<void> _fetchBrands() async {
    final response = await http.get(Uri.parse('$baseUrl/get-brand'));
    if (response.statusCode == 200) {
      List<dynamic> brandsJson = json.decode(response.body);
      setState(() {
        _brands = brandsJson
            .map((brand) => {
                  'id': brand['id'],
                  'name': brand['name']
                      .toString()
                      .toLowerCase() // Convert brand name to lowercase
                })
            .toList();
      });
    } else {
      // Handle error or show a message
      print('Failed to load brands');
    }
  }

  Future<void> getVendorList() async {
    final response = await http.get(Uri.parse('$baseUrl/vendor-list'));
    print("Response: ${response.body} ");
    if (response.statusCode == 200) {
      // Decode the JSON response
      List<dynamic> vendorJson = json.decode(response.body);

      // Convert the dynamic list to a list of Vendor objects
      List<Vendor> vendors =
          vendorJson.map<Vendor>((json) => Vendor.fromJson(json)).toList();

      // Update the state safely inside setState
      setState(() {
        _vendors = vendors;
      });
    } else {
      print('Failed to load vendors');
    }
  }

  void _showAddVendorForm() {
    setState(() {
      _selectedBrands = [];
      _selectedDeliveryDays = [];
      _selectMOC = [];
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(
                color: Colors.black, width: 2), // Black border with 2px width
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('Add Vendor'),
          content: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'name',
                    decoration: inputDecoration('Name'),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 25),
                  MultiSelectDialogField(
                    items: _brands
                        .map((brand) => MultiSelectItem<String>(
                            brand['name'], brand['name']))
                        .toList(),
                    title: const Text("Brands"),
                    initialValue:
                        _selectedBrands, // Use the state variable here
                    onConfirm: (List<String> values) {
                      setState(() {
                        _selectedBrands = values; // Update the state variable
                      });
                    },
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    buttonText: const Text(
                      "Select Brands",
                      style: TextStyle(fontSize: 16),
                    ),
                    listType: MultiSelectListType.CHIP,
                  ),
                  const SizedBox(height: 25),
                  FormBuilderDropdown(
                    name: 'delivery_frequency',
                    decoration: inputDecoration('Delivery Frequency'),
                    validator: _requiredValidator,
                    items: ['once', 'twice', 'thrice', 'All days']
                        .map((frequency) => DropdownMenuItem(
                            value: frequency, child: Text(frequency)))
                        .toList(),
                  ),
                  const SizedBox(height: 25),
                  MultiSelectDialogField<String>(
                    items: _deliveryDays
                        .map((day) => MultiSelectItem<String>(day, day))
                        .toList(),
                    title: const Text("Delivery Days"),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    buttonText: const Text(
                      "Delivery Days",
                      style: TextStyle(fontSize: 16),
                    ),
                    onConfirm: (List<String> values) {
                      setState(() {
                        _selectedDeliveryDays = values;
                      });
                    },
                    validator: (values) {
                      if (values == null || values.isEmpty) {
                        return 'Please select at least one delivery day';
                      }
                      return null;
                    },
                    listType: MultiSelectListType.CHIP,
                  ),
                  const SizedBox(height: 25),
                  MultiSelectDialogField<String>(
                    items: _modeOfCommunicationOptions,
                    title: const Text("Mode Of Communication"),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    buttonText: const Text(
                      "Whatsapp Or Email?",
                      style: TextStyle(fontSize: 16),
                    ),
                    onConfirm: (values) {
                      setState(() {
                        _selectMOC = List<String>.from(
                            values); // Update the state variable
                      });
                    },
                    validator: (values) {
                      if (values == null || values.isEmpty) {
                        return 'Please select at least one ';
                      }
                      return null;
                    },
                    listType: MultiSelectListType.CHIP,
                  ),
                  const SizedBox(height: 25),
                  FormBuilderTextField(
                    name: 'phone',
                    decoration: inputDecoration('Phone'),
                    keyboardType: TextInputType
                        .phone, // Use phone keyboard type for input
                    validator: (value) {
                      // Basic validation to check if the phone field is not empty
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required.';
                      }
                      // Additional validation for phone number format can be added here
                      // For example, using regular expressions to match specific patterns
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  FormBuilderTextField(
                    name: 'email',
                    decoration: inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final modeOfCommunication = _formKey.currentState
                              ?.fields['mode_of_communication']?.value ??
                          [];
                      print(
                          "Selected modes of communication: $modeOfCommunication");

                      if (modeOfCommunication.contains('email')) {
                        print("Email mode selected, validating email...");
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required when Email is selected as a mode of communication.';
                        }
                        String pattern =
                            r'\S+@\S+\.\S+'; // Simplified regex for email validation
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                      }
                      return null; // No error
                    },
                  ),
                  const SizedBox(height: 25),
                  FormBuilderTextField(
                    name: 'notes',
                    decoration: inputDecoration('Notes'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _submitForm(context);
              }, // Update the callback here
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              child: const Text(
                "Add Vendor",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;

      // Encode the request body and store it in a variable
      String requestBody = jsonEncode({
        'name': formData?['name'],
        'brands': _selectedBrands,
        'phone': formData?['phone'],
        'email': formData?['email'] ?? "",
        'delivery_frequency': formData?['delivery_frequency'],
        'delivery_day': _selectedDeliveryDays,
        'mode_of_communication': _selectMOC,
        'notes': formData?['notes'] ?? "",
      });

      // Print the request body
      print("HTTP Request Body: $requestBody");

      //return;
      try {
        final response = await http.post(
          Uri.parse(
              '$baseUrl/vendor-add'), // Adjust with your actual endpoint URL
          headers: {'Content-Type': 'application/json'},
          body: requestBody, // Use the requestBody variable here
        );

        if (response.statusCode == 200) {
          Navigator.of(context).pop();

          final vendorResponse = Vendor.fromJson(json.decode(response.body));

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Vendor Added Successfully"),
                content: Text(
                    "Vendor ID: ${vendorResponse.id}\nName: ${vendorResponse.name}"),
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
          getVendorList();
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text(response.body),
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
          print('Failed to add vendor: ${response.body}');
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(e.toString()),
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
        print('Error submitting form: $e');
      }
    }
  }

  Future<void> _submitFormEdit(BuildContext context, int vendorId) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;

      // Encode the request body and store it in a variable
      String requestBody = jsonEncode({
        'id': vendorId,
        'name': formData?['name'],
        'brands': _selectedBrands,
        'phone': formData?['phone'],
        'email': formData?['email'] ?? "",
        'delivery_frequency': formData?['delivery_frequency'],
        'delivery_day': _selectedDeliveryDays,
        'mode_of_communication': _selectMOC,
        'notes': formData?['notes'] ?? "",
      });

      // Print the request body
      print("HTTP Request Body: $requestBody");

      //return;
      try {
        final response = await http.post(
          Uri.parse(
              '$baseUrl/vendor-edit'), // Adjust with your actual endpoint URL
          headers: {'Content-Type': 'application/json'},
          body: requestBody, // Use the requestBody variable here
        );

        if (response.statusCode == 200) {
          Navigator.of(context).pop();

          final vendorResponse = Vendor.fromJson(json.decode(response.body));
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Vendor Edited Successfully"),
                content: Text(
                    "Vendor ID: ${vendorResponse.id}\nName: ${vendorResponse.name}"),
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
          getVendorList();
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text('Failed to edit vendor: ${response.body}'),
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
          getVendorList();
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text('Failed to edit vendor: $e'),
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
    }
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor List'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _vendors.length,
        itemBuilder: (context, index) {
          final vendor = _vendors[index];
          return Dismissible(
              key: Key(vendor
                  .name), // Ensure the key is unique for each item in the list
              direction:
                  DismissDirection.endToStart, // Swipe from right to left
              onDismissed: (direction) {
                // Normally, you would remove the item from the list but here you'll show the dialog
              },
              confirmDismiss: (direction) async {
                // Show the dialog and return false to prevent the item from being dismissed
                setState(() {
                  // Initialize state variables with the existing vendor's values
                  _selectedBrands = vendor.brands;
                  _selectedDeliveryDays = vendor.deliveryDay;
                  _selectMOC = vendor.modeOfCommunication;
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: Colors.black,
                            width: 2), // Black border with 2px width
                      ),
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      title: const Text('Edit Vendor'),
                      content: SingleChildScrollView(
                        child: FormBuilder(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FormBuilderTextField(
                                name: 'name',
                                decoration: inputDecoration('Name'),
                                validator: _requiredValidator,
                                initialValue: vendor.name,
                              ),
                              const SizedBox(height: 25),
                              MultiSelectDialogField(
                                items: _brands
                                    .map((brand) => MultiSelectItem<String>(
                                        brand['name'], brand['name']))
                                    .toList(),
                                title: const Text("Brands"),
                                initialValue: vendor
                                    .brands, // Use the state variable here
                                onConfirm: (List<String> values) {
                                  setState(() {
                                    _selectedBrands =
                                        values; // Update the state variable
                                  });
                                },
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                buttonText: const Text(
                                  "Select Brands",
                                  style: TextStyle(fontSize: 16),
                                ),
                                listType: MultiSelectListType.CHIP,
                              ),
                              const SizedBox(height: 25),
                              FormBuilderDropdown(
                                name: 'delivery_frequency',
                                decoration:
                                    inputDecoration('Delivery Frequency'),
                                validator: _requiredValidator,
                                initialValue: vendor.deliveryFrequency,
                                items: ['once', 'twice', 'thrice', 'All days']
                                    .map((frequency) => DropdownMenuItem(
                                        value: frequency,
                                        child: Text(frequency)))
                                    .toList(),
                              ),
                              const SizedBox(height: 25),
                              MultiSelectDialogField<String>(
                                items: _deliveryDays
                                    .map((day) =>
                                        MultiSelectItem<String>(day, day))
                                    .toList(),
                                title: const Text("Delivery Days"),
                                initialValue: vendor.deliveryDay,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                buttonText: const Text(
                                  "Delivery Days",
                                  style: TextStyle(fontSize: 16),
                                ),
                                onConfirm: (List<String> values) {
                                  setState(() {
                                    _selectedDeliveryDays = values;
                                  });
                                },
                                validator: (values) {
                                  if (values == null || values.isEmpty) {
                                    return 'Please select at least one delivery day';
                                  }
                                  return null;
                                },
                                listType: MultiSelectListType.CHIP,
                              ),
                              const SizedBox(height: 25),
                              MultiSelectDialogField<String>(
                                items: _modeOfCommunicationOptions,
                                initialValue: vendor.modeOfCommunication,
                                title: const Text("Mode Of Communication"),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                buttonText: const Text(
                                  "Whatsapp Or Email?",
                                  style: TextStyle(fontSize: 16),
                                ),
                                onConfirm: (values) {
                                  setState(() {
                                    _selectMOC = List<String>.from(
                                        values); // Update the state variable
                                  });
                                },
                                validator: (values) {
                                  if (values == null || values.isEmpty) {
                                    return 'Please select at least one ';
                                  }
                                  return null;
                                },
                                listType: MultiSelectListType.CHIP,
                              ),
                              const SizedBox(height: 25),
                              FormBuilderTextField(
                                name: 'phone',
                                initialValue: vendor.phone,
                                decoration: inputDecoration('Phone'),
                                keyboardType: TextInputType
                                    .phone, // Use phone keyboard type for input
                                validator: (value) {
                                  // Basic validation to check if the phone field is not empty
                                  if (value == null || value.isEmpty) {
                                    return 'Phone number is required.';
                                  }
                                  // Additional validation for phone number format can be added here
                                  // For example, using regular expressions to match specific patterns
                                  return null;
                                },
                              ),
                              const SizedBox(height: 25),
                              FormBuilderTextField(
                                name: 'email',
                                initialValue: vendor.email,
                                decoration: inputDecoration('Email'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final modeOfCommunication = _formKey
                                          .currentState
                                          ?.fields['mode_of_communication']
                                          ?.value ??
                                      [];
                                  print(
                                      "Selected modes of communication: $modeOfCommunication");

                                  if (modeOfCommunication.contains('email')) {
                                    print(
                                        "Email mode selected, validating email...");
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email is required when Email is selected as a mode of communication.';
                                    }
                                    String pattern =
                                        r'\S+@\S+\.\S+'; // Simplified regex for email validation
                                    RegExp regex = RegExp(pattern);
                                    if (!regex.hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    }
                                  }
                                  return null; // No error
                                },
                              ),
                              const SizedBox(height: 25),
                              FormBuilderTextField(
                                name: 'notes',
                                decoration: inputDecoration('Notes'),
                                initialValue: vendor.notes,
                                maxLines: 20,
                                minLines: 1,
                                textInputAction: TextInputAction.newline,
                                // Make the field expand horizontally to fill the available space
                                expands:
                                    false, // Allow the field to expand vertically
                                keyboardType: TextInputType
                                    .multiline, // Allow multiline input
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            _submitFormEdit(context, vendor.id);
                          }, // Update the callback here
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6200EE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          child: const Text(
                            "Edit Vendor",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ],
                    );
                  },
                );
                return false; // Return false to prevent the item from being dismissed
              },
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                              color: Colors.black,
                              width: 2), // Black border with 2px width
                        ),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        title: const Text('View Vendor'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align content to the start
                            children: [
                              InputDecorator(
                                decoration: inputDecoration('Name'),
                                child: Text(vendor.name,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                              const SizedBox(height: 25),
                              InputDecorator(
                                decoration: inputDecoration('Brands'),
                                child: Text(vendor.brands.join(", "),
                                    style: const TextStyle(
                                        color: Colors
                                            .black)), // Assuming 'brands' is a list
                              ),
                              const SizedBox(height: 25),
                              InputDecorator(
                                decoration:
                                    inputDecoration('Delivery Frequency'),
                                child: Text(vendor.deliveryFrequency,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                              const SizedBox(height: 25),
                              InputDecorator(
                                decoration: inputDecoration('Delivery Days'),
                                child: Text(vendor.deliveryDay.join(", "),
                                    style: const TextStyle(
                                        color: Colors
                                            .black)), // Assuming 'deliveryDay' is a list
                              ),
                              const SizedBox(height: 25),
                              InputDecorator(
                                decoration:
                                    inputDecoration('Mode Of Communication'),
                                child: Text(
                                    vendor.modeOfCommunication.join(", "),
                                    style: const TextStyle(
                                        color: Colors
                                            .black)), // Assuming 'modeOfCommunication' is a list
                              ),
                              const SizedBox(height: 25),
                              InputDecorator(
                                decoration: inputDecoration('Phone'),
                                child: Text(vendor.phone,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                              const SizedBox(height: 25),
                              InputDecorator(
                                decoration: inputDecoration('Email'),
                                child: Text(vendor.email,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                              const SizedBox(height: 25),
                              InputDecorator(
                                decoration: inputDecoration('Notes'),
                                child: Text(vendor.notes,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                // Initialize state variables with the existing vendor's values
                                _selectedBrands = vendor.brands;
                                _selectedDeliveryDays = vendor.deliveryDay;
                                _selectMOC = vendor.modeOfCommunication;
                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(
                                          color: Colors.black,
                                          width:
                                              2), // Black border with 2px width
                                    ),
                                    backgroundColor: Colors.white,
                                    surfaceTintColor: Colors.white,
                                    title: const Text('Edit Vendor'),
                                    content: SingleChildScrollView(
                                      child: FormBuilder(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FormBuilderTextField(
                                              name: 'name',
                                              decoration:
                                                  inputDecoration('Name'),
                                              validator: _requiredValidator,
                                              initialValue: vendor.name,
                                            ),
                                            const SizedBox(height: 25),
                                            MultiSelectDialogField(
                                              items: _brands
                                                  .map((brand) =>
                                                      MultiSelectItem<String>(
                                                          brand['name'],
                                                          brand['name']))
                                                  .toList(),
                                              title: const Text("Brands"),
                                              initialValue: vendor
                                                  .brands, // Use the state variable here
                                              onConfirm: (List<String> values) {
                                                setState(() {
                                                  _selectedBrands =
                                                      values; // Update the state variable
                                                });
                                              },
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              buttonText: const Text(
                                                "Select Brands",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              listType:
                                                  MultiSelectListType.CHIP,
                                            ),
                                            const SizedBox(height: 25),
                                            FormBuilderDropdown(
                                              name: 'delivery_frequency',
                                              decoration: inputDecoration(
                                                  'Delivery Frequency'),
                                              validator: _requiredValidator,
                                              initialValue:
                                                  vendor.deliveryFrequency,
                                              items: [
                                                'once',
                                                'twice',
                                                'thrice',
                                                'All days'
                                              ]
                                                  .map((frequency) =>
                                                      DropdownMenuItem(
                                                          value: frequency,
                                                          child:
                                                              Text(frequency)))
                                                  .toList(),
                                            ),
                                            const SizedBox(height: 25),
                                            MultiSelectDialogField<String>(
                                              items: _deliveryDays
                                                  .map((day) =>
                                                      MultiSelectItem<String>(
                                                          day, day))
                                                  .toList(),
                                              title:
                                                  const Text("Delivery Days"),
                                              initialValue: vendor.deliveryDay,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              buttonText: const Text(
                                                "Delivery Days",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              onConfirm: (List<String> values) {
                                                setState(() {
                                                  _selectedDeliveryDays =
                                                      values;
                                                });
                                              },
                                              validator: (values) {
                                                if (values == null ||
                                                    values.isEmpty) {
                                                  return 'Please select at least one delivery day';
                                                }
                                                return null;
                                              },
                                              listType:
                                                  MultiSelectListType.CHIP,
                                            ),
                                            const SizedBox(height: 25),
                                            MultiSelectDialogField<String>(
                                              items:
                                                  _modeOfCommunicationOptions,
                                              initialValue:
                                                  vendor.modeOfCommunication,
                                              title: const Text(
                                                  "Mode Of Communication"),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              buttonText: const Text(
                                                "Whatsapp Or Email?",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              onConfirm: (values) {
                                                setState(() {
                                                  _selectMOC = List<
                                                          String>.from(
                                                      values); // Update the state variable
                                                });
                                              },
                                              validator: (values) {
                                                if (values == null ||
                                                    values.isEmpty) {
                                                  return 'Please select at least one ';
                                                }
                                                return null;
                                              },
                                              listType:
                                                  MultiSelectListType.CHIP,
                                            ),
                                            const SizedBox(height: 25),
                                            FormBuilderTextField(
                                              name: 'phone',
                                              initialValue: vendor.phone,
                                              decoration:
                                                  inputDecoration('Phone'),
                                              keyboardType: TextInputType
                                                  .phone, // Use phone keyboard type for input
                                              validator: (value) {
                                                // Basic validation to check if the phone field is not empty
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Phone number is required.';
                                                }
                                                // Additional validation for phone number format can be added here
                                                // For example, using regular expressions to match specific patterns
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 25),
                                            FormBuilderTextField(
                                              name: 'email',
                                              initialValue: vendor.email,
                                              decoration:
                                                  inputDecoration('Email'),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (value) {
                                                final modeOfCommunication = _formKey
                                                        .currentState
                                                        ?.fields[
                                                            'mode_of_communication']
                                                        ?.value ??
                                                    [];
                                                print(
                                                    "Selected modes of communication: $modeOfCommunication");

                                                if (modeOfCommunication
                                                    .contains('email')) {
                                                  print(
                                                      "Email mode selected, validating email...");
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Email is required when Email is selected as a mode of communication.';
                                                  }
                                                  String pattern =
                                                      r'\S+@\S+\.\S+'; // Simplified regex for email validation
                                                  RegExp regex =
                                                      RegExp(pattern);
                                                  if (!regex.hasMatch(value)) {
                                                    return 'Enter a valid email address';
                                                  }
                                                }
                                                return null; // No error
                                              },
                                            ),
                                            const SizedBox(height: 25),
                                            FormBuilderTextField(
                                              name: 'notes',
                                              decoration:
                                                  inputDecoration('Notes'),
                                              initialValue: vendor.notes,
                                              maxLines: 20,
                                              minLines: 1,
                                              textInputAction:
                                                  TextInputAction.newline,
                                              // Make the field expand horizontally to fill the available space
                                              expands:
                                                  false, // Allow the field to expand vertically
                                              keyboardType: TextInputType
                                                  .multiline, // Allow multiline input
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          _submitFormEdit(context, vendor.id);
                                        }, // Update the callback here
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF6200EE),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                        ),
                                        child: const Text(
                                          "Edit Vendor",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                            child: const Text(
                              "Edit",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6200EE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                            child: const Text(
                              "Close",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  padding: const EdgeInsets.all(
                      10), // Add padding inside the container for its children
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 1, // Spread radius
                        blurRadius: 7, // Blur radius
                        offset:
                            const Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendor.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(
                          height: 8), // Space between title and chips

                      // Brands chips
                      Wrap(
                        spacing: 6, // Space between chips
                        children: vendor.brands
                            .map((brand) => Chip(
                                  label: Text(
                                    brand,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: const Color.fromARGB(
                                      255,
                                      11,
                                      105,
                                      236), // Chip background color for brands
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: Colors
                                            .transparent), // Transparent border
                                  ),
                                ))
                            .toList(),
                      ),

                      const SizedBox(
                          height: 5), // Space between different sets of chips

                      // Phone and Mode of Communication chips
                      Wrap(
                        spacing: 6, // Space between chips horizontally
                        runSpacing:
                            6, // Space between chips vertically, creating a new "line"
                        children: [
                          Chip(
                            label: Text(vendor.phone),
                            backgroundColor: Colors
                                .greenAccent, // Different background color for phone
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color:
                                      Colors.transparent), // Transparent border
                            ),
                          ),
                          ...vendor.modeOfCommunication
                              .map((mode) => Chip(
                                    label: Text(mode),
                                    backgroundColor: Colors
                                        .greenAccent, // Background color for contact modes
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Colors
                                              .transparent), // Transparent border
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),

                      const SizedBox(
                          height: 5), // Space between different sets of chips

                      // Frequency and Delivery Day chips
                      Wrap(
                        spacing: 6, // Space between chips
                        children: [
                          Chip(
                            label: Text(
                              vendor.deliveryFrequency,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color.fromARGB(255, 11, 105,
                                236), // Background color for frequency
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color:
                                      Colors.transparent), // Transparent border
                            ),
                          ),
                          ...vendor.deliveryDay
                              .map((day) => Chip(
                                    label: Text(day),
                                    backgroundColor: const Color.fromARGB(
                                        255,
                                        149,
                                        240,
                                        251), // Background color for days
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: Colors
                                              .transparent), // Transparent border
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVendorForm,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        tooltip: 'Add Vendor',
        child: const Icon(
          Icons.person_add_sharp,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Vendor {
  final int id;
  final String name;
  final List<String> brands;
  final String phone;
  final String email;
  final String deliveryFrequency;
  final List<String> deliveryDay;
  final List<String> modeOfCommunication;
  final String notes;

  Vendor({
    required this.id,
    required this.name,
    required this.brands,
    required this.phone,
    required this.email,
    required this.deliveryFrequency,
    required this.deliveryDay,
    required this.modeOfCommunication,
    required this.notes,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brands: List<String>.from(json['brands'] ?? []),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      deliveryFrequency: json['delivery_frequency'] ?? '',
      deliveryDay: List<String>.from(json['delivery_day'] ?? []),
      modeOfCommunication:
          List<String>.from(json['mode_of_communication'] ?? []),
      notes: json['notes'] ?? '',
    );
  }
}

/*
return Container(
            margin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding = const EdgeInsets.all(
                10), // Add padding inside the container for its children
            decoration = BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Shadow color
                  spreadRadius: 1, // Spread radius
                  blurRadius: 7, // Blur radius
                  offset: const Offset(0, 3), // Changes position of shadow
                ),
              ],
            ),
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vendor.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8), // Space between title and chips

                // Brands chips
                Wrap(
                  spacing: 6, // Space between chips
                  children: vendor.brands
                      .map((brand) => Chip(
                            label: Text(brand),
                            backgroundColor: const Color.fromARGB(255, 255, 125,
                                125), // Chip background color for brands
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color:
                                      Colors.transparent), // Transparent border
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(
                    height: 5), // Space between different sets of chips

                // Phone and Mode of Communication chips
                Wrap(
                  spacing: 6, // Space between chips horizontally
                  runSpacing:
                      6, // Space between chips vertically, creating a new "line"
                  children: [
                    Chip(
                      label: Text(vendor.phone),
                      backgroundColor: Colors
                          .greenAccent, // Different background color for phone
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            color: Colors.transparent), // Transparent border
                      ),
                    ),
                    ...vendor.modeOfCommunication
                        .map((mode) => Chip(
                              label: Text(mode),
                              backgroundColor: Colors
                                  .greenAccent, // Background color for contact modes
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Colors
                                        .transparent), // Transparent border
                              ),
                            ))
                        .toList(),
                  ],
                ),

                const SizedBox(
                    height: 5), // Space between different sets of chips

                // Frequency and Delivery Day chips
                Wrap(
                  spacing: 6, // Space between chips
                  children: [
                    Chip(
                      label: Text(vendor.deliveryFrequency),
                      backgroundColor: Colors
                          .lightGreenAccent, // Background color for frequency
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            color: Colors.transparent), // Transparent border
                      ),
                    ),
                    ...vendor.deliveryDay
                        .map((day) => Chip(
                              label: Text(day),
                              backgroundColor: Colors
                                  .lightGreenAccent, // Background color for days
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Colors
                                        .transparent), // Transparent border
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ],
            ),
          );
*/       