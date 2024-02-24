import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:store/store/category/category.dart';
import 'package:store/store/item/items.dart';

class EditItemPage extends StatefulWidget {
  EditItemPage({super.key, required this.item});

  Item item;

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final CategoryApiClient apiClient = CategoryApiClient();
  List<Category> categories = [];
  List<String> _selectedCategories = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await apiClient.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        print(categories[1].name);
      });
    } catch (err) {
      print('(catalog)fetchCategories error $err');
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
        title: const Text('Edit Item'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: inputDecoration('Name'),
                validator: _requiredValidator,
                initialValue: widget.item.name,
              ),
              const SizedBox(height: 25),
              MultiSelectDialogField(
                items: categories
                    .map((car) => MultiSelectItem<String>(car.name, car.name))
                    .toList(),
                title: const Text("Brands"),
                initialValue:
                    widget.item.categoryNames, // Use the state variable here
                onConfirm: (List<String> values) {
                  setState(() {
                    _selectedCategories = values; // Update the state variable
                  });
                },
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                buttonText: const Text(
                  "Select Categories",
                  style: TextStyle(fontSize: 16),
                ),
                listType: MultiSelectListType.CHIP,
              ),
              const SizedBox(height: 25),
              FormBuilderTextField(
                name: 'description',
                initialValue: widget.item.description,
                decoration: inputDecoration('Description'),
                keyboardType:
                    TextInputType.phone, // Use phone keyboard type for input
                validator: (value) {
                  // Basic validation to check if the phone field is not empty
                  if (value == null || value.isEmpty) {
                    return 'Item Description.';
                  }
                  // Additional validation for phone number format can be added here
                  // For example, using regular expressions to match specific patterns
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }
}
