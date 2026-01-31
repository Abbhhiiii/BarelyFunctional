import 'package:flutter/material.dart';
import 'package:swasthyasetu/gov_worker/gov_worker_dashboard.dart';
import '../services/auth_service.dart';


class GovWorkerRegisterPage extends StatefulWidget {
  const GovWorkerRegisterPage({super.key});

  @override
  State<GovWorkerRegisterPage> createState() => _GovWorkerRegisterPageState();
}

class _GovWorkerRegisterPageState extends State<GovWorkerRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final workLocationController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Government Worker Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _field("Full Name", nameController),
                  _field("Age", ageController,
                      keyboardType: TextInputType.number),
                  _field("Work Location / Address", workLocationController),

                  const Divider(height: 40),

                  _field("Email", emailController,
                      keyboardType: TextInputType.emailAddress),
                  _field("Password", passwordController, isPassword: true),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (v) =>
            v == null || v.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await AuthService().registerGovWorker(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        age: ageController.text.trim(),
        workLocation: workLocationController.text.trim(),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GovWorkerDashboard()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }
}
