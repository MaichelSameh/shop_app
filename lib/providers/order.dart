import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  String userId;

  List<OrderItem> get orders => _orders;

  getData(String authToken, String userID, List<OrderItem> orders) {
    this.authToken = authToken;
    this.userId = userID;
    this._orders = orders;
    notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    var url =
        "https://shop-app-4a8bc-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";

    try {
      final http.Response res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) return;

      List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        if (orderData["products"] == null) {
          try {
            final url =
                "https://shop-app-4a8bc-default-rtdb.firebaseio.com/orders/$userId/$orderId.json?auth=$authToken";
            http.delete(Uri.parse(url));
            print("Item removed");
          } on Exception catch (e) {
            print("error removing the item");
          }
          return;
        }
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData["amount"],
            products: (orderData["products"] as List<dynamic>).map((item) {
              return CartItem(
                id: item["id"],
                title: item["title"],
                quantity: int.parse(item["quantity"].toString()),
                price: double.parse(item["price"].toString()),
              );
            }).toList(),
            dateTime: DateTime.parse(
              orderData["dateTime"],
            ),
          ),
        );
      });

      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url =
        "https://shop-app-4a8bc-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken";
    try {
      final timesTamp = DateTime.now();
      final res = await http.post(
        Uri.parse(url),
        body: json.encode({
          "amount": total,
          "dateTime": timesTamp.toIso8601String(),
          "products": cartProduct.map((e) => e.getAsMAp()).toList(),
        }),
      );
      _orders.insert(
        0,
        OrderItem(
            id: json.decode(res.body)["name"],
            amount: total,
            products: cartProduct,
            dateTime: timesTamp),
      );
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
