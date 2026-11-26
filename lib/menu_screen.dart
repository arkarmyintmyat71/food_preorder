import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'cart_screen.dart';

// Menu of one shop. The student adds food to the cart here.
class MenuScreen extends StatefulWidget {
  final Map<String, dynamic> shop;
  const MenuScreen({super.key, required this.shop});

  @override
  State<StatefulWidget> createState() {
    return _MenuScreenState();
  }
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _menu = [];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    final response =
        await http.get(Uri.parse('$baseUrl/shops/${widget.shop['id']}/menu'));
    if (!mounted) return;
    setState(() {
      _menu = json.decode(response.body);
    });
  }

  void _addToCart(dynamic food) {
    // One order = one shop
    if (cartItems.isNotEmpty && cartShopId != widget.shop['id']) {
      _showSnackBar(
          'Your cart has food from $cartShopName. Please clear the cart first.');
      return;
    }
    cartShopId = widget.shop['id'];
    cartShopName = widget.shop['name'];

    final index = cartItems.indexWhere((item) => item['id'] == food['id']);
    setState(() {
      if (index >= 0) {
        cartItems[index]['quantity'] = cartItems[index]['quantity'] + 1;
      } else {
        cartItems.add({
          'id': food['id'],
          'name': food['name'],
          'price': toPrice(food['price']),
          'image': food['image'],
          'quantity': 1,
        });
      }
    });
    _showSnackBar('Added ${food['name']}');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = widget.shop['is_open'] == 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop['name']),
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 160,
            child: foodImage(widget.shop['image'], icon: Icons.store),
          ),
          if (!isOpen)
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'This shop is closed now. You cannot order.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final food = _menu[index];
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: foodImage(food['image']),
                    ),
                    title: Text(food['name']),
                    subtitle: Text(
                      '${food['description']}\n${toPrice(food['price']).toStringAsFixed(0)} Baht',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: isOpen
                          ? () {
                              _addToCart(food);
                            }
                          : null,
                      child: const Text('ADD'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: cartItems.isEmpty || cartShopId != widget.shop['id']
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()))
                      .then((value) => setState(() {}));
                },
                child: Text(
                    'VIEW CART (${cartCount()})  -  ${cartTotal().toStringAsFixed(0)} Baht'),
              ),
            ),
    );
  }
}
