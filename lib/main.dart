import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/product_details_screen.dart';

import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/user_products_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/product_overview_screen.dart';

import 'providers/auth.dart';
import 'providers/cart.dart';
import 'providers/order.dart';
import 'providers/products.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>.value(value: Auth()),
        ChangeNotifierProvider<Cart>.value(value: Cart()),
        ChangeNotifierProvider<Order>.value(value: Order()),
        ChangeNotifierProvider<Products>.value(value: Products()),
      ],
      builder: (ctx, child) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: "Lato",
        ),
        debugShowCheckedModeBanner: false,
        home: ctx.watch<Auth>().isAuth
            ? ProductOverviewScreen()
            : FutureBuilder(
                future: ctx.read<Auth>().tryAutoLogin(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: SplashScreen());
                  }
                  return AuthScreen();
                }),
        routes: {
          AuthScreen.routeName: (ctx) => AuthScreen(),
          CartScreen.routeName: (ctx) => OrdersScreen(),
          SplashScreen.routeName: (ctx) => SplashScreen(),
          EditProductScreen.routeName: (ctx) => EditProductScreen(),
          UserProductScreen.routeName: (ctx) => UserProductScreen(),
          ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
          ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
        },
      ),
    );
  }
}
