import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';

class OrderDetailScreen extends StatefulWidget {
  final int id;
  const OrderDetailScreen({super.key, required this.id});

  @override
  State<StatefulWidget> createState() {
    return _OrderDetailScreenState();
  }
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<dynamic, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    final response =
        await http.get(Uri.parse('$baseUrl/orders/${widget.id}'));
    if (!mounted) return;
    setState(() {
      _order = json.decode(response.body);
    });
  }

  // The student can cancel only while the order is still waiting
  Future<void> _cancelOrder() async {
    final url = Uri.parse('$baseUrl/orders/${widget.id}/status');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'status': 'cancelled'});
    final res = await http.put(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200) {
      _showSnackBar('Order cancelled');
    } else {
      _showSnackBar(jsonDecode(res.body)['message']);
    }
    _fetchOrder();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  String _statusMessage(String status) {
    if (status == 'pending') return 'Waiting for the shop to accept';
    if (status == 'cooking') return 'The shop is cooking your food';
    if (status == 'ready') return 'Your food is ready! Go pick it up';
    if (status == 'completed') return 'Picked up. Enjoy your meal!';
    return 'This order was cancelled';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Order #${widget.id}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchOrder,
            ),
          ],
        ),
        body: _order == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor(_order!['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          statusText(_order!['status']).toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _statusMessage(_order!['status']),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    _order!['shop_name'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text('Pickup time: ${_order!['pickup_time']}'),
                  if (_order!['note'] != null && _order!['note'] != '')
                    Text('Note: ${_order!['note']}'),
                  const Divider(),
                  for (final item in _order!['items'])
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        '${item['quantity']}x',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      title: Text(item['name']),
                      trailing: Text(
                          '${(toPrice(item['price']) * item['quantity']).toStringAsFixed(0)} Baht'),
                    ),
                  const Divider(),
                  Text(
                    'Total: ${toPrice(_order!['total']).toStringAsFixed(0)} Baht',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_order!['status'] == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cancelOrder,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('CANCEL ORDER'),
                      ),
                    ),
                ],
              ));
  }
}
