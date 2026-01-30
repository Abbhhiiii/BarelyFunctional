import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedRole = 'Government Worker';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
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
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Select Profile Type",
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Government Worker',
                      child: Text('Government Worker'),
                    ),
                    DropdownMenuItem(value: 'Doctor', child: Text('Doctor')),
                    DropdownMenuItem(value: 'User', child: Text('User')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    debugPrint("Selected role: $selectedRole");
                    // later: route to dashboards
                  },
                  child: const Text("Continue"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
