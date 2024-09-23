import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_ride/utils/app_color.dart';

Widget TextFieldWidget(String title, IconData iconData, TextEditingController controller, Function validator){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54),
      ),
      const SizedBox(
        height: 6,
      ),
      Container(
        width: Get.width,
        // height: 50,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 1)
            ],
            borderRadius: BorderRadius.circular(8)),
        child: TextFormField(
          // readOnly: readOnly,
          // onTap: ()=> onTap!(),
          validator: (input)=> validator(input),
          autocorrect: false,
          enableSuggestions: false,
          controller: controller,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xffA7A7A7)),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                iconData,
                color: AppColor.orangeColor,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15)
          ),
        ),
      )
    ],
  );
}
