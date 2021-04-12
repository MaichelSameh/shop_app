import 'package:flutter/material.dart';

class CartItem {
  String _id;
  String _title;
  double _price;
  int _quantity;

  String get id => _id;
  String get title => _title;
  int get quantity => _quantity;
  double get price => _price;
  CartItem({
    @required String id,
    @required String title,
    @required int quantity,
    @required double price,
  }) {
    _id = id;
    _title = title;
    _price = price;
    _quantity = quantity;
  }

  Map<String, Object> getAsMAp() {
    return {
      "id": id,
      "title": title,
      "price": price,
      "quantity": quantity,
    };
  }
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => items.length;

  double get totalAmount {
    double total = 0.0;
    items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
        ),
      );
      notifyListeners();
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!items.containsKey(productId)) {
      return;
    }
    if (items[productId].quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity - 1,
            price: existingCartItem.price),
      );
      print("decremented");
    } else {
      _items.remove(productId);
      print("Rmoved");
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
