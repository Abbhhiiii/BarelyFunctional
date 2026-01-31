import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); // ✅ ADDED

  String selectedSex = "Male";
  bool isLoading = false;

  Future<void> addPatient() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Gov worker not logged in");
      }

      await FirebaseFirestore.instance.collection('patients').add({
        "name": nameController.text.trim(),
        "age": int.parse(ageController.text.trim()),
        "sex": selectedSex,
        "phone": phoneController.text.trim(), // ✅ STORED
        "addedBy": user.uid,
        "addedByEmail": user.email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient added successfully")),
      );

      nameController.clear();
      ageController.clear();
      phoneController.clear();
      setState(() => selectedSex = "Male");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Patient Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 👤 NAME
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Patient Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? "Please enter patient name"
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // 🎂 AGE
                  TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Please enter age";
                      }
                      if (int.tryParse(v) == null) {
                        return "Age must be a number";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // 📞 PHONE NUMBER (IMPORTANT)
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return "Please enter phone number";
                      }
                      if (v.trim().length < 10) {
                        return "Enter a valid phone number";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // 🚻 SEX
                  DropdownButtonFormField<String>(
                    value: selectedSex,
                    decoration: const InputDecoration(
                      labelText: "Sex",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                      DropdownMenuItem(
                        value: "Third Gender",
                        child: Text("Third Gender"),
                      ),
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
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Add Patient"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
