import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart';
import 'package:taxi_ride/utils/app_color.dart';
import 'package:http/http.dart' as http;
import 'package:taxi_ride/widget/text_field_search_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  RxList<dynamic> _placeList = <dynamic>[].obs;  // Assure-toi d'importer 'package:get/get.dart'

  bool afficher= false;


  @override
  void initState() {
    // TODO: implement initState
    _initializeMapRenderer();
  }

  void _initializeMapRenderer() {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  void getSuggestion(String input) async {
    try{
      String baseURL = 'https://photon.komoot.io/api/';
      String request = '$baseURL?q=$input&limit=4';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        _placeList.value =  data['features'];
      } else {
        throw Exception('Failed to load predictions');
      }
    }catch(e){
      print(e);
    }
  }

   void _openBottomSheet(){
    Get.bottomSheet(
      Container(
        width: Get.width,
        height: Get.height,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(10)),
            color: Colors.white),
        child: Column(
          children: [
            SizedBox(height: 10,),
            Container(
              width: Get.width/3,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20)
              ),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: textFieldSearchWidget("Lieu de départ", Icons.location_history,(val){
                getSuggestion(val);
              }),
            ),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: textFieldSearchWidget("Destination finale", Icons.location_pin,(val){
                getSuggestion(val);
              }),
            ),
            SizedBox(height: 15,),
            listBuilder()
          ],
        ),
      )
    );
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final locationController = Location();
  static const googlePlex = LatLng(-21.4225525, 47.1069917);
  static const emplacementAleatoire =
      LatLng(-21.434133333186164, 47.089535043312395);

  LatLng? currentPosition;

  GoogleMapController? myMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 138,
            left: 0,
            right: 0,
            bottom: 0,
            child: GoogleMap(
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                myMapController = controller;
              },
              mapType: MapType.normal,
              initialCameraPosition:
                  const CameraPosition(target: googlePlex, zoom: 13),
            ),
          ),
          buildProfileTile(),
          buildTextField(),
          buildCurrentLocation(),

        ],
      ),

    );
  }

  Widget buildProfileTile() {
    return Positioned(
        top: 40,
        left: 20,
        right: 20,
        child: SizedBox(
          width: Get.width,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: AppColor.orangeColor,
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 19,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: const TextSpan(children: [
                    TextSpan(
                        text: 'Heureux de te voir  ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: 'Loic',
                        style: TextStyle(
                            color: AppColor.orangeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ])),
                  RichText(
                      text: const TextSpan(children: [
                    TextSpan(
                        text: 'Où souhaitez vous aller ? ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))
                  ])),
                ],
              )
            ],
          ),
        ));
  }

  Widget buildTextField() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        width: Get.width,
        // height: 50,
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 4,
                  blurRadius: 10)
            ],
            borderRadius: BorderRadius.circular(8)),
        child: TextFormField(
          textAlign: TextAlign.start,
          readOnly: true,
          onChanged: (valeur)=> getSuggestion(valeur),
          onTap: (){
            _openBottomSheet();
          },
          autocorrect: false,
          enableSuggestions: false,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xffA7A7A7)),
          decoration: const InputDecoration(
              hintText: "Rechercher une direction",
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Icon(
                  Icons.search,
                  color: AppColor.orangeColor,
                  size: 30,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15)),
        ),
      ),
    );
  }

  Widget buildCurrentLocation() {
    return const Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircleAvatar(
          backgroundColor: AppColor.orangeColor,
          radius: 25,
          child: Icon(
            Icons.location_searching_sharp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget listBuilder() {
    return Obx(()=>
        Expanded(
          child: Container(
            color: Color(0xFFF7F7F7),
            width: Get.width,
            height: Get.height,
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
                thickness: 1,
                height: 0,
              ),
              itemCount: _placeList.length + 2,
              itemBuilder: (context, index) {

                if (index == 0) {
                  return ListTile(
                    leading: Icon(Icons.my_location, color:Color(0xffA7A7A7)),
                    title: Text("Ma position actuelle",style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffA7A7A7)),),
                    onTap: () {

                      print("Ma position actuelle sélectionnée",);
                    },
                  );
                } else if (index == 1) {
                  return ListTile(
                    leading: Icon(Icons.map, color: Color(0xffA7A7A7)),
                    title: Text("Choisir sur la carte",style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffA7A7A7)),),
                    onTap: () {
                      // Action pour "Choisir sur la carte"
                      print("Choisir sur la carte sélectionné");
                    },
                  );
                } else {
                  // Les autres éléments dynamiques de la liste (_placeList)
                  var place = _placeList[index - 2];  // Ajuster l'index pour _placeList
                  var coordinates = place['geometry']['coordinates'];
                  var properties = place['properties'];
          
                  return ListTile(
                    leading: Icon(Icons.place_outlined,color: Color(0xffA7A7A7),),
                    subtitle: Text(
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffA7A7A7)),
                      '${properties['name'] ?? ''}, '
                          '${properties['city'] ?? ''}, '
                          '${properties['state'] ?? ''}, '
                          '${properties['county'] ?? ''}'
                          '${properties['country'] ?? ''}, '
                         // '${coordinates[1]}, ${coordinates[0]}',
                    ),
                  );
                }
              },
            ),
          ),
        )
    ) ;
  }

}
