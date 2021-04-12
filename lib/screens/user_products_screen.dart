import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

import '../providers/products.dart';

import 'edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const String routeName = "/user-product";

  Future<void> _refreshProducts(BuildContext context) async {
    await context.read<Products>().fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your products"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _refreshProducts(ctx),
                  child: Consumer<Products>(
                    builder: (ctx, productsProvider, child) => Padding(
                      padding: EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: productsProvider.items.length,
                        itemBuilder: (ctx, index) => Column(
                          children: [
                            UserProductItem(
                              productsProvider.items[index].id,
                              productsProvider.items[index].title,
                              productsProvider.items[index].imageUrl,
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
