import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_search_project/core/constants.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_api_headers/google_api_headers.dart';
import 'dart:ui' as ui;

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

final kGoogleApiKey = FlutterConfig.get('API_KEY').toString();
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchViewState extends State<SearchView> {
  TextEditingController countryCtrl = TextEditingController();
  TextEditingController provienceCtrl = TextEditingController();
  TextEditingController districtCtrl = TextEditingController();
  TextEditingController postCodeCtrl = TextEditingController();
  TextEditingController searchCtrl = TextEditingController();

  String? _mapStyle;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);

  Set<Marker> markersList = {};

  late GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/style/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      backgroundColor: const Color(0xFFF1F3F6),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 36.0,
          right: 36.0,
          top: 53.0,
          bottom: 13.0,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cities',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: primaryTextColor,
                    ),
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        child: Image.asset('assets/images/img.png'),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 30),
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.5),
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: buildSearchTextField(context),
            ),
            const Spacer(flex: 2),
            Expanded(
              flex: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 6,
                          child: Text('Country'),
                        ),
                        const Spacer(flex: 2),
                        Expanded(
                          flex: 18,
                          child: buildTextField(countryCtrl),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  Expanded(
                    flex: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 6,
                          child: Text('Province'),
                        ),
                        const Spacer(flex: 2),
                        Expanded(
                          flex: 18,
                          child: buildTextField(provienceCtrl),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Expanded(
              flex: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 6,
                          child: Text('District'),
                        ),
                        const Spacer(flex: 2),
                        Expanded(
                          flex: 18,
                          child: buildTextField(districtCtrl),
                        )
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  Expanded(
                    flex: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 6,
                          child: Text('Post Code'),
                        ),
                        const Spacer(flex: 2),
                        Expanded(
                          flex: 18,
                          child: buildTextField(postCodeCtrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Expanded(
              flex: 40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: GoogleMap(
                  myLocationButtonEnabled: false,
                  initialCameraPosition: initialCameraPosition,
                  markers: markersList,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                    controller.setMapStyle(_mapStyle);
                  },
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  TextField buildSearchTextField(BuildContext context) {
    return TextField(
      enabled: searchCtrl.text.isNotEmpty ? false : true,
      controller: searchCtrl,
      onTap: () => _handlePressButton(),
      cursorColor: secondaryTextColor,
      decoration: InputDecoration(
        hintText: 'Search',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: transparentColor,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        filled: true,
        fillColor: backgrounColorTwo,
        prefixIcon: Icon(
          Icons.search,
          color: quaternaryTextColor,
        ),
        labelStyle: TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: transparentColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  TextField buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      enabled: false,
      style: TextStyle(
        color: secondaryTextColor,
      ),
      decoration: InputDecoration(
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: transparentColor,
          ),
        ),
        filled: true,
        fillColor: backgrounColorTwo,
      ),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode,
      language: "tr",
      types: [""],
      strictbounds: false,
      components: [Component(Component.country, "tr")],
    );

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage!),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> displayPrediction(
    Prediction p,
    ScaffoldState? currentState,
  ) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    searchCtrl.text = detail.result.addressComponents[0].longName;
    countryCtrl.text = detail.result.addressComponents[4].longName;
    provienceCtrl.text = detail.result.addressComponents[3].longName;
    districtCtrl.text = detail.result.addressComponents[2].longName;
    postCodeCtrl.text = detail.result.addressComponents[5].longName;

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    final Uint8List customMarker = await getBytesFromAsset(
      path: 'assets/images/img_3.png',
      width: 40,
    );

    markersList.clear();
    markersList.add(
      Marker(
        icon: BitmapDescriptor.fromBytes(customMarker),
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name),
      ),
    );

    setState(() {});

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

  Future<Uint8List> getBytesFromAsset(
      {required String path, required int width}) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
