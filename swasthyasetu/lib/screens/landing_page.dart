import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('SwasthyaSetu')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(160, 44),
                  ),
                  child: const Text("Sign In"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(160, 44),
                  ),
                  child: const Text("Sign Up"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
