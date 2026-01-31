import 'package:flutter/material.dart';

class ManageAppointmentsPage extends StatelessWidget {
  const ManageAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Appointments")),
      body: const Center(
        child: Text(
          "Appointments management coming soon",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
