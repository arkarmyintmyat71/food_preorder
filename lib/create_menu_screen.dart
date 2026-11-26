import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'shop_menu_screen.dart';

class CreateMenuScreen extends StatefulWidget {
  const CreateMenuScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CreateMenuScreenState();
  }
}

class CreateMenuScreenState extends State<CreateMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  Future<void> _create() async {
    final url = Uri.parse('$baseUrl/menu');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'shop_id': currentShop!['id'],
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'category': _categoryController.text,
      'image': _imageController.text,
      'available': true,
    });
    final res = await http.post(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200 || res.statusCode == 201) {
      _showSnackBar('Create menu success');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShopMenuScreen(),
        ),
      );
    } else {
      _showSnackBar('Error creating menu');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the food name';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price (Baht)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the price';
                } else if (double.tryParse(value) == null) {
                  return 'Price must be a number';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                  labelText: 'Category (Rice, Noodles, Drink...)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the category';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _create();
                      }
                    },
                    child: const Text('CREATE')))
          ]),
        ),
      ),
    );
  }
}
