import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';

import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/product_grid.dart';

import 'cart_screen.dart';

enum FilterOption { Favorite, All }

class ProductOverviewScreen extends StatefulWidget {
  static const String routeName = "/product-overview";
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isLoading = false;
  bool _showOnlyFavorite = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    context
        .read<Products>()
        .fetchAndSetProducts()
        .then(
          (value) => setState(
            () {
              _isLoading = false;
            },
          ),
        )
        .catchError(
          (_) => setState(
            () {
              _isLoading = false;
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shop"),
        actions: [
          PopupMenuButton<FilterOption>(
            itemBuilder: (ctx) {
              return [
                PopupMenuItem(
                  child: Text("Only favorite"),
                  value: FilterOption.Favorite,
                ),
                PopupMenuItem(
                  child: Text("Show All"),
                  value: FilterOption.All,
                ),
              ];
            },
            onSelected: (FilterOption selectedVal) {
              if (selectedVal == FilterOption.Favorite) {
                setState(() {
                  _showOnlyFavorite = true;
                });
              } else {
                setState(() {
                  _showOnlyFavorite = false;
                });
              }
            },
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
            builder: (ctx, cartProvider, child) {
              return Badge(
                value: cartProvider.itemCount.toString(),
                child: child,
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorite),
    );
  }
}
