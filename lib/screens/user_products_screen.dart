import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class UserProductScreen extends StatelessWidget {
  static const String routeName = "/user-product";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(),
      body: Center(child: Text("User products")),
    );
  }
}
