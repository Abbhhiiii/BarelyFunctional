import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'patient_dashboard.dart';

class PatientRegisterPage extends StatefulWidget {
  const PatientRegisterPage({super.key});

  @override
  State<PatientRegisterPage> createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String gender = 'Male';

  bool diabetes = false;
  bool bp = false;
  bool asthma = false;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field("Full Name", nameController),
                  _field("Age", ageController, keyboard: TextInputType.number),
                  _genderSelector(),
                  _field(
                    "Phone Number",
                    phoneController,
                    keyboard: TextInputType.phone,
                  ),
                  _field("Address", addressController),

                  const SizedBox(height: 16),
                  const Text(
                    "Medical History",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  _medicalCheckbox("Diabetes", diabetes, (v) => diabetes = v),
                  _medicalCheckbox("Blood Pressure", bp, (v) => bp = v),
                  _medicalCheckbox("Asthma", asthma, (v) => asthma = v),

                  const Divider(height: 40),

                  _field(
                    "Email",
                    emailController,
                    keyboard: TextInputType.emailAddress,
                  ),
                  _field("Password", passwordController, isPassword: true),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Register"),
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

  Widget _field(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget _genderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: gender,
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
          DropdownMenuItem(value: 'Other', child: Text('Other')),
        ],
        onChanged: (v) => setState(() => gender = v!),
        decoration: const InputDecoration(labelText: "Gender"),
      ),
    );
  }

  Widget _medicalCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: (v) => setState(() => onChanged(v!)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await AuthService().registerPatient(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        age: ageController.text.trim(),
        gender: gender,
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        medicalHistory: {'diabetes': diabetes, 'bp': bp, 'asthma': asthma},
        emergencyContact: {}, // add later
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PatientDashboard()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }
}
