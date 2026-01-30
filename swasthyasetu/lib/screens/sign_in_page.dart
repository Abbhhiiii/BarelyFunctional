import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Email or Phone Number",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    // auth later
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
