import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'profile_screen.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';

// Home page of a student: list of all shops
class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ShopsScreenState();
  }
}

class _ShopsScreenState extends State<ShopsScreen> {
  List<dynamic> _shops = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    final search = Uri.encodeQueryComponent(_searchController.text);
    final response = await http.get(Uri.parse('$baseUrl/shops?search=$search'));
    if (!mounted) return;
    setState(() {
      _shops = json.decode(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${currentUser!['fname']}'),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${cartCount()}'),
              isLabelVisible: cartItems.isNotEmpty,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const CartScreen()))
                  .then((value) => setState(() {}));
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyOrdersScreen()));
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search shop',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchShops();
                  },
                ),
              ),
              onSubmitted: (value) {
                _fetchShops();
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchShops,
              child: ListView.builder(
                itemCount: _shops.length,
                itemBuilder: (context, index) {
                  final shop = _shops[index];
                  final isOpen = shop['is_open'] == 1;
                  return Card(
                    child: ListTile(
                      leading: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: foodImage(shop['image'], icon: Icons.store),
                      ),
                      title: Text(
                        shop['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${shop['description']}\n${shop['menu_count']} menu items',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        isOpen ? 'OPEN' : 'CLOSED',
                        style: TextStyle(
                          color: isOpen ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MenuScreen(shop: shop)))
                            .then((value) => setState(() {}));
                      },
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
