import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String _formatDate(Timestamp? ts) {
  if (ts == null) return 'No date';
  final d = ts.toDate().toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

/* ==========================================================
   SYMPTOMS FORM
========================================================== */

class SymptomsForm extends StatefulWidget {
  @override
  State<SymptomsForm> createState() => _SymptomsFormState();
}

class _SymptomsFormState extends State<SymptomsForm> {
  double fever = 0;
  double cold = 0;
  double stomachPain = 0;
  double headache = 0;
  double nausea = 0;

  final TextEditingController otherController = TextEditingController();
  bool isLoading = false;

  Color getSliderColor(double value) {
    if (value <= 3) return Colors.green;
    if (value <= 6) return Colors.orange;
    return Colors.red;
  }

  Widget symptomSlider(
    String label,
    IconData icon,
    double value,
    Function(double) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(label),
                const Spacer(),
                Text(value.toInt().toString()),
              ],
            ),
            Slider(
              value: value,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: getSliderColor(value),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitSymptoms() async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String patientName = userDoc.data()?['name'] ?? "Unknown";
      final String? patientPhone = userDoc.data()?['phone'];

      bool hasAlert =
          fever >= 7 ||
          cold >= 7 ||
          stomachPain >= 7 ||
          headache >= 7 ||
          nausea >= 7;

      await FirebaseFirestore.instance.collection('symptoms_reports').add({
        "patientId": user.uid,
        "patientName": patientName,
        "patientPhone": patientPhone, // ✅ FIX
        "fever": fever.toInt(),
        "cold": cold.toInt(),
        "stomachPain": stomachPain.toInt(),
        "headache": headache.toInt(),
        "nausea": nausea.toInt(),
        "otherSymptoms": otherController.text.trim(),
        "hasAlert": hasAlert,
        "sosTriggered": hasAlert,
        "updatedBy": "patient",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasAlert
                ? "⚠️ High severity detected. SOS triggered!"
                : "Symptoms submitted successfully",
          ),
        ),
      );

      setState(() {
        fever = cold = stomachPain = headache = nausea = 0;
        otherController.clear();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Report Your Symptoms",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          symptomSlider(
            "Fever",
            Icons.thermostat,
            fever,
            (v) => setState(() => fever = v),
          ),
          symptomSlider(
            "Cold",
            Icons.ac_unit,
            cold,
            (v) => setState(() => cold = v),
          ),
          symptomSlider(
            "Stomach Pain",
            Icons.sick,
            stomachPain,
            (v) => setState(() => stomachPain = v),
          ),
          symptomSlider(
            "Headache",
            Icons.psychology,
            headache,
            (v) => setState(() => headache = v),
          ),
          symptomSlider(
            "Nausea",
            Icons.sentiment_dissatisfied,
            nausea,
            (v) => setState(() => nausea = v),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: otherController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Other symptoms",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : submitSymptoms,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}

/* ==========================================================
   MANUAL SOS SCREEN
========================================================== */

class ManualSOSScreen extends StatefulWidget {
  const ManualSOSScreen({super.key});

  @override
  State<ManualSOSScreen> createState() => _ManualSOSScreenState();
}

class _ManualSOSScreenState extends State<ManualSOSScreen>
    with SingleTickerProviderStateMixin {
  bool sosActive = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> triggerSOS() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final String patientName = userDoc.data()?['name'] ?? "Unknown";
    final String? patientPhone = userDoc.data()?['phone'];

    await FirebaseFirestore.instance.collection('symptoms_reports').add({
      "patientId": user.uid,
      "patientName": patientName,
      "patientPhone": patientPhone, // ✅ FIX
      "fever": 10,
      "cold": 10,
      "stomachPain": 10,
      "headache": 10,
      "nausea": 10,
      "otherSymptoms": "Manual emergency SOS triggered",
      "hasAlert": true,
      "sosTriggered": true,
      "updatedBy": "patient",
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() {
      sosActive = true;
      _controller.repeat(reverse: true);
    });
  }

  void confirmSOS() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm SOS"),
        content: const Text(
          "This will trigger an emergency alert.\nDo you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              triggerSOS();
            },
            child: const Text("YES, TRIGGER SOS"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: sosActive
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.3).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    size: 110,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "SOS ACTIVE",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            )
          : ElevatedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text("EMERGENCY SOS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              onPressed: confirmSOS,
            ),
    );
  }
}

/* ==========================================================
   DASHBOARD
========================================================== */

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;
  String patientName = "";

  @override
  void initState() {
    super.initState();
    fetchPatientName();
  }

  Future<void> fetchPatientName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    setState(() => patientName = doc.data()?['name'] ?? "Patient");
  }

  Widget homeView() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            'assets/images/patient.png',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Text(
            "Hi, $patientName 👋",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Last prescription (from users or patients collection)
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              if (!snap.hasData || !snap.data!.exists)
                return const SizedBox.shrink();
              final data = snap.data!.data() as Map<String, dynamic>?;
              final lastPres = data?['lastPrescription'] as String?;
              if (lastPres == null || lastPres.isEmpty)
                return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Prescription',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(lastPres),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Appointments list for this patient
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: StreamBuilder<QuerySnapshot>(
              // Avoid requiring a Firestore composite index by removing server-side ordering
              // and sorting client-side instead.
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('patientId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Failed to load appointments: ${snap.error}'),
                  );
                }
                final docsRaw = snap.data?.docs ?? [];
                // sort client-side by scheduledAt (safely handling missing timestamps)
                final docs = List.of(docsRaw);
                docs.sort((a, b) {
                  final aTs =
                      (a.data() as Map<String, dynamic>?)?['scheduledAt'];
                  final bTs =
                      (b.data() as Map<String, dynamic>?)?['scheduledAt'];
                  final aDate = aTs is Timestamp
                      ? aTs.toDate()
                      : DateTime.fromMillisecondsSinceEpoch(0);
                  final bDate = bTs is Timestamp
                      ? bTs.toDate()
                      : DateTime.fromMillisecondsSinceEpoch(0);
                  return aDate.compareTo(bDate);
                });
                if (docs.isEmpty)
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No appointments scheduled'),
                  );

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final data = d.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'scheduled';
                    final scheduled = data['scheduledAt'] as Timestamp?;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(data['doctorName'] ?? 'Appointment'),
                        subtitle: Text(
                          '${_formatDate(scheduled)}\nStatus: $status' +
                              (data['prescription'] != null &&
                                      (data['prescription'] as String)
                                          .isNotEmpty
                                  ? '\nPrescription: ${data['prescription']}'
                                  : ''),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return homeView();
      case 1:
        return SymptomsForm();
      case 2:
        return const ManualSOSScreen();
      case 3:
        return profileView();
      default:
        return homeView();
    }
  }

  Widget profileView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.purple.shade50],
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
                  backgroundColor: Colors.purple.shade200,
                  child: Text(
                    (patientName.isNotEmpty
                            ? patientName
                            : FirebaseAuth.instance.currentUser!.email!)
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
                        patientName.isNotEmpty ? patientName : 'Patient',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        FirebaseAuth.instance.currentUser!.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: const Text('Patient'),
                        backgroundColor: Colors.purple.shade100,
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
                          'Upcoming',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('3'),
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
                          'Past',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('7'),
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
            onPressed: () async => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getCurrentView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.healing), label: "Symptoms"),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: "SOS"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
