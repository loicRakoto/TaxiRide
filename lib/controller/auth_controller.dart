
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';



class AuthController extends GetxController{
  var  verId = "";
  int? resendTokenId;
  bool phoneAuthCheck = false;
  dynamic credentials;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  phoneAuth(String phone)async{
    debugPrint(phone);
    try {
      credentials= null;
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds:68),
        verificationCompleted: (PhoneAuthCredential credential) async{
          debugPrint(" Verification Completed");
          credentials = credential;
          debugPrint("le credentials est : $credentials");
          await _auth.signInWithCredential(credential);
        } ,
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            Get.snackbar("Erreur", "Le numéro de téléphone est invalide");
          } else {
            Get.snackbar("Erreur", "Une erreur est survenue : ${e.message}");
          }
          debugPrint("Erreur sur : ${e.message}");
        },
        forceResendingToken: resendTokenId,
        codeSent: (verificationId,resendToken){
          verId = verificationId;
          resendTokenId = resendToken;
          Get.snackbar("Code envoyé", "Vérifie ton téléphone pour le code OTP");
          debugPrint( " verID : $verId");
          debugPrint( " resendTokenId : $resendTokenId");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verId = verificationId;
        } ,
      );
    } catch (e) {
      debugPrint("Error sur $e");
    }

  }

  verifyOTP(String otpCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: otpCode,
      );

      _auth.signInWithCredential(credential);
 
      Get.snackbar("Succès", "Code OTP vérifié");
      debugPrint("Succès");
    } catch (e) {
      Get.snackbar("Erreur", "Code OTP incorrect");
      debugPrint("Error");
    }
  }

}