import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:purehisab/data/model/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> createUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) return null;

      final userData = {
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isDeleted': false,
      };

      await _db.collection('users').doc(user.uid).set(userData);

      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('Failed to create user document in Firestore');
      }

      final userDocData = userDoc.data() as Map<String, dynamic>;
      return UserModel.fromMap(userDocData, user.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) throw Exception('User not found');

      final userData = await _db.collection('users').doc(user.uid).get();
      if (!userData.exists) {
        throw Exception('User data not found');
      }

      final userDoc = userData.data() as Map<String, dynamic>;
      final userModel = UserModel.fromMap(userDoc, userData.id);

      if (userModel.isDeleted) {
        throw Exception('User is deleted');
      }

      return userModel;
    } catch (e) {
      throw Exception('Failed to login user: $e');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      default:
        return 'Authentication failed';
    }
  }
}
