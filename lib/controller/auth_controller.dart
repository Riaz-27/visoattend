import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cloud_firestore_controller.dart';

class AuthController extends GetxController {
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set isLoading(value) => _isLoading.value = value;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  String tempPassword = '';

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading(true);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Something Went Wrong',
        e.toString(),
        colorText: Colors.red,
        animationDuration: const Duration(milliseconds: 200),
      );
    }
    _isLoading(false);
  }

  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading(true);
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading(false);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Something Went Wrong',
        e.toString(),
        colorText: Colors.red,
        animationDuration: const Duration(milliseconds: 200),
      );
    }
    _isLoading(false);
    return null;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String?> matchOldPassword(String oldPassword) async {
    final email = Get.find<CloudFirestoreController>().currentUser.email;
    final cred =
        EmailAuthProvider.credential(email: email, password: oldPassword);

    try {
      await currentUser!.reauthenticateWithCredential(cred);
    } catch (_){
      return 'Invalid password';
    }
    return null;
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      await
        currentUser!.updatePassword(newPassword);
    } catch (_) {
      return false;
    }
    return true;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
