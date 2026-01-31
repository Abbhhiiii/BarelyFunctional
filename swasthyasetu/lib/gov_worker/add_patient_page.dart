import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String selectedSex = "Male";
  bool isLoading = false;

  Future<void> addPatient() async {
    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Gov worker not logged in");
      }

      if (nameController.text.trim().isEmpty ||
          ageController.text.trim().isEmpty) {
        throw Exception("Please fill all fields");
      }

      await FirebaseFirestore.instance.collection('patients').add({
        "name": nameController.text.trim(),
        "age": int.parse(ageController.text.trim()),
        "sex": selectedSex,
        "addedBy": user.uid,
        "addedByEmail": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient added successfully")),
      );

      nameController.clear();
      ageController.clear();
      setState(() => selectedSex = "Male");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Patient Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Patient Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedSex,
              decoration: const InputDecoration(
                labelText: "Sex",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Third Gender", child: Text("Third Gender")),
              ],
              onChanged: (value) {
                setState(() => selectedSex = value!);
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : addPatient,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Patient"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
