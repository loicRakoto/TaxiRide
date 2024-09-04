import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:custom_clippers/custom_clippers.dart';

Widget introWidget(){
  return ClipPath(
    clipper: DirectionalWaveClipper(),
    child: Container(
      width: Get.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/textpng.png"),
          fit: BoxFit.cover
        )
      ),
      height: Get.height*0.6,
    ),
  );
}