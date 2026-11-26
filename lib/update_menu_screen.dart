import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'shop_menu_screen.dart';

class UpdateMenuScreen extends StatefulWidget {
  final int id;
  const UpdateMenuScreen({super.key, required this.id});

  @override
  State<StatefulWidget> createState() {
    return UpdateMenuScreenState();
  }
}

class UpdateMenuScreenState extends State<UpdateMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  bool _available = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    final url = Uri.parse('$baseUrl/menu/${widget.id}');
    final response = await http.get(url);
    if (!mounted) return;
    if (response.statusCode == 200) {
      final menuData = jsonDecode(response.body)[0];
      _loadMenuData(menuData);
    } else {
      _showSnackBar('Failed to fetch menu data');
    }
  }

  void _loadMenuData(Map<String, dynamic> menuData) {
    _nameController.text = menuData['name'] ?? '';
    _descriptionController.text = menuData['description'] ?? '';
    _priceController.text = toPrice(menuData['price']).toStringAsFixed(0);
    _categoryController.text = menuData['category'] ?? '';
    _imageController.text = menuData['image'] ?? '';
    _available = menuData['available'] == 1;
    setState(() {});
  }

  Future<void> _update() async {
    final url = Uri.parse('$baseUrl/menu');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'category': _categoryController.text,
      'image': _imageController.text,
      'available': _available,
      'id': widget.id,
    });
    final res = await http.put(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200 || res.statusCode == 201) {
      _showSnackBar('Update menu success');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShopMenuScreen(),
        ),
      );
    } else {
      _showSnackBar('Error updating menu');
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
        title: const Text('Edit Menu'),
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
              decoration: const InputDecoration(labelText: 'Category'),
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
            SwitchListTile(
              title: const Text('Available'),
              value: _available,
              onChanged: (value) {
                setState(() {
                  _available = value;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _update();
                      }
                    },
                    child: const Text('EDIT')))
          ]),
        ),
      ),
    );
  }
}
