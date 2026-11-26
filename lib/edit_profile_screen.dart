import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return EditProfileScreenState();
  }
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true; // true = show dots, false = show the password
  final TextEditingController _avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final url = Uri.parse('$baseUrl/users/${currentUser!['id']}');
    final response = await http.get(url);
    if (!mounted) return;
    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body)[0];
      _loadUserData(userData);
    } else {
      _showSnackBar('Failed to fetch user data');
    }
  }

  void _loadUserData(Map<String, dynamic> userData) {
    _fnameController.text = userData['fname'] ?? '';
    _lnameController.text = userData['lname'] ?? '';
    _emailController.text = userData['username'] ?? '';
    _avatarController.text = userData['avatar'] ?? '';
    setState(() {});
  }

  Future<void> _update() async {
    final url = Uri.parse('$baseUrl/users');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'fname': _fnameController.text,
      'lname': _lnameController.text,
      'username': _emailController.text,
      'password': _passwordController.text, // empty = keep the old password
      'avatar': _avatarController.text,
      'id': currentUser!['id'],
    });
    final res = await http.put(url, headers: headers, body: body);
    if (!mounted) return;
    if (res.statusCode == 200 || res.statusCode == 201) {
      currentUser = jsonDecode(res.body);
      _showSnackBar('Update profile success');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
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
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(
              controller: _fnameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _lnameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else if (!value.contains('@')) {
                  return 'Please enter valid email';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                hintText: 'Leave empty to keep your old password',
                suffixIcon: IconButton(
                  icon: Icon(_hidePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                ),
              ),
              obscureText: _hidePassword,
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 6) {
                  return 'Password must be at least 6 characters';
                } else {
                  return null;
                }
              },
            ),
            TextFormField(
              controller: _avatarController,
              decoration: const InputDecoration(labelText: 'Avatar (picture URL)'),
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
                    child: const Text('SAVE')))
          ]),
        ),
      ),
    );
  }
}