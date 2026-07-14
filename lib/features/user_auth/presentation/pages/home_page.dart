import 'package:flutter/material.dart';
import 'package:motor_show/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:motor_show/features/user_auth/presentation/pages/profile_page.dart';
import 'package:motor_show/features/user_auth/presentation/pages/purchase_page.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuthService _authService;

  HomePage({super.key, FirebaseAuthService? authService})
      : _authService = authService ?? const FirebaseAuthService();

  final List<Map<String, dynamic>> cars = [
    {
      "name": "BMW M4 2014",
      "description": "F82 • 3.0 DCT (431 к.с.) • Base",
      "image": "assets/car1.jpg",
      "price": "Price: \$123,000",
    },
    {
      "name": "Volkswagen Golf GTI 2014",
      "description": "VII Gen • 2.0 (256 к.с.)",
      "image": "assets/car2.jpg",
      "price": "Price: \$19,000",
    },
    {
      "name": "Ford Focus 2015",
      "description": "III покоління (FL) • 2.0 TDCi Powershift (160 к.с.)",
      "image": "assets/car3.jpg",
      "price": "Price: \$8,500",
    },
    {
      "name": "Audi A6 2011",
      "description": "3.0 TFSI S-tronic (300 к.с.)",
      "image": "assets/car4.jpg",
      "price": "Price: \$18,900",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const ProfilePage(),
                ),
              );
            },
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/profile_picture.jpg'),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white70],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/company_logo.png',
                height: 70,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  return CarItem(
                    name: cars[index]["name"],
                    description: cars[index]["description"],
                    image: cars[index]["image"],
                    price: cars[index]["price"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthServiceException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class CarItem extends StatelessWidget {
  final String? name;
  final String? description;
  final String? image;
  final String? price;

  const CarItem({
    super.key,
    this.name,
    this.description,
    this.image,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                image!,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(description!),
                  const SizedBox(height: 5),
                  Text(
                    price!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: PurchasePage(
                      carName: name!,
                      carDescription: description!,
                      carImage: image!,
                      carPrice: price!,
                    ),
                  ),
                );
              },
              child: const Text("Buy"),
            ),
          ],
        ),
      ),
    );
  }
}
