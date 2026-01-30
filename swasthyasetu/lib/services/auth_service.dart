import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
