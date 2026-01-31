import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GovWorkerProfile extends StatelessWidget {
  const GovWorkerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.blue.shade200,
                  child: Text(
                    (user?.displayName ?? user?.email ?? 'G')
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Gov Worker',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: const Text('Government Worker'),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: const [
                        Text(
                          'Visited Patients',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('56'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: const [
                        Text(
                          'Communities',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('8'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
