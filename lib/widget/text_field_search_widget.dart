import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_color.dart';


Widget textFieldSearchWidget(String FieldName, IconData IconName, Function(String) onChanged){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 9),
    child: Container(
      width: Get.width,
      // height: 50,
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 4,
                blurRadius: 10)
          ],
          borderRadius: BorderRadius.circular(8)),
      child: TextFormField(
        onChanged: (val) {
          onChanged(val);  // Appeler la fonction de rappel avec la nouvelle valeur
        },
        textAlign: TextAlign.start,
        readOnly: false,
        autocorrect: false,
        enableSuggestions: false,
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xffA7A7A7)),
        decoration:  InputDecoration(
            hintText: FieldName,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Icon(
                IconName,
                color: Colors.black,
                size: 22,
              ),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15)),
      ),
    ),
  );
}