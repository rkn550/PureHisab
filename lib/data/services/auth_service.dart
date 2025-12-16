import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// SEND / RESEND OTP
  Future<String> sendOtp(String phoneNumber) async {
    try {
      late String verificationId;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          throw Exception(e.message ?? 'OTP verification failed');
        },

        codeSent: (String vId, int? resendToken) {
          verificationId = vId;
        },

        codeAutoRetrievalTimeout: (String vId) {
          verificationId = vId;
        },
      );

      return verificationId;
    } catch (e) {
      rethrow;
    }
  }

  /// VERIFY OTP
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
