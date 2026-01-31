import 'package:flutter/material.dart';
import 'gov_worker_home.dart';
import 'gov_worker_profile.dart';
import 'manage_patients_page.dart';


class GovWorkerDashboard extends StatefulWidget {
  const GovWorkerDashboard({super.key});

  @override
  State<GovWorkerDashboard> createState() => _GovWorkerDashboardState();
}

class _GovWorkerDashboardState extends State<GovWorkerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
  GovWorkerHome(),
  ManagePatientsPage(),
  GovWorkerProfile(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Manage Patients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
