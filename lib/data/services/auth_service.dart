import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> sendOtp(
    String phoneNumber, {
    int? resendToken,
  }) async {
    try {
      final Completer<Map<String, dynamic>> completer =
          Completer<Map<String, dynamic>>();
      String? verificationId;
      int? resendTokenValue;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,

        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.completeError(Exception('Auto-verification completed'));
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(e.message ?? 'OTP verification failed'),
            );
          }
        },

        codeSent: (String vId, int? token) {
          verificationId = vId;
          resendTokenValue = token;
          if (!completer.isCompleted) {
            completer.complete({'verificationId': vId, 'resendToken': token});
          }
        },

        codeAutoRetrievalTimeout: (String vId) {
          verificationId = vId;
          if (!completer.isCompleted && verificationId != null) {
            completer.complete({
              'verificationId': vId,
              'resendToken': resendTokenValue,
            });
          }
        },
      );

      return completer.future;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Invalid OTP');
    }
  }

  User? get currentUser => _auth.currentUser;
}
