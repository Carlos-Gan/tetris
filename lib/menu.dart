import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/logo.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    Text(
                      'Error cargando logo: $error',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 50),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Iniciar',
                style: TextStyle(color: Colors.white,
                fontFamily: 'Bitcount',
                fontSize: 24),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/game');
              },
            ),
          ],
        ),
      ),
    );
  }
}
