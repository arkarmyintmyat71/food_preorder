import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyOrdersScreenState();
  }
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final response = await http
        .get(Uri.parse('$baseUrl/orders/user/${currentUser!['id']}'));
    if (!mounted) return;
    setState(() {
      _orders = json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: _orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final foods = (order['items'] as List)
                      .map((item) => '${item['quantity']}x ${item['name']}')
                      .join(', ');
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Order #${order['id']} - ${order['shop_name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '$foods\nPickup: ${order['pickup_time']}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            statusText(order['status']),
                            style: TextStyle(
                              color: statusColor(order['status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${toPrice(order['total']).toStringAsFixed(0)} Baht'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OrderDetailScreen(id: order['id'])))
                            .then((value) => _fetchOrders());
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
