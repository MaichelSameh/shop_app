import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class ProductOverviewScreen extends StatefulWidget {
  static const String routeName = "/product-overview";
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shop")),
      drawer: AppDrawer(),
      body: Center(child: Text("Text")),
    );
  }
}
