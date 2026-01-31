import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String _formatDate(Timestamp? ts) {
  if (ts == null) return 'No date';
  final d = ts.toDate().toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class ManageAppointmentsPage extends StatefulWidget {
  const ManageAppointmentsPage({super.key});

  @override
  State<ManageAppointmentsPage> createState() => _ManageAppointmentsPageState();
}

class _ManageAppointmentsPageState extends State<ManageAppointmentsPage> {
  final _appointmentsRef = FirebaseFirestore.instance.collection(
    'appointments',
  );

  Future<void> _updateAppointmentStatus(String docId, String status) async {
    await _appointmentsRef.doc(docId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _addPrescription(
    String appointmentId,
    Map<String, dynamic> appt,
    String prescription,
  ) async {
    // Update appointment with prescription and mark done
    await _appointmentsRef.doc(appointmentId).update({
      'prescription': prescription,
      'status': 'done',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final String patientId = appt['patientId'] ?? '';

    if (patientId.isEmpty) return;

    // Try update users/{patientId} first
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(patientId)
        .get();
    final dataToSave = {
      'lastPrescription': prescription,
      'lastPrescriptionAt': FieldValue.serverTimestamp(),
    };

    if (userDoc.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .update(dataToSave);
    } else {
      // fallback to patients collection
      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .get();
      if (patientDoc.exists) {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .update(dataToSave);
      }
    }
  }

  void _showPrescriptionDialog(
    BuildContext context,
    String appointmentId,
    Map<String, dynamic> appt,
  ) {
    final TextEditingController c = TextEditingController(
      text: appt['prescription'] ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Prescription'),
        content: TextField(
          controller: c,
          maxLines: 6,
          decoration: const InputDecoration(hintText: 'Prescription details'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = c.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context);
              await _addPrescription(appointmentId, appt, text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prescription saved')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Appointments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _appointmentsRef
            .orderBy('scheduledAt', descending: false)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No appointments'));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'scheduled';
              final scheduled = data['scheduledAt'] as Timestamp?;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['patientName'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatDate(scheduled),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Status: $status',
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            if (data['prescription'] != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Prescription: ${data['prescription']}',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status == 'scheduled')
                              ElevatedButton(
                                onPressed: () async {
                                  await _updateAppointmentStatus(
                                    d.id,
                                    'missed',
                                  );
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Marked missed'),
                                      ),
                                    );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  minimumSize: const Size.fromHeight(36),
                                ),
                                child: const Text('Missed'),
                              ),
                            if (status == 'scheduled')
                              const SizedBox(height: 6),
                            if (status == 'scheduled')
                              ElevatedButton(
                                onPressed: () => _showPrescriptionDialog(
                                  context,
                                  d.id,
                                  data,
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(36),
                                ),
                                child: const Text('Add'),
                              ),
                            if (status == 'scheduled')
                              const SizedBox(height: 6),
                            if (status == 'scheduled')
                              ElevatedButton(
                                onPressed: () async {
                                  await _updateAppointmentStatus(d.id, 'done');
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Marked done'),
                                      ),
                                    );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size.fromHeight(36),
                                ),
                                child: const Text('Done'),
                              ),
                          ],
                        ),
                      ),
                    ],
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
