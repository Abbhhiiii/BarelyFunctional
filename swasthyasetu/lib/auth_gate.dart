import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/patient_dashboard.dart';
import 'screens/gov_worker_dashboard.dart';
import 'screens/landing_page.dart';
import 'screens/doctor_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!snapshot.hasData) {
          return const LandingPage();
        }

        // ✅ Logged in → check role
        final user = snapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("User profile not found")),
              );
            }

            final role =
                (roleSnapshot.data!.data() as Map<String, dynamic>)['role'];

            // 🔁 Role-based redirect
            if (role == 'doctor') {
              return const DoctorDashboard();
            }
            if (role == 'patient') {
              return const PatientDashboard();
            }
            if (role == 'gov_worker') {
              return const GovWorkerDashboard();
            }

            // Fallback
            return const LandingPage();
          },
        );
      },
    );
  }
}
