import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getCurrentUserRole() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  if (!doc.exists) {
    throw Exception("User profile not found");
  }

  return doc['role'];
}
Future<void> registerGovWorker({
  required String email,
  required String password,
  required String name,
  required String age,
  required String workLocation,
}) async {
  // 1️⃣ Create auth user
  UserCredential cred = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // 2️⃣ Save worker profile
  await _db.collection('users').doc(cred.user!.uid).set({
    'role': 'gov_worker',
    'email': email,
    'name': name,
    'age': age,
    'workLocation': workLocation,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<void> registerPatient({
  required String email,
  required String password,
  required String name,
  required String age,
  required String gender,
  required String phone,
  required String address,
  required Map<String, dynamic> medicalHistory,
  required Map<String, dynamic> emergencyContact,
}) async {
  // 1️⃣ Create auth user
  UserCredential cred = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // 2️⃣ Save patient profile
  await _db.collection('users').doc(cred.user!.uid).set({
    'role': 'patient',
    'email': email,
    'name': name,
    'age': age,
    'gender': gender,
    'phone': phone,
    'address': address,
    'medicalHistory': medicalHistory,
    'emergencyContact': emergencyContact,
    'createdAt': FieldValue.serverTimestamp(),
  });
}



  Future<void> registerDoctor({
  required String email,
  required String password,
  required String name,
  required String phone,
  required String doctorId,
  required String hospital,
}) async {
  // 1. Create auth user
  UserCredential cred = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // 2. Save doctor profile + role
  await _db.collection('users').doc(cred.user!.uid).set({
    'role': 'doctor',
    'email': email,
    'name': name,
    'phone': phone,
    'doctorId': doctorId,
    'hospital': hospital,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

  Future<void> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    // Create auth user
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save role in Firestore
    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}
