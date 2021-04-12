import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

import '../providers/order.dart' show Orders;

class OrdersScreen extends StatelessWidget {
  static const String routeName = "/orders";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your order")),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: context.read<Orders>().fetchAndSetProducts,
        child: FutureBuilder(
          future: context.read<Orders>().fetchAndSetProducts(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator.adaptive());
            } else {
              if (snapshot.error != null) {
                return Center(child: Text("An error occured!"));
              }
              return Consumer<Orders>(
                builder: (ctx, order, child) => ListView.builder(
                  itemBuilder: (ctx, index) => OrderItem(order.orders[index]),
                  itemCount: order.orders.length,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
