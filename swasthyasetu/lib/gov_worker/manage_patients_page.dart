import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_patient_health_page.dart';

class ManagePatientsPage extends StatefulWidget {
  const ManagePatientsPage({super.key});

  @override
  State<ManagePatientsPage> createState() => _ManagePatientsPageState();
}

class _ManagePatientsPageState extends State<ManagePatientsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> allPatients = [];

  @override
  void initState() {
    super.initState();
    fetchAllPatients();
  }

  Future<void> fetchAllPatients() async {
    List<Map<String, dynamic>> temp = [];

    // 1️⃣ Fetch patients from `users` (role = patient)
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .get();

    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      temp.add({
        "name": data['name'] ?? 'Unknown',
        "age": data['age'] ?? '-',
        "gender": data['gender'] ?? 'Unknown',
        "source": "Registered User",
        "id": doc.id,
      });
    }

    // 2️⃣ Fetch patients from `patients` (manual entries)
    final patientsSnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .get();

    for (var doc in patientsSnapshot.docs) {
      final data = doc.data();
      temp.add({
        "name": data['name'] ?? 'Unknown',
        "age": data['age'] ?? '-',
        "gender": data['sex'] ?? 'Unknown',
        "source": "Added by Gov Worker",
        "id": doc.id,
      });
    }

    setState(() {
      allPatients = temp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Patients")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allPatients.isEmpty
          ? const Center(child: Text("No patients found"))
          : ListView.builder(
              itemCount: allPatients.length,
              itemBuilder: (context, index) {
                final patient = allPatients[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(patient['name']),
                    subtitle: Text(
                      "Age: ${patient['age']} | Gender: ${patient['gender']}",
                    ),
                    trailing: patient['source'] == "Added by Gov Worker"
                        ? ElevatedButton(
                            child: const Text("Update Health"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UpdatePatientHealthPage(
                                    patientName: patient['name'],
                                    patientId: patient['id'],
                                  ),
                                ),
                              );
                            },
                          )
                        : const Text(
                            "Self Reporting",
                            style: TextStyle(color: Colors.grey),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
