
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_ride/utils/app_constant.dart';
import 'package:taxi_ride/widget/text_widget.dart';
import 'package:pinput/pinput.dart';

Widget otpVerificationWidget(){
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textWidget(text: AppConstant.verificationTelephone, fontWeight: FontWeight.w400),
          const SizedBox(height: 20,),
          textWidget(text: AppConstant.entrerOtp, fontSize: 20 , fontWeight: FontWeight.bold),
          const SizedBox(height: 30,),
          Container(
            

            child: Center(
              child: Pinput(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF272928)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

              ),
            ),
          ),
          const SizedBox(height: 50,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: RichText(
                textAlign: TextAlign.start,
                text:
                TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    children: [
                      const TextSpan(text: "${AppConstant.renvoyerCode} "),
                      TextSpan(text: "10 seconds", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),

                 ]
                )),
          )

        ],
      )
  );
}