import 'package:flutter/material.dart';

class PurchasePage extends StatelessWidget {
  final String carName;
  final String carDescription;
  final String carImage;
  final String carPrice;

  const PurchasePage({
    super.key,
    required this.carName,
    required this.carDescription,
    required this.carImage,
    required this.carPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase $carName"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white70],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  carImage,
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  carName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  carDescription,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  carPrice,
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Thank you for your order, we will send you the details to your email shortly",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Back to Home"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
