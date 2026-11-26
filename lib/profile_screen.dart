import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

// Profile page for both students and shop owners
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<dynamic, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final response =
        await http.get(Uri.parse('$baseUrl/users/${currentUser!['id']}'));
    if (!mounted) return;
    setState(() {
      _user = json.decode(response.body)[0];
    });
  }

  void _logout() {
    currentUser = null;
    currentShop = null;
    cartItems.clear();
    cartShopId = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value.toString());
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: _user == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Center(
                    child: ClipOval(
                      child: Container(
                        width: 120,
                        height: 120,
                        color: Colors.orange.shade100,
                        child: foodImage(_user!['avatar'], icon: Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    '${_user!['fname']} ${_user!['lname']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    _user!['username'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: Chip(
                      avatar: Icon(_user!['role'] == 'shop'
                          ? Icons.store
                          : Icons.school),
                      label: Text(
                          _user!['role'] == 'shop' ? 'Shop owner' : 'Student'),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('User ID'),
                    trailing: Text('${_user!['id']}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Member since'),
                    trailing: Text(_formatDate(_user!['created_at'])),
                  ),
                  // Only shop owners see their shop
                  if (_user!['role'] == 'shop' && currentShop != null) ...[
                    const Divider(),
                    const Text(
                      'My Shop',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Card(
                      child: ListTile(
                        leading: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child:
                              foodImage(currentShop!['image'], icon: Icons.store),
                        ),
                        title: Text(currentShop!['name']),
                        subtitle: Text(currentShop!['description'] ?? ''),
                        trailing: Text(
                          currentShop!['is_open'] == 1 ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            color: currentShop!['is_open'] == 1
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EditProfileScreen()));
                      },
                      child: const Text('EDIT PROFILE'),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('LOGOUT'),
                    ),
                  ),
                ],
              ));
  }
}
