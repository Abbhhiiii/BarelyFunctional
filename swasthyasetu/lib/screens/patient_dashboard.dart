import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      String label, IconData icon, double value, Function(double) onChanged) {
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

      bool hasAlert = fever >= 7 ||
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
          const Text("Report Your Symptoms",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          symptomSlider("Fever", Icons.thermostat, fever,
              (v) => setState(() => fever = v)),
          symptomSlider("Cold", Icons.ac_unit, cold,
              (v) => setState(() => cold = v)),
          symptomSlider("Stomach Pain", Icons.sick, stomachPain,
              (v) => setState(() => stomachPain = v)),
          symptomSlider("Headache", Icons.psychology, headache,
              (v) => setState(() => headache = v)),
          symptomSlider("Nausea", Icons.sentiment_dissatisfied, nausea,
              (v) => setState(() => nausea = v)),

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
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
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
            "This will trigger an emergency alert.\nDo you want to continue?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
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
                        parent: _controller, curve: Curves.easeInOut),
                  ),
                  child: const Icon(Icons.notifications_active,
                      size: 110, color: Colors.red),
                ),
                const SizedBox(height: 20),
                const Text("SOS ACTIVE",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ],
            )
          : ElevatedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text("EMERGENCY SOS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() => patientName = doc.data()?['name'] ?? "Patient");
  }

  Widget homeView() {
    return Column(
      children: [
        Image.asset('assets/images/patient.png',
            height: 220, width: double.infinity, fit: BoxFit.cover),
        const SizedBox(height: 16),
        Text("Hi, $patientName 👋",
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold)),
      ],
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
          Text("Profile",
              style: Theme.of(context).textTheme.headlineSmall),
          Text("Name: $patientName"),
          Text("Email: ${FirebaseAuth.instance.currentUser!.email}"),
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
