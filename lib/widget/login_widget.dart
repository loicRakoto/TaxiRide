import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_ride/utils/app_constant.dart';
import 'package:taxi_ride/views/otp_verfication_screen.dart';
import 'package:taxi_ride/widget/text_widget.dart';

Widget loginWidget(CountryCode countryCodes, Function onCountryChange , Function onSubmit){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
      child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textWidget(text: AppConstant.bonjourRavis, fontWeight: FontWeight.w400),
            const SizedBox(height: 20,),
            textWidget(text: AppConstant.pretPartir, fontSize: 20 , fontWeight: FontWeight.bold),
            const SizedBox(height: 30,),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: ()=> onCountryChange(),
                        child: Row(
                          children: [
                            const SizedBox(width: 5,),
                            Expanded(
                                child: Container(
                                   child: countryCodes.flagImage(),
                                )
                            ),
                            const SizedBox(width: 5,),
                            textWidget(text: countryCodes.dialCode,fontSize: 12,fontWeight: FontWeight.bold),
                            const SizedBox(width: 5,),
                            const Icon(Icons.keyboard_arrow_down)
                        
                          ],
                        ),
                      ),
                  ),
                  Container(
                    width: 1,
                    height: 55,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onSubmitted: (value){
                        onSubmit(value);
                      },
                      decoration: InputDecoration(
                        hintStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal),
                        hintText: AppConstant.enterMobileNumber,
                        border: InputBorder.none
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: RichText(
                  textAlign: TextAlign.center,
                  text:
              TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 12),
                children: [
                  const TextSpan(text: "${AppConstant.enCreantCompte} "),
                  TextSpan(text: AppConstant.conditionUtilisation, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const TextSpan(text: " et nos "),
                  TextSpan(text: AppConstant.politiqueConfidentialite, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ]
              )),
            )

          ],
    )
  );
}