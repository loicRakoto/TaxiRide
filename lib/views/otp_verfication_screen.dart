
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:taxi_ride/controller/auth_controller.dart';
import 'package:taxi_ride/utils/app_color.dart';
import 'package:taxi_ride/widget/intro_widget.dart';
import 'package:taxi_ride/widget/otp_verification_widget.dart';


class OtpVerficationScreen extends StatefulWidget {

  String phoneNumber;

  OtpVerficationScreen(this.phoneNumber,);

  @override
  State<OtpVerficationScreen> createState() => _OtpVerficationScreenState();
}

class _OtpVerficationScreenState extends State<OtpVerficationScreen> {
  
  AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController.phoneAuth(widget.phoneNumber);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                introWidget(),
                Positioned(
                  top: 40,
                  left: 25,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: InkWell(
                        onTap: (){
                          Get.back();
                        },
                        child: const Icon(Icons.arrow_back,color: AppColor.orangeColor)
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 50,
            ),
        
            otpVerificationWidget()
          ],
        ),
      ),
    );
  }
}
