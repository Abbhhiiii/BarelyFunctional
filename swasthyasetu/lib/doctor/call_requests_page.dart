import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallRequestsPage extends StatelessWidget {
  const CallRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Call Requests")),
      body: StreamBuilder<QuerySnapshot>(
        // includeMetadataChanges so we can observe cache/remote transitions
        stream: FirebaseFirestore.instance
            .collection('symptoms_reports')
            .where('hasAlert', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .snapshots(includeMetadataChanges: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Print debug info to console for diagnosis
          try {
            final metadata = snapshot.data?.metadata;
            print(
              'CallRequests snapshot: docs=${snapshot.data?.docs.length ?? 0} fromCache=${metadata?.isFromCache ?? false} pendingWrites=${metadata?.hasPendingWrites ?? false} error=${snapshot.error}',
            );
            if (snapshot.data != null) {
              final ids = snapshot.data!.docs.map((d) => d.id).toList();
              print('CallRequests docIds: $ids');
            }
          } catch (e) {
            print('CallRequests debug print failed: $e');
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Error loading call requests:\n${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('No emergency call requests (found: $count)'),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String patientId = data['patientId'] ?? '';
              final String source = data['updatedBy'] ?? 'patient';

              // If report already contains name/phone, use immediately.
              final String? reportedName =
                  (data['patientName'] as String?)?.isNotEmpty == true
                  ? data['patientName'] as String
                  : null;
              final String? reportedPhone =
                  (data['patientPhone'] as String?)?.isNotEmpty == true
                  ? data['patientPhone'] as String
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: FutureBuilder<Map<String, String?>>(
                  future: _resolvePatientInfo(
                    reportedName,
                    reportedPhone,
                    patientId,
                  ),
                  builder: (context, infoSnap) {
                    String displayName = 'Unknown';
                    String phoneText = 'Phone: Not available';

                    if (infoSnap.connectionState == ConnectionState.done &&
                        infoSnap.hasData) {
                      final info = infoSnap.data!;
                      displayName = info['name'] ?? 'Unknown';
                      final ph = info['phone'];
                      phoneText = (ph != null && ph.isNotEmpty)
                          ? 'Phone: $ph'
                          : 'Phone: Not available';
                    } else if (reportedName != null || reportedPhone != null) {
                      displayName = reportedName ?? 'Unknown';
                      phoneText =
                          (reportedPhone != null && reportedPhone.isNotEmpty)
                          ? 'Phone: $reportedPhone'
                          : 'Phone: Not available';
                    }

                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(
                        displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(phoneText),
                      trailing: Text(
                        source == 'gov_worker' ? 'Via Gov Worker' : 'Direct',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: source == 'gov_worker'
                              ? Colors.blue
                              : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Resolve patient name/phone using reported values or by looking up
  /// `users` and `patients` collections with `patientId`.
  Future<Map<String, String?>> _resolvePatientInfo(
    String? reportedName,
    String? reportedPhone,
    String patientId,
  ) async {
    if ((reportedName != null && reportedName.isNotEmpty) ||
        (reportedPhone != null && reportedPhone.isNotEmpty)) {
      return {"name": reportedName, "phone": reportedPhone};
    }

    if (patientId.isEmpty) return {"name": null, "phone": null};

    // Try users collection first
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(patientId)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data();
      return {
        "name": data?['name'] as String?,
        "phone": data?['phone'] as String?,
      };
    }

    // Fallback to patients collection
    final patientDoc = await FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .get();
    if (patientDoc.exists) {
      final data = patientDoc.data();
      return {
        "name": data?['name'] as String?,
        "phone": data?['phone'] as String?,
      };
    }

    return {"name": null, "phone": null};
  }
}
