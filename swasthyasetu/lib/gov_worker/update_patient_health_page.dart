import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdatePatientHealthPage extends StatefulWidget {
  final String patientId; // ✅ IMPORTANT
  final String patientName;

  const UpdatePatientHealthPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<UpdatePatientHealthPage> createState() =>
      _UpdatePatientHealthPageState();
}

class _UpdatePatientHealthPageState extends State<UpdatePatientHealthPage> {
  double fever = 0;
  double cold = 0;
  double stomachPain = 0;
  double headache = 0;
  double nausea = 0;

  bool sosTriggered = false;
  bool isSaving = false;

  String? patientPhone; // ✅ will be fetched
  final TextEditingController prescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatientPhone();
  }

  // -------------------- FETCH PATIENT PHONE --------------------

  Future<void> fetchPatientPhone() async {
    // Try patients collection first (manual entries)
    final doc = await FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .get();

    if (doc.exists) {
      setState(() {
        final data = doc.data();
        patientPhone = data?['phone'];
        final pres = data?['lastPrescription']?.toString();
        prescriptionController.text = pres ?? '';
      });
      return;
    }

    // Fallback: try users collection
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .get();

    if (userDoc.exists) {
      setState(() {
        final data = userDoc.data();
        patientPhone = data?['phone'];
        final pres = data?['lastPrescription']?.toString();
        prescriptionController.text = pres ?? '';
      });
    }
  }

  @override
  void dispose() {
    prescriptionController.dispose();
    super.dispose();
  }

  // -------------------- UI HELPERS --------------------

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
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: Text(value.toInt().toString()),
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
    );
  }

  // -------------------- FIRESTORE LOGIC --------------------

  /// 🔴 EMERGENCY SOS (IMMEDIATE DB UPDATE)
  Future<void> triggerSOS() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
      fever = cold = stomachPain = headache = nausea = 10;
      sosTriggered = true;
    });

    await FirebaseFirestore.instance.collection('symptoms_reports').add({
      "patientId": widget.patientId,
      "patientName": widget.patientName,
      "patientPhone": patientPhone, // ✅ FIX
      "fever": 10,
      "cold": 10,
      "stomachPain": 10,
      "headache": 10,
      "nausea": 10,
      "hasAlert": true,
      "sosTriggered": true,
      "medicinePrescription": null,
      "updatedBy": "gov_worker",
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🚨 Emergency SOS sent successfully")),
    );
  }

  /// 🟢 NORMAL UPDATE
  Future<void> submitHealthUpdate() async {
    if (isSaving) return;

    final bool hasAlert =
        fever >= 7 ||
        cold >= 7 ||
        stomachPain >= 7 ||
        headache >= 7 ||
        nausea >= 7;

    setState(() => isSaving = true);

    await FirebaseFirestore.instance.collection('symptoms_reports').add({
      "patientId": widget.patientId,
      "patientName": widget.patientName,
      "patientPhone": patientPhone, // ✅ FIX
      "fever": fever.toInt(),
      "cold": cold.toInt(),
      "stomachPain": stomachPain.toInt(),
      "headache": headache.toInt(),
      "nausea": nausea.toInt(),
      "hasAlert": hasAlert,
      "sosTriggered": false,
      "medicinePrescription": null,
      "updatedBy": "gov_worker",
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() => isSaving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Health update submitted")));

    Navigator.pop(context);
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Health – ${widget.patientName}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

            const SizedBox(height: 16),

            TextField(
              controller: prescriptionController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Prescription',
                hintText: prescriptionController.text.isEmpty
                    ? 'Not prescribed yet'
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: triggerSOS,
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("EMERGENCY SOS"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: submitHealthUpdate,
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
