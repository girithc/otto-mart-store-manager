import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/store/item-detail/item-detail.dart';

class ItemDetails extends StatefulWidget {
  const ItemDetails({required this.itemId, required this.itemName, super.key});

  final int itemId;
  final String itemName;

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  bool isDataFetched = false; // Flag to indicate whether data is fetched
  bool isListeningForBarcode = false;

  final ItemDetailApiClient apiClient = ItemDetailApiClient();
  List<Item> items = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Create an updated item based on form inputs
    Item updatedItem = Item(
        id: widget.itemId,
        barcode: items[0].barcode,
        name: _nameController.text,
        mrpPrice: int.parse(_priceController.text),
        stockQuantity: int.parse(_stockQuantityController.text),
        images: [_imageController.text],
        categories: items[0].categories,
        discount: 0,
        storePrice: 0,
        quantity: 0,
        unitOfQuantity: '');

    try {
      await apiClient
          .editItem(updatedItem); // Call your updateItem function here

      // Optionally, update the local state to reflect the changes
      setState(() {
        //items[0] = updatedItem.name;
      });

      // Handle success, show a toast, navigate back, etc.
    } catch (error) {
      // Handle error, show an error message, etc.
    }
  }

  Future<void> _showEditBarcodeDialog(context) async {
    TextEditingController barcodeEditController =
        TextEditingController(text: _imageController.text);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Barcode'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: barcodeEditController,
                  decoration: const InputDecoration(hintText: 'Enter Barcode'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _imageController.text = barcodeEditController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onBarcodeScanned(String scannedBarcode) {
    if (isListeningForBarcode) {
      setState(() {
        _barcodeController.text = scannedBarcode;
        isListeningForBarcode = false;
      });
      addBarcode().then(
        (success) => {
          Navigator.of(context).pop(),
          if (!success) {_showErrorDialog('Error in saving barcode.')}
        },
      );

      if (!mounted) return;
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchItem();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _barcodeController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> fetchItem() async {
    try {
      final fetchedItem = await apiClient.fetchItem(widget.itemId);
      setState(() {
        print(
            "Fetched Item ${fetchedItem.name}, ${fetchedItem.mrpPrice}, ${fetchedItem.stockQuantity}");
        //throw Exception("Debug");
        items.add(fetchedItem);
        _nameController.text = fetchedItem.name;
        _priceController.text = fetchedItem.mrpPrice.toString();
        _stockQuantityController.text = fetchedItem.stockQuantity.toString();
        _barcodeController.text = fetchedItem.barcode;
        _imageController.text = fetchedItem.images[0];
        isDataFetched = true; // Mark data as fetched
      });
    } catch (err) {
      //Handle Error
      setState(() {
        items = [];
      });
      print('(itemdetails)fetchItems error $err');
    }
  }

  Future<bool> addBarcode() async {
    try {
      final fetchedItem =
          await apiClient.addBarcode(widget.itemId, _barcodeController.text);
      print("Barcode controller: ${_barcodeController.text} ");
      setState(() {
        print(
            "Fetched Item ${fetchedItem.name}, ${fetchedItem.mrpPrice}, ${fetchedItem.stockQuantity}");
        //throw Exception("Debug");
        items.add(fetchedItem);
        _nameController.text = fetchedItem.name;
        _priceController.text = fetchedItem.mrpPrice.toString();
        _stockQuantityController.text = fetchedItem.stockQuantity.toString();
        _imageController.text = fetchedItem.images[0];
        _barcodeController.text = fetchedItem.barcode;
        isDataFetched = true; // Mark data as fetched
      });

      return true;
    } catch (err) {
      //Handle Error
      setState(() {
        items = [];
      });
      print('(itemdetails)fetchItems error $err');
      return false;
    }
  }

  String? _scanBarcodeResult;

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      setState(() {
        _scanBarcodeResult = barcodeScanRes;
        _barcodeController.text = barcodeScanRes;
      });
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version';
      // TODO
    }

    addBarcode().then(
      (success) => {
        Navigator.of(context).pop(),
        if (!success) {_showErrorDialog('Error in saving barcode.')}
      },
    );

    if (!mounted) return;
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditFieldDialog(
      TextEditingController controller, String title) async {
    TextEditingController editController =
        TextEditingController(text: controller.text);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: editController,
                  decoration: InputDecoration(hintText: 'Enter $title'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            title == "Barcode"
                ? TextButton(
                    child: isListeningForBarcode
                        ? const Text('Barcode')
                        : const Text('Change'),
                    onPressed: () {
                      scanBarcode();
                      /*
                      setState(() {
                        isListeningForBarcode = !isListeningForBarcode;
                      });
                      */
                    },
                  )
                : const SizedBox.shrink(),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  controller.text = editController.text;
                });
                title == "Barcode"
                    ? setState(() {
                        _barcodeController.text = editController.text;
                        addBarcode().then(
                          (success) => {
                            Navigator.of(context).pop(),
                            if (!success)
                              {_showErrorDialog('Error in saving barcode.')}
                          },
                        );
                      })
                    : Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required String labelText,
  }) {
    return InkWell(
      onTap: () => _showEditFieldDialog(controller, labelText),
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.deepPurpleAccent),
            hintText: hintText,
            labelText: labelText,
            border: InputBorder.none,
          ),
          style:
              const TextStyle(color: Colors.black), // Set text color to black
          enabled: false, // Disable editing directly in the text field
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          widget.itemName,
          style: const TextStyle(
              color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BarcodeKeyboardListener(
          onBarcodeScanned: (String code) {
            if (isListeningForBarcode) onBarcodeScanned(code);
          },
          child: Center(
            child: isDataFetched
                ? Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildCustomTextField(
                          controller: _nameController,
                          icon: Icons.person,
                          hintText: 'Enter Item Name',
                          labelText: 'Item Name',
                        ),
                        _buildCustomTextField(
                          controller: _stockQuantityController,
                          icon: Icons.shopping_bag_outlined,
                          hintText: 'Enter Stock Quantity',
                          labelText: 'Stock Quantity',
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCustomTextField(
                                controller: _priceController,
                                icon: Icons.attach_money_outlined,
                                hintText: 'Enter Item Price',
                                labelText: 'Item Price',
                              ),
                            ),
                            const SizedBox(
                                width: 8), // Spacing between two text fields
                            Expanded(
                              child: _buildCustomTextField(
                                controller:
                                    _priceController, // Duplicate controller for demonstration
                                icon: Icons.attach_money_outlined,
                                hintText: 'Enter MRP Price',
                                labelText: 'MRP Price',
                              ),
                            ),
                          ],
                        ),
                        _buildCustomTextField(
                          controller: _barcodeController,
                          icon: Icons.barcode_reader,
                          hintText: 'Barcode',
                          labelText: 'Barcode',
                        ),
                        _buildCustomTextField(
                          controller: _imageController,
                          icon: Icons.image_outlined,
                          hintText: 'Enter Image Link',
                          labelText: 'Image',
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(), // Show a loading indicator when data is being fetched
          ),
        ),
      ),
    );
  }
}

class ImageUpload extends StatefulWidget {
  const ImageUpload({super.key, required this.image});

  final String image;

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? _image;
  Uint8List? _imageBytes;
  final picker = ImagePicker();
  String? _imageName;

  //image picker
  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        _image = imageTemp;
        print('Image: ${_image?.path}');
        _imageBytes = _image?.readAsBytesSync();
        _imageName = _image?.path.split('/').last;
      });
    } on Exception catch (e) {
      print('Failed to pick image $e');
    }
  }

  void _saveImage() async {}

  @override
  void initState() {
    super.initState(); // Call the superclass's initState method
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _image != null
              ? Image.file(_image!, width: 250, height: 250, fit: BoxFit.cover)
              : Image.network(widget.image, height: 300),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                  child: const Text('Add Image')),
            ],
          )
        ],
      ),
    );
  }
}
