import 'package:flutter/material.dart';
import 'call_requests_page.dart';
import 'book_appointment_page.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔝 Header image
          Image.asset(
            'assets/images/doctor.png',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 16),

          // 👋 Greeting
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Hi, Doctor 👋",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 24),

          // 📞 Call Requests
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CallRequestsPage()),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.call, size: 40),
                      SizedBox(width: 16),
                      Text(
                        "Call Requests",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 📅 Book Appointment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookAppointmentPage(),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, size: 40),
                      SizedBox(width: 16),
                      Text(
                        "Book Appointment",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
