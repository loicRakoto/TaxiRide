import 'dart:math';

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi_ride/widget/intro_widget.dart';

import '../widget/login_widget.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final countryPicker = const  FlCountryCodePicker();
  CountryCode countryCodes =  const CountryCode(name: "Madagascar", code: "MG", dialCode: "+261");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: Get.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              introWidget(),
              const SizedBox(height: 50,),
              loginWidget(countryCodes,()async{
                final picked= await countryPicker.showPicker(context: context);
                // Null check
                if (picked!= null) {
                  setState(() {
                    countryCodes=picked;
                  });
                }

              }),
            ],
          ),
        ),
      ),
    );
  }
}
