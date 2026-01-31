import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallRequestsPage extends StatelessWidget {
  const CallRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('symptoms_reports')
            .where('hasAlert', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No emergency call requests"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;

              final String patientName =
                  data['patientName'] ?? "Unknown";
              final String? patientPhone =
                  data['patientPhone'];
              final String source =
                  data['updatedBy'] ?? "patient";

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  title: Text(
                    patientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    patientPhone != null && patientPhone.isNotEmpty
                        ? "Phone: $patientPhone"
                        : "Phone: Not available",
                  ),
                  trailing: Text(
                    source == "gov_worker"
                        ? "Via Gov Worker"
                        : "Direct",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: source == "gov_worker"
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
