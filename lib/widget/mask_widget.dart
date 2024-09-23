import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxi_ride/utils/app_color.dart';


Widget Mask(){
    return ClipPath(
      clipper: DirectionalWaveClipper(),
      child: Container(
        height: Get.height,
        width: Get.width,
        color: AppColor.orangeColor,
        ),
    );
}
