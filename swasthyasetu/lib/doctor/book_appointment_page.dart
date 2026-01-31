import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    setState(() => isLoading = true);

    final List<Map<String, dynamic>> temp = [];

    // Registered users with role == patient
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .get();

    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      temp.add({
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'phone': data['phone'] ?? '',
        'source': 'Registered User',
      });
    }

    // Manual patients added by gov workers
    final patientsSnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .get();

    for (var doc in patientsSnapshot.docs) {
      final data = doc.data();
      temp.add({
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'phone': data['phone'] ?? '',
        'source': 'Added by Gov Worker',
      });
    }

    setState(() {
      patients = temp;
      isLoading = false;
    });
  }

  Future<void> _pickDateTimeAndSchedule(Map<String, dynamic> patient) async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return;

    final DateTime scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    try {
      setState(() => isLoading = true);

      final currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': patient['id'],
        'patientName': patient['name'],
        'patientPhone': patient['phone'],
        'scheduledAt': Timestamp.fromDate(scheduled),
        'createdBy': currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'scheduled',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment scheduled for ${patient['name']} on ${scheduled.toLocal()}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
          ? const Center(child: Text('No patients available'))
          : ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final p = patients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(p['name'] ?? 'Unknown'),
                    subtitle: Text(
                      p['phone'] == null || (p['phone'] as String).isEmpty
                          ? 'Phone: Not available'
                          : 'Phone: ${p['phone']}',
                    ),
                    trailing: ElevatedButton(
                      child: const Text('Schedule'),
                      onPressed: () => _pickDateTimeAndSchedule(p),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
