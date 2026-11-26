import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'my_orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CartScreenState();
  }
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();

  void _addOne(int index) {
    setState(() {
      cartItems[index]['quantity'] = cartItems[index]['quantity'] + 1;
    });
  }

  void _removeOne(int index) {
    setState(() {
      cartItems[index]['quantity'] = cartItems[index]['quantity'] - 1;
      if (cartItems[index]['quantity'] == 0) {
        cartItems.removeAt(index);
      }
      if (cartItems.isEmpty) {
        cartShopId = null;
      }
    });
  }

  void _clearCart() {
    setState(() {
      cartItems.clear();
      cartShopId = null;
    });
  }

  Future<void> _placeOrder() async {
    final url = Uri.parse('$baseUrl/orders');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_id': currentUser!['id'],
      'shop_id': cartShopId,
      'note': _noteController.text,
      'pickup_time':
          _pickupController.text.isEmpty ? 'ASAP' : _pickupController.text,
      'items': cartItems
          .map((item) => {'menu_item_id': item['id'], 'quantity': item['quantity']})
          .toList(),
    });
    final res = await http.post(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200 || res.statusCode == 201) {
      _clearCart();
      _showSnackBar('Order placed!');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
        (route) => route.isFirst,
      );
    } else {
      _showSnackBar(jsonDecode(res.body)['message']);
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
        title: const Text('My Cart'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  cartShopName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                for (int index = 0; index < cartItems.length; index++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(cartItems[index]['name']),
                    subtitle: Text(
                        '${(cartItems[index]['price'] as double).toStringAsFixed(0)} Baht'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            _removeOne(index);
                          },
                        ),
                        Text('${cartItems[index]['quantity']}',
                            style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            _addOne(index);
                          },
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                TextField(
                  controller: _pickupController,
                  decoration: const InputDecoration(
                      labelText: 'Pickup time (e.g. 12:30)',
                      hintText: 'Leave empty = as soon as possible'),
                ),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                      labelText: 'Note to shop (e.g. not spicy)'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Total: ${cartTotal().toStringAsFixed(0)} Baht',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: _placeOrder,
                    child: const Text('PLACE ORDER'),
                  ),
                ),
                TextButton(
                  onPressed: _clearCart,
                  child: const Text('Clear cart',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
    );
  }
}
