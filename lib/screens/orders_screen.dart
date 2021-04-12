import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = "/orders";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(),
      body: Center(child: Text("Orders")),
    );
  }
}
