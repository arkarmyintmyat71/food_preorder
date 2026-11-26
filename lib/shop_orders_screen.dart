import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'profile_screen.dart';
import 'shop_menu_screen.dart';

// Home page of a shop owner: orders from students
class ShopOrdersScreen extends StatefulWidget {
  const ShopOrdersScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ShopOrdersScreenState();
  }
}

class _ShopOrdersScreenState extends State<ShopOrdersScreen> {
  List<dynamic> _orders = [];
  Map<dynamic, dynamic>? _stats;
  bool _isOpen = currentShop!['is_open'] == 1;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final shopId = currentShop!['id'];
    final response = await http.get(Uri.parse('$baseUrl/orders/shop/$shopId'));
    final statsResponse =
        await http.get(Uri.parse('$baseUrl/shops/$shopId/stats'));
    if (!mounted) return;
    setState(() {
      _orders = json.decode(response.body);
      _stats = json.decode(statsResponse.body);
    });
  }

  // pending -> cooking -> ready -> completed  (or pending -> cancelled)
  Future<void> _changeStatus(int id, String status) async {
    final url = Uri.parse('$baseUrl/orders/$id/status');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'status': status});
    final res = await http.put(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200) {
      _showSnackBar('Order #$id: ${statusText(status)}');
    } else {
      _showSnackBar(jsonDecode(res.body)['message']);
    }
    _fetchOrders();
  }

  // Open or close the shop
  Future<void> _setOpen(bool value) async {
    final url = Uri.parse('$baseUrl/shops/${currentShop!['id']}');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'name': currentShop!['name'],
      'description': currentShop!['description'],
      'image': currentShop!['image'],
      'is_open': value,
    });
    final res = await http.put(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200) {
      currentShop = jsonDecode(res.body);
      setState(() {
        _isOpen = value;
      });
      _showSnackBar(value ? 'Shop is open' : 'Shop is closed');
    } else {
      _showSnackBar('Error updating shop');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  // Buttons change with the status of the order
  Widget _buttons(dynamic order) {
    final id = order['id'];
    if (order['status'] == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _changeStatus(id, 'cancelled');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('REJECT'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _changeStatus(id, 'cooking');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const Text('ACCEPT & COOK'),
            ),
          ),
        ],
      );
    }
    if (order['status'] == 'cooking') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _changeStatus(id, 'ready');
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
          child: const Text('FOOD IS READY'),
        ),
      );
    }
    if (order['status'] == 'ready') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _changeStatus(id, 'completed');
          },
          child: const Text('STUDENT PICKED UP'),
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentShop!['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ShopMenuScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()))
                  .then((value) => setState(() {}));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text(
              _isOpen ? 'Shop is OPEN' : 'Shop is CLOSED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isOpen ? Colors.green : Colors.red,
              ),
            ),
            subtitle: Text(_stats == null
                ? ''
                : 'Today: ${_stats!['orders_today']} orders, '
                    '${toPrice(_stats!['revenue_today']).toStringAsFixed(0)} Baht'),
            value: _isOpen,
            onChanged: _setOpen,
          ),
          const Divider(height: 1),
          Expanded(
            child: _orders.isEmpty
                ? const Center(child: Text('No orders yet'))
                : RefreshIndicator(
                    onRefresh: _fetchOrders,
                    child: ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '#${order['id']} ${order['customer_name']}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      statusText(order['status']),
                                      style: TextStyle(
                                        color: statusColor(order['status']),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text('Pickup: ${order['pickup_time']}'),
                                const SizedBox(height: 8),
                                for (final item in order['items'])
                                  Text(
                                    '${item['quantity']}x ${item['name']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                if (order['note'] != null && order['note'] != '')
                                  Text(
                                    'Note: ${order['note']}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                Text(
                                  'Total: ${toPrice(order['total']).toStringAsFixed(0)} Baht',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buttons(order),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
