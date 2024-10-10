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
import 'package:flutter/services.dart';

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
  bool hideSearchPrincipale = false;


  @override
  void initState() {
    // TODO: implement initState
    _initializeMapRenderer();
    // Change la couleur de la StatusBar

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
      enterBottomSheetDuration: Duration(milliseconds: 500),
      exitBottomSheetDuration: Duration(milliseconds: 500),
      isScrollControlled: true,
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          width: Get.width,
          height: Get.height,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(10)),
              color: Colors.white),
          child: Column(
            children: [
              SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  child:  Row(
                    children: [
                      IconButton(
                          onPressed: ()=> Get.back(),
                          icon: Icon(Icons.arrow_circle_left,size: 40,color: Colors.black,)),

                      Text("Votre itinéraire", style: TextStyle(wordSpacing: 0, fontSize: 20, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: textFieldSearchWidget(startController,startFocusNode, "Lieu de départ", Icons.location_history,(val){
                  getSuggestion(val);
                },_placeList),
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: textFieldSearchWidget(endController,endFocusNode, "Destination finale", Icons.location_pin,(val){
                  getSuggestion(val);
                },_placeList),
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: listBuilder(),
              ),
              SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: (){},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Couleur de fond du bouton
                        foregroundColor: Colors.white, // Couleur du texte ou de l'icône du bouton// Padding interne du bouton
                        shape: RoundedRectangleBorder( // Forme du bouton
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                        elevation: 5, // Ombre du bouton
                        shadowColor: Colors.grey, // Couleur de l'ombre
                        textStyle: const TextStyle(
                          fontSize: 18, // Taille du texte
                          fontWeight: FontWeight.bold, // Poids du texte
                        ),
                      ),
                      child: Text('Confirmer la déstination')),
                ),
              )
            ],
          ),
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
    hideSearchPrincipale = true;
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // couleur de fond de la StatusBar
      statusBarIconBrightness: Brightness.dark, // couleur du texte et des icônes
    ));

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
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
          buildMenuBoutom(),
          if(!hideSearchPrincipale)...[
            buildTextField(),
          ],
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal, // Couleur de fond du bouton
                                foregroundColor: Colors.white, // Couleur du texte ou de l'icône du bouton// Padding interne du bouton
                                shape: RoundedRectangleBorder( // Forme du bouton
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
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

                                // Appeler la fonction pour ouvrir l'ancien BottomSheet
                                _openBottomSheet();

                                setState(() {
                                  showAddressSheet = false;
                                  hideSearchPrincipale = false;
                                });

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



  Widget buildMenuBoutom() {
    return const Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.menu,
                color: Colors.teal,
              ),
            )
          ],
        )
    );
  }

  Widget buildTextField() {
    return Positioned(
      top: 150,
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
            _placeList.clear();
          },
          autocorrect: false,
          enableSuggestions: false,
          style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xffA7A7A7)),
          decoration: const InputDecoration(
              hintText: "Rechercher une direction",
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Icon(
                  Icons.flag_circle,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 22)),
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
          backgroundColor: Colors.white,
          radius: 25,
          child: Icon(
            Icons.location_searching_sharp,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  Widget listBuilder() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFF7F7F7),
      ),
      width: Get.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: List.generate(
            _placeList.length + 2, // +2 pour les deux premiers éléments fixes
                (index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    print("Ma position actuelle sélectionnée");
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centre horizontalement
                      children: [
                        Icon(Icons.my_location, color: Color(0xffA7A7A7)),
                        SizedBox(width: 10), // Espacement entre l'icône et le texte
                        Expanded(
                          child: Text(
                            "Ma position actuelle",
                            textAlign: TextAlign.start, // Centre le texte
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffA7A7A7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (index == 1) {
                return GestureDetector(
                  onTap: () {
                    print("Choisir sur la carte sélectionné");
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, color: Color(0xffA7A7A7)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Choisir sur la carte",
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffA7A7A7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                var place = _placeList[index - 2]; // Ajuster l'index pour _placeList
                var coordinates = place['geometry']['coordinates'];
                var properties = place['properties'];

                String? name = properties['name'];
                String? city = properties['city'];
                String? state = properties['state'];
                String? county = properties['county'];
                String? country = properties['country'];

                List<String> Adresse = [];

                if (name != null && name.isNotEmpty) {
                  Adresse.add(name);
                }
                if (city != null && city.isNotEmpty) {
                  Adresse.add(city);
                }
                if (state != null && state.isNotEmpty) {
                  Adresse.add(state);
                }
                if (county != null && county.isNotEmpty) {
                  Adresse.add(county);
                }
                if (country != null && country.isNotEmpty) {
                  Adresse.add(country);
                }

                String sortie = Adresse.join(', ');

                return GestureDetector(
                  onTap: () {
                    String convert = "${coordinates[1]}, ${coordinates[0]}";
                    List<String> latLng = convert.split(',');
                    double latitude = double.parse(latLng[0]);
                    double longitude = double.parse(latLng[1]);
                    LatLng position = LatLng(latitude, longitude);

                    // Vérifie quel champ a le focus
                    if (startFocusNode.hasFocus) {
                      departAdress = position;
                      startController.text = sortie;

                      if (departAdress != null) {
                        onSuggestionSelected(departAdress!, 'D');
                      } else {
                        print("Attente de l'adresse ");
                      }
                    } else if (endFocusNode.hasFocus) {
                      arriveAdress = position;
                      endController.text = sortie;
                      if (arriveAdress != null) {
                        onSuggestionSelected(arriveAdress!, 'A');
                      } else {
                        print("Attente de l'adresse ");
                      }
                    }
                    _placeList.clear();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.place_outlined, color: Color(0xffA7A7A7)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            sortie,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffA7A7A7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    ));
  }




}
