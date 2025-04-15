import 'package:brasil_cripto/common/components/custom_bottom_navigator.dart';
import 'package:brasil_cripto/core/routes/app_routes.dart';
import 'package:brasil_cripto/features/crypto_favorites/screen/crypto_favorites_screen.dart';
import 'package:brasil_cripto/features/crypto_list/screen/crypto_list_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        resizeToAvoidBottomInset: false,
        body: CustomBottomNavigationBar(
          screens: [CryptoListScreen(), CryptoFavoriteScreen()],
        ),
      ),
      onGenerateRoute: generateRoute,
    );
  }
}
