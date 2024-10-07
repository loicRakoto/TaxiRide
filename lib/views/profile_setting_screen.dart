import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_ride/utils/app_color.dart';
import 'package:taxi_ride/widget/mask_widget.dart';
import 'package:taxi_ride/widget/text_field_widget.dart';
import 'package:taxi_ride/widget/text_widget.dart';
import 'package:intl/intl.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cinController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController residenceController = TextEditingController();

  final List<DateTime> _dates = [
    DateTime.now().add(const Duration(days: 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Get.height * 0.4,
              child: Stack(
                children: [
                  Mask(),
                  Align(
                    child: Container(
                        width: 500,
                        height: 180,
                        alignment: Alignment.topCenter,
                        child: textWidget(
                            text: "Formulaire d'inscription",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            colors: Colors.white)),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                              color: AppColor.orangeColor, width: 1.5)),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: AppColor.orangeColor,
                          size: 55,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                children: [
                  TextFieldWidget("Nom", Icons.person, nameController, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre nom';
                    }
                    return null;
                  }),
                  const SizedBox(
                    height: 6.0,
                  ),
                  TextFieldWidget("CIN", Icons.credit_card, cinController,
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre CIN';
                    } else if (int.tryParse(value) == null) {
                      return "S'il vous plaît, veuillez entrer un nombre valide";
                    }
                    return null;
                  }),
                  const SizedBox(
                    height: 6.0,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date de naissance",
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
                            readOnly: true,
                            controller: birthdayController,
                            onTap: () async {
                              final values =
                                  await showCalendarDatePicker2Dialog(
                                context: context,
                                config:
                                    CalendarDatePicker2WithActionButtonsConfig(),
                                dialogSize: const Size(325, 370),
                                borderRadius: BorderRadius.circular(15),
                                value: _dates,
                                dialogBackgroundColor: Colors.white,
                              );
                              if (values != null) {
                                final selectedDate = values.first;
                                setState(() {
                                  birthdayController.text =
                                      DateFormat('yyyy-MM-dd')
                                          .format(selectedDate!);
                                });
                              }
                            },
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xffA7A7A7)),
                            decoration: const InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: AppColor.orangeColor,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15)),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),
                  TextFieldWidget("Adresse de résidence", Icons.location_city,
                      residenceController, (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre résidence';
                    }
                    return null;
                  }),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: submitBouton("Soumettre le formulaire"),
            )
          ],
        ),
      ),
    );
  }

  Widget submitBouton(String titre) {
    return MaterialButton(
      minWidth: Get.width,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: AppColor.orangeColor,
      onPressed: () {
        print("submit button");
        CollectionReference users =
            FirebaseFirestore.instance.collection('utilisateurs');
        users.add({
          'nom': nameController.text,
          'cin': cinController.text,
          'date_naissance': birthdayController.text,
          'residence': residenceController.text,
          'photo': 'lien_photo',
          'passagerDetails': {
            'totalRides': '',
            'notePassager': '',
          },
        });
      },
      child: Text(
        titre,
        style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
