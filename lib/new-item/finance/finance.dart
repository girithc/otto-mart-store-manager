import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:store/utils/constants.dart';
import 'package:store/utils/network/service.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class ItemFinance extends StatefulWidget {
  const ItemFinance({super.key, required this.itemId});

  final int itemId;

  @override
  State<ItemFinance> createState() => _ItemFinanceState();
}

class _ItemFinanceState extends State<ItemFinance> {
  bool _isEditMode = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitofquantitycontroller =
      TextEditingController();
  final TextEditingController _mrppriceController = TextEditingController();
  final TextEditingController _marginController = TextEditingController();
  final TextEditingController _gstcontroller = TextEditingController();
  final TextEditingController _buypricecontroller = TextEditingController();
  int? _selectedGst; // Assuming GST is an integer value

  final TextEditingController _schemeController = TextEditingController();
  final TextEditingController _schemeRateController = TextEditingController();
  final TextEditingController _minimumQuantityController =
      TextEditingController();
  final TextEditingController _rateAfterSchemeController =
      TextEditingController();
  final TextEditingController _schemeRateBillController =
      TextEditingController();

  final TextEditingController _quantityFreeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final TextEditingController _schemeTotal = TextEditingController();
  final TextEditingController _schemeQuantityController =
      TextEditingController();

  // Add more controllers as needed for other fields

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: !_isEditMode
          ? const Color.fromARGB(255, 189, 235, 255)
          : Colors.greenAccent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration inputDecorationAddOn(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: !_isEditMode
          ? Color.fromARGB(255, 230, 189, 255)
          : const Color.fromARGB(255, 189, 235, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration inputDecorationAddOnEdit(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Color.fromARGB(255, 230, 189, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchItemFinance();
    fetchTax();
  }

  ItemFinanceDetails? _itemFinanceDetails;
  List<Tax> _taxes = [];

  Future<void> fetchTax() async {
    http.Response response = await http.get(
      Uri.parse('$baseUrl/manager-tax-get'),
    );
    print("Response Tax: ${response.body}");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Correctly map each JSON object to a Tax instance and convert to a list
      _taxes = List<Tax>.from(jsonResponse.map((tax) => Tax.fromJson(tax)));
      setState(() {
        // This part might need adjustment based on how you want to use _taxes
        // For example, setting _selectedGst to the first tax's GST value if needed
        // _selectedGst = _taxes.isNotEmpty ? _taxes.first.gst : null;
      });
    } else {
      print("Response body is null or empty");
    }
  }

  Future<void> fetchItemFinance() async {
    Map<String, dynamic> data = {
      "id": widget.itemId,
    };

    final networkService = NetworkService();
    final response = await networkService
        .postWithAuth("/manager-item-finance-get", additionalData: data);

    print("Response Item Finance: ${response.body}");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _itemFinanceDetails = ItemFinanceDetails.fromJson(jsonResponse);
        _nameController.text = _itemFinanceDetails!.itemName;
        _quantityController.text = _itemFinanceDetails!.quantity.toString();
        _unitofquantitycontroller.text = _itemFinanceDetails!.unitOfQuantity;
        _mrppriceController.text =
            _itemFinanceDetails!.mrpPrice?.toString() ?? '';
        _buypricecontroller.text =
            _itemFinanceDetails!.buyPrice?.toString() ?? '';
        _marginController.text = _itemFinanceDetails!.margin?.toString() ?? '';
        _gstcontroller.text = _itemFinanceDetails!.gst?.toString() ?? '';

        _selectedGst = ((_itemFinanceDetails!.gst ?? 0) * 100).toInt();

        _schemeRateController.text =
            _itemFinanceDetails!.discount?.toString() ?? '';
        _minimumQuantityController.text =
            _itemFinanceDetails!.minimumQuantity?.toString() ?? '';

        if (_itemFinanceDetails!.startDate != null &&
            _itemFinanceDetails!.startDate!.isNotEmpty) {
          DateTime parsedStartDate =
              DateTime.parse(_itemFinanceDetails!.startDate!);
          String formattedStartDate =
              DateFormat('yyyy-MM-dd').format(parsedStartDate);
          _startDateController.text = formattedStartDate;
        } else {
          _startDateController.text = '';
        }

        if (_itemFinanceDetails!.endDate != null &&
            _itemFinanceDetails!.endDate!.isNotEmpty) {
          DateTime parsedEndDate =
              DateTime.parse(_itemFinanceDetails!.endDate!);
          String formattedEndDate =
              DateFormat('yyyy-MM-dd').format(parsedEndDate);
          _endDateController.text = formattedEndDate;
        } else {
          _endDateController.text = '';
        }

        if (_schemeRateController.text.isNotEmpty) {
          double schemeRate =
              double.tryParse(_schemeRateController.text) ?? 0.0;
          double mrp = double.tryParse(_mrppriceController.text) ?? 0.0;
          double buyPrice = double.tryParse(_buypricecontroller.text) ?? 0.0;
          double scheme = ((schemeRate / 100) * mrp) /
              (1 + (_itemFinanceDetails!.gst ?? 0));

          double rateAfterScheme = buyPrice - scheme;
          _schemeController.text = scheme.toStringAsFixed(2);
          _rateAfterSchemeController.text = rateAfterScheme.toStringAsFixed(2);
        }
      });
    } else {
      print("Response body is null or empty");
    }
  }

  void toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> saveDetails() async {
    if (_selectedGst == null) {
      print("GST value is not selected.");
      return;
    }

    // Check if start date is empty and set default if so
    String startDate = _startDateController.text.isEmpty
        ? '2024-01-01'
        : _startDateController.text; // Default to Jan 1, 2024 if empty

    // Check if end date is empty and set default if so
    String endDate = _endDateController.text.isEmpty
        ? '2026-12-31'
        : _endDateController.text; // Default to Dec 31, 2026 if empty

    // Check if minimum quantity is empty and set default if so
    String minimumQuantityText = _minimumQuantityController.text.isEmpty
        ? '1'
        : _minimumQuantityController.text; // Default to 1 if empty

    Map<String, dynamic> data = {
      "item_id": widget.itemId,
      "mrp_price": double.parse(_mrppriceController.text),
      "buy_price": double.parse(_buypricecontroller.text),
      "margin": double.parse(_marginController.text),
      "gst": _selectedGst! / 100,
      "discount": double.parse(_schemeRateController.text),
      "minimum_quantity":
          int.parse(minimumQuantityText), // Use the checked value
      "start_date": startDate, // Use the checked start date
      "end_date": endDate, // Use the checked end date
    };

    final networkService = NetworkService();
    final response = await networkService
        .postWithAuth('/manager-item-finance-edit', additionalData: data);

    if (response.statusCode == 200) {
      print("Response Item Finance Edit: ${response.body}");

      setState(() {
        _isEditMode = !_isEditMode;
      });
      await fetchItemFinance(); // Re-fetch item finance details to refresh the widget
    } else {
      print("Error Edit: ${response.body}");
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();

    // Check if the current controller text is a valid date
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        // If there's an error parsing the date, fallback to the current date
        initialDate = DateTime.now();
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000), // Adjust the range as needed
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      // Format and set the picked date
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _updateMargin() {
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double buyPrice = double.tryParse(_buypricecontroller.text) ?? 0;
    double gst = _selectedGst != null
        ? _selectedGst! / 100
        : 0; // Convert GST percentage to a decimal

    // Adjust buyPrice to include GST
    double buyPriceWithGst = buyPrice * (1 + (gst / 100));

    if (mrp > 0 && buyPriceWithGst > 0 && buyPriceWithGst <= mrp) {
      // Margin is calculated as ((MRP - Buy Price with GST) / MRP) * 100
      double margin = ((mrp - buyPriceWithGst) / mrp) * 100;
      _marginController.text = margin.toStringAsFixed(2);
    }
  }

  // Function to calculate and update Buy Price based on MRP and Margin
  void _updateBuyPrice() {
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double margin = double.tryParse(_marginController.text) ?? 0;
    double gst = _selectedGst != null
        ? _selectedGst! / 100
        : 0; // Convert GST percentage to a decimal

    if (mrp > 0 && margin >= 0 && margin <= 100) {
      double buyPrice = (mrp / (1 + (gst / 100))) * (1 - margin / 100);
      _buypricecontroller.text = buyPrice.toStringAsFixed(2);
    }
  }

  void _updateScheme() {
    double schemeRate = double.tryParse(_schemeRateController.text) ?? 0;
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double gst = _selectedGst != null
        ? _selectedGst! / 100
        : 0; // Convert GST percentage to a decimal
    double discount = mrp - (double.tryParse(_buypricecontroller.text) ?? 0);
    if (mrp > 0 && schemeRate >= 0 && schemeRate <= 100) {
      double scheme = (mrp * (schemeRate / 100)) / (1 + (gst / 100));
      _schemeController.text = scheme.toStringAsFixed(2);
      _rateAfterSchemeController.text =
          (mrp - discount - scheme).toStringAsFixed(2);
    }
  }

  void _updateSchemeRate() {
    double scheme = double.tryParse(_schemeController.text) ?? 0;
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double discount = mrp - (double.tryParse(_buypricecontroller.text) ?? 0);
    if (mrp > 0 && scheme >= 0) {
      double gst = _selectedGst != null ? _selectedGst! / 100 : 0;
      double schemeRate = ((scheme * (1 + (gst / 100))) / mrp) * 100;
      _schemeRateController.text = schemeRate.toStringAsFixed(2);
      _rateAfterSchemeController.text =
          (mrp - discount - scheme).toStringAsFixed(2);
    }
  }

  void _updateSchemeRateBill() {
    double schemeBillRate =
        double.tryParse(_schemeRateBillController.text) ?? 0;
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double buyPrice = double.tryParse(_buypricecontroller.text) ?? 0;

    double gst = _selectedGst != null ? _selectedGst! / 100 : 0;
    double scheme = (schemeBillRate / 100) * buyPrice;
    double schemeRate = (((scheme * (1 + (gst / 100))) / mrp) * 100);

    if (mrp > 0 && scheme >= 0 && schemeRate >= 0 && schemeRate <= 100) {
      _schemeRateController.text = schemeRate.toStringAsFixed(2);
      _schemeController.text = scheme.toStringAsFixed(2);
      _rateAfterSchemeController.text = (buyPrice - scheme).toStringAsFixed(2);
    }
  }

  void _updateSchemeFromQuantity() {
    double schemeAmount = double.tryParse(_schemeTotal.text) ?? 0;
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double buyPrice = double.tryParse(_buypricecontroller.text) ?? 0;
    double schemeQuantity =
        double.tryParse(_schemeQuantityController.text) ?? 0;
    double gst = _selectedGst != null ? _selectedGst! / 100 : 0;

    double scheme = schemeAmount / schemeQuantity;
    double schemeRate = (((scheme * (1 + (gst / 100))) / mrp) * 100);

    if (mrp > 0 && scheme >= 0 && schemeRate >= 0 && schemeRate <= 100) {
      _schemeRateController.text = schemeRate.toStringAsFixed(2);
      _schemeController.text = scheme.toStringAsFixed(2);
      _rateAfterSchemeController.text = (buyPrice - scheme).toStringAsFixed(2);
    }
  }

  void _updateSchemeRateUsingQuantity() {
    double quantityFree = double.tryParse(_quantityFreeController.text) ?? 0;
    double schemeRate = (1 / (1 + quantityFree)) * 100;
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double buyPrice = double.tryParse(_buypricecontroller.text) ?? 0;
    double scheme = buyPrice * (schemeRate / 100);
    double gst = _selectedGst != null ? _selectedGst! / 100 : 0;

    if (mrp > 0 && schemeRate >= 0 && schemeRate <= 100) {
      _schemeController.text = scheme.toStringAsFixed(2);
      _schemeRateController.text =
          (((scheme * (1 + (gst / 100))) / mrp) * 100).toStringAsFixed(2);
      _rateAfterSchemeController.text = (buyPrice - scheme).toStringAsFixed(2);

      int minimumQuantity = (quantityFree + 1).ceil();
      _minimumQuantityController.text = minimumQuantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Finance'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              TextField(
                decoration: inputDecoration(''),
                controller: _nameController,
                readOnly: true,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Quantity",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecoration(''),
                          controller: _quantityController,
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Unit",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecoration(''),
                          controller: _unitofquantitycontroller,
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "MRP Price",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecoration(''),
                          controller: _mrppriceController,
                          readOnly: !_isEditMode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Rate",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecoration(''),
                          controller: _buypricecontroller,
                          readOnly: !_isEditMode,
                          onChanged: (_) => _updateMargin(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Margin",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecoration(''),
                          controller: _marginController,
                          readOnly: !_isEditMode,
                          onChanged: (_) => _updateBuyPrice(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "GST",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        _isEditMode
                            ? DropdownButtonFormField<int>(
                                decoration: inputDecoration(""),
                                value:
                                    _selectedGst, // This should be the sum of GST and CESS where needed
                                items: _taxes.map((Tax tax) {
                                  int combinedRate = tax.gst +
                                      tax.cess; // Combine GST and CESS
                                  return DropdownMenuItem<int>(
                                    value: combinedRate,
                                    child: Text("${combinedRate / 100}%"),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    _selectedGst =
                                        newValue; // newValue will be the combined rate
                                  });

                                  _updateMargin();
                                },
                              )
                            : TextField(
                                decoration: inputDecoration(''),
                                controller: _gstcontroller,
                                readOnly: !_isEditMode,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              _isEditMode
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Scheme % Bill",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              TextField(
                                decoration: inputDecorationAddOnEdit(''),
                                controller: _schemeRateBillController,
                                readOnly: !_isEditMode,
                                onChanged: (_) => _updateSchemeRateBill(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Buy X Get 1 Free",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              TextField(
                                decoration: inputDecorationAddOnEdit(''),
                                controller: _quantityFreeController,
                                readOnly: !_isEditMode,
                                onChanged: (_) =>
                                    _updateSchemeRateUsingQuantity(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(),
              _isEditMode
                  ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Total Scheme",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              TextField(
                                decoration: inputDecorationAddOnEdit(''),
                                controller: _schemeTotal,
                                readOnly: !_isEditMode,
                                onChanged: (_) => _updateSchemeFromQuantity(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Scheme Quantity",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              TextField(
                                decoration: inputDecorationAddOnEdit(''),
                                controller: _schemeQuantityController,
                                readOnly: !_isEditMode,
                                onChanged: (_) => _updateSchemeFromQuantity(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(),
              _isEditMode
                  ? SizedBox(
                      height: 10,
                    )
                  : Container(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Scheme",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecorationAddOn(''),
                          controller: _schemeController,
                          readOnly: !_isEditMode,
                          onChanged: (_) => _updateSchemeRate(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Scheme %",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecorationAddOn(''),
                          controller: _schemeRateController,
                          readOnly: !_isEditMode,
                          onChanged: (_) => _updateScheme(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Rate after Scheme",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecorationAddOn(''),
                          controller: _rateAfterSchemeController,
                          readOnly: !_isEditMode,
                          onChanged: (_) => _updateBuyPrice(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Min Quantity",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextField(
                          decoration: inputDecorationAddOn(''),
                          controller: _minimumQuantityController,
                          readOnly: !_isEditMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Start Date",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextFormField(
                          decoration: inputDecorationAddOn(''),
                          controller: _startDateController,
                          readOnly: true, // Make it read-only
                          onTap: () {
                            if (_isEditMode) {
                              _selectDate(context, _startDateController);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "End Date",
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        TextFormField(
                          decoration: inputDecorationAddOn(''),
                          controller: _endDateController,
                          readOnly: true, // Make it read-only
                          onTap: () {
                            if (_isEditMode) {
                              _selectDate(context, _endDateController);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 25.0, top: 10, left: 20, right: 20),
        child: ElevatedButton(
          onPressed: _isEditMode ? saveDetails : toggleEditMode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(
            _isEditMode ? 'Save' : 'Edit',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class Tax {
  final int gst;
  final int cess;
  final int id;

  Tax({required this.gst, required this.cess, required this.id});

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      gst: json['GST'],
      cess: json['CESS'],
      id: json['ID'],
    );
  }
}

class ItemFinanceDetails {
  final int itemID;
  final String itemName;
  final String unitOfQuantity;
  final int quantity;
  final double? buyPrice;
  final double? mrpPrice;
  final double? gst;
  final double? margin;
  final double? discount;
  final int? minimumQuantity;
  final String? startDate;
  final String? endDate;

  ItemFinanceDetails({
    required this.itemID,
    required this.itemName,
    required this.unitOfQuantity,
    required this.quantity,
    this.buyPrice,
    this.gst,
    this.mrpPrice,
    this.margin,
    this.discount,
    this.minimumQuantity,
    this.startDate,
    this.endDate,
  });

  factory ItemFinanceDetails.fromJson(Map<String, dynamic> json) {
    String? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      // Strip out the timezone part to make it compatible with DateTime.parse
      final date = dateStr.split(' ').first;
      return date;
    }

    return ItemFinanceDetails(
      itemID: json['item_id'],
      itemName: json['item_name'],
      unitOfQuantity: json['unit_of_quantity'],
      quantity: json['quantity'],
      buyPrice: json['buy_price']?['Valid'] == true
          ? json['buy_price']['Float64']?.toDouble()
          : null,
      mrpPrice: json['mrp_price']?['Valid'] == true
          ? json['mrp_price']['Float64']?.toDouble()
          : null,
      margin: json['margin']?['Valid'] == true
          ? json['margin']['Float64']?.toDouble()
          : null,
      gst: json['gst_rate']?['Valid'] == true
          ? json['gst_rate']['Float64']?.toDouble() / 100
          : null,
      discount: json['discount']?['Valid'] == true
          ? json['discount']['Float64']?.toDouble()
          : null,
      minimumQuantity: json['minimum_quantity']?['Valid'] == true
          ? json['minimum_quantity']['Int32']
          : null,
      startDate: parseDate(json['start_date']?['String']),
      endDate: parseDate(json['end_date']?['String']),
    );
  }
}
