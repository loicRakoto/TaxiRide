import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:location/location.dart' as locat;
import 'package:location/location.dart';
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
  FocusNode startFocusNode = FocusNode();
  FocusNode endFocusNode = FocusNode();

  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();

  LatLng ? departAdress ;
  LatLng ? arriveAdress ;

  Set<Marker> markers = Set<Marker>();

  bool showAddressSheet = false;


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
              child: textFieldSearchWidget(startController,startFocusNode, "Lieu de départ", Icons.location_history,(val){
                getSuggestion(val);
              }),
            ),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: textFieldSearchWidget(endController,endFocusNode, "Destination finale", Icons.location_pin,(val){
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

  Marker? departureMarker;
  Marker? destinationMarker;

  void _findPlace(LatLng place) {
    // Centrer la caméra sur la position sélectionnée
    myMapController!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: place, zoom: 12),
    ));
  }

  String choixchamp ="";
  TextEditingController addressController = TextEditingController();
  void onSuggestionSelected(LatLng selectedPlace, String choix) {
    // Ferme le BottomSheet actuel
    Get.back();

    // Déplace la carte vers l'endroit sélectionné
    _findPlace(selectedPlace);
    // Affiche un nouveau BottomSheet avec un champ de texte pour personnaliser l'adresse
    choixchamp = choix;
    showAddressSheet = true;
  }


  void _updatePosition(LatLng centerPosition) {
    // Geocoding pour récupérer les informations à partir des coordonnées
    placemarkFromCoordinates(centerPosition.latitude, centerPosition.longitude)
        .then((placemarks) {
      var output = 'No results found.';

      if (placemarks.isNotEmpty) {
        // Récupère le premier Placemark dans la liste
        Placemark place = placemarks[0];

        // Extraction des informations spécifiques
        String? country = place.country;
        String? administrativeArea = place.administrativeArea;
        String? subAdministrativeArea = place.subAdministrativeArea;
        String? subLocality = place.subLocality;
        String? street = place.street;

        // Créer une liste des éléments non nuls
        List<String> addressParts = [];

        if (subLocality != null && subLocality.isNotEmpty) {
          addressParts.add(subLocality);
        } if (street != null && street.isNotEmpty) {
          addressParts.add(street);
        }
        if (subAdministrativeArea != null && subAdministrativeArea.isNotEmpty) {
          addressParts.add(subAdministrativeArea);
        }
        if (administrativeArea != null && administrativeArea.isNotEmpty) {
          addressParts.add(administrativeArea);
        }
        if (country != null && country.isNotEmpty) {
          addressParts.add(country);
        }
        output = addressParts.join(', ');

        // Mettre à jour le TextField avec l'adresse formatée
        addressController.text = output;
      }
    }).catchError((error) {
      print("Erreur lors du Geocoding: $error");
    });
  }






  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final locationController = locat.Location();
  static const googlePlex = LatLng(-21.4225525, 47.1069917);
  static const emplacementAleatoire = LatLng(-21.434133333186164, 47.089535043312395);

  LatLng? currentPosition;

  CameraPosition? cameraPositionSearch;

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
              markers: markers,
              onCameraMove: (CameraPosition position) {
                setState(() {
                  cameraPositionSearch = position; // Stocke la position actuelle de la caméra
                });
              },
              onCameraIdle: () {
                // Appelé lorsque la caméra s'arrête de bouger, met à jour la position
                if (cameraPositionSearch != null) {
                  _updatePosition(cameraPositionSearch!.target); // Met à jour la position
                }
              },
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                myMapController = controller;
              },
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(target: googlePlex, zoom: 13),
            ),
          ),
          buildProfileTile(),
          buildTextField(),
          buildCurrentLocation(),

          // Afficher le Container uniquement si showAddressSheet est vrai
          if (showAddressSheet) ...[
            Positioned(
              top: Get.height-200,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                // height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 4,
                          blurRadius: 10)
                    ],
                    borderRadius: BorderRadius.circular(8)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(choixchamp == "D" ? "Lieu de départ" : choixchamp == "A" ? "Destination finale" : "",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,color: Colors.black45),
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFF7F7F7)
                          ),
                          child: TextFormField(
                            controller: addressController,
                            textAlign: TextAlign.start,
                            readOnly: true,
                            enableSuggestions: false,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xffA7A7A7)),
                            decoration:  const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.sensors_outlined,
                                  color: Colors.black,
                                  size: 22,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 15)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal, // Couleur de fond du bouton
                                foregroundColor: Colors.white, // Couleur du texte ou de l'icône du bouton// Padding interne du bouton
                                shape: RoundedRectangleBorder( // Forme du bouton
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                elevation: 5, // Ombre du bouton
                                shadowColor: Colors.grey, // Couleur de l'ombre
                                textStyle: const TextStyle(
                                  fontSize: 18, // Taille du texte
                                  fontWeight: FontWeight.bold, // Poids du texte
                                ),
                              ),
                              onPressed: () {
                                // Soumettre l'adresse personnalisée
                                String customAddress = addressController.text;
                                Get.back(); // Fermer ce BottomSheet
                                // Rediriger vers l'ancien BottomSheet avec l'adresse personnalisée
                                if (choixchamp == "D") {
                                  startController.text = customAddress;
                                } else if (choixchamp == "A") {
                                  endController.text = customAddress;
                                }
                                // Cacher le Container après la soumission
                                setState(() {
                                  showAddressSheet = false;
                                });
                                // Appeler la fonction pour ouvrir l'ancien BottomSheet
                                _openBottomSheet();
                              },
                              child: const Text("Confirmer l'endroit choisi")),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.location_on,
                color: Colors.teal,
                size: 40,
              ),
            ),
          ],
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
              separatorBuilder: (context, index) => const Divider(
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

                  //Properties
                  String? name = properties['name'];
                  String? city = properties['city'];
                  String? state = properties['state'];
                  String? county = properties['county'];
                  String? country = properties['country'];

                  List<String> Adresse = [];

                  if(name!=null && name.isNotEmpty){
                    Adresse.add(name);
                  } if(city!=null && city.isNotEmpty){
                    Adresse.add(city);
                  } if(state!=null && state.isNotEmpty){
                    Adresse.add(state);
                  } if(county!=null && county.isNotEmpty){
                    Adresse.add(county);
                  } if(country!=null && country.isNotEmpty){
                    Adresse.add(country);
                  }

                  String sortie = Adresse.join(', ');



          
                  return ListTile(
                    leading: Icon(Icons.place_outlined,color: Color(0xffA7A7A7),),
                    subtitle: Text(
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffA7A7A7)),
                          sortie
                         // '${coordinates[1]}, ${coordinates[0]}',
                    ),
                    onTap: (){
                      String convert = "${coordinates[1]}, ${coordinates[0]}";
                      List<String> latLng = convert.split(',');
                      double latitude = double.parse(latLng[0]);
                      double longitude = double.parse(latLng[1]);
                      LatLng position = LatLng(latitude, longitude);

                      // Vérifie quel champ a le focus
                      if (startFocusNode.hasFocus) {
                        departAdress = position;
                        startController.text = sortie ;

                        if (departAdress != null ) {
                          onSuggestionSelected(departAdress!,'D');
                        } else {
                          print("Attente de l' adresses ");
                        }
                      } else if (endFocusNode.hasFocus) {
                        arriveAdress = position;
                        endController.text = sortie;
                        if (arriveAdress != null ) {
                          onSuggestionSelected(arriveAdress!,'A');
                        } else {
                          print("Attente de l' adresses ");
                        }
                      }
                      _placeList.clear();
                    },
                  );
                }
              },
            ),
          ),
        )
    ) ;
  }

}
