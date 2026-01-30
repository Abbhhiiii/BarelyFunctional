import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: Stack(
        children: [
          /// 🔝 HEADER IMAGE
          Container(
            height: size.height * 0.42,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/header.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Move the centered block 30% down, then center within remaining space
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: size.height * 0.30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// 🐰 BUNNY + LOGO
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/bunny.png", height: 80),
                            const SizedBox(width: 12),
                            Text(
                              "SwasthyaSetu",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "Healthcare that reaches everyone",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// 📦 ACTION CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignInPage(),
                                ),
                              );
                            },
                            child: const Text("Sign In"),
                          ),

                          const SizedBox(height: 16),

                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpPage(),
                                ),
                              );
                            },
                            child: const Text("Sign Up"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
