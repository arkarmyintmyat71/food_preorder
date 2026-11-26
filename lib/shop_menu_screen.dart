import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'create_menu_screen.dart';
import 'update_menu_screen.dart';

// Shop owner: list of my menu (Read + Delete). Create and Update are other pages.
class ShopMenuScreen extends StatefulWidget {
  const ShopMenuScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ShopMenuScreenState();
  }
}

class _ShopMenuScreenState extends State<ShopMenuScreen> {
  List<dynamic> _menu = [];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    // ?all=1 also shows food that is sold out
    final response = await http
        .get(Uri.parse('$baseUrl/shops/${currentShop!['id']}/menu?all=1'));
    if (!mounted) return;
    setState(() {
      _menu = json.decode(response.body);
    });
  }

  Future<void> _delMenu(int id, int index) async {
    final url = Uri.parse('$baseUrl/menu');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'id': id});
    await http.delete(url, headers: headers, body: body);
    if (!mounted) return;
    setState(() {
      _menu.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Menu'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateMenuScreen()));
            },
            child: const Text('CREATE'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final food = _menu[index];
                final soldOut = food['available'] == 0;
                return ListTile(
                  leading: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: foodImage(food['image']),
                  ),
                  title: Text(soldOut ? '${food['name']} (sold out)' : food['name']),
                  subtitle: Text(
                      '${toPrice(food['price']).toStringAsFixed(0)} Baht - ${food['category']}'),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UpdateMenuScreen(id: food['id'])));
                  },
                  trailing: ElevatedButton(
                    onPressed: () {
                      _delMenu(food['id'], index);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('DEL'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
