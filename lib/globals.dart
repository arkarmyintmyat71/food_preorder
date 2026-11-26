import 'package:flutter/material.dart';

const String baseUrl = 'https://food-preorder-lilac.vercel.app';

// The user who is logged in (and the shop, if the user is a shop owner)
Map<String, dynamic>? currentUser;
Map<String, dynamic>? currentShop;

// The cart. Food can only come from ONE shop.
List<Map<String, dynamic>> cartItems = [];
int? cartShopId;
String cartShopName = '';

// The database sends price as text like "50.00". This changes it to a number.
double toPrice(dynamic value) {
  return double.tryParse(value.toString()) ?? 0;
}

double cartTotal() {
  double total = 0;
  for (final item in cartItems) {
    total = total + item['price'] * item['quantity'];
  }
  return total;
}

int cartCount() {
  int count = 0;
  for (final item in cartItems) {
    count = count + (item['quantity'] as int);
  }
  return count;
}

// Text and color for each order status
String statusText(String status) {
  if (status == 'pending') return 'Waiting';
  if (status == 'cooking') return 'Cooking';
  if (status == 'ready') return 'Ready';
  if (status == 'completed') return 'Picked up';
  return 'Cancelled';
}

Color statusColor(String status) {
  if (status == 'pending') return Colors.orange;
  if (status == 'cooking') return Colors.blue;
  if (status == 'ready') return Colors.green;
  if (status == 'completed') return Colors.grey;
  return Colors.red;
}

// Picture from a URL. If there is no URL or it is broken, show an icon.
Widget foodImage(dynamic url, {IconData icon = Icons.fastfood}) {
  if (url == null || url == '') {
    return Icon(icon, size: 40, color: Colors.deepOrange);
  }
  return Image.network(
    url,
    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
        Icon(icon, size: 40, color: Colors.deepOrange),
  );
}
