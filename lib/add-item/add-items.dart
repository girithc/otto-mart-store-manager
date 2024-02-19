import 'package:flutter/material.dart';

class AddItem extends StatefulWidget {
  const AddItem({required this.categoryName, super.key});
  final String categoryName;

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            shadowColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 4.0,
            title: Text(
              'Add Item: ${widget.categoryName}',
              style: const TextStyle(
                backgroundColor: Colors.white,
                color: Colors.deepPurpleAccent,
              ),
            )),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Enter Item Name',
                  labelText: 'Item Name',
                ),
                //initialValue: items[0].name,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.shopping_bag_outlined),
                  hintText: 'Enter Stock Quantity',
                  labelText: 'Stock Quantity',
                ),
                //initialValue: items[0].stockQuantity.toString(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.attach_money_outlined),
                  hintText: 'Enter Item Price',
                  labelText: 'Item Price',
                ),
                //initialValue: items[0].price.toString(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person_2_outlined),
                  hintText: 'Enter Image Link',
                  labelText: 'Image',
                ),
                initialValue: '',
                enabled: true, // Make the field read-only
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person_2_outlined),
                  hintText: 'Enter Quantity of Individual Item',
                  labelText: 'Quantity',
                ),
                initialValue: '',
                enabled: true, // Make the field read-only
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person_2_outlined),
                  hintText: 'Enter Unit Of Quantity',
                  labelText: 'Unit Of Quantity',
                ),
                initialValue: '',
                enabled: true, // Make the field read-only
              ),
              Container(
                  padding: const EdgeInsets.only(left: 150.0, top: 40.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Add Item'),
                  )),
            ],
          ),
        ));
  }
}
