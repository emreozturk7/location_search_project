import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_search_project/core/color_palette.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:location_search_project/view/edited_package.dart';
import 'dart:ui' as ui;

import 'package:location_search_project/core/context_extensions.dart';

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

  String? _mapStyle;
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(37.42796, -122.08574),
    zoom: 14.0,
  );

  Set<Marker> markersList = {};

  late GoogleMapController googleMapController;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/style/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  String cities = 'Cities';
  String country = 'Country';
  String provience = 'Provience';
  String district = 'District';
  String postCode = 'Post Code';
  String explore = 'Explore';
  String search = 'Search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: homeScaffoldKey,
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(
          left: context.mediumValue,
          right: context.mediumValue,
          top: context.mediumValue,
          bottom: context.lowValue,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cities,
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        child: Image.asset('assets/images/profile_icon.png'),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: context.dynamicHeight(0.045),
                        ),
                        width: context.lowValue,
                        height: context.lowValue,
                        decoration: BoxDecoration(
                          borderRadius: context.lowBorderRadius,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 8,
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
                        Expanded(
                          flex: 7,
                          child: buildTextFieldTitle(context, country),
                        ),
                        const Spacer(),
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
                        Expanded(
                          flex: 7,
                          child: buildTextFieldTitle(context, provience),
                        ),
                        const Spacer(),
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
                        Expanded(
                          flex: 7,
                          child: buildTextFieldTitle(context, district),
                        ),
                        const Spacer(),
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
                        Expanded(
                          flex: 7,
                          child: buildTextFieldTitle(context, postCode),
                        ),
                        const Spacer(),
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
              flex: 32,
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
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Text buildTextFieldTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: tertiaryTextColor,
          ),
    );
  }

  TextField buildSearchTextField(BuildContext context) {
    return TextField(
      onTap: () => _handlePressButton(),
      cursorColor: secondaryTextColor,
      decoration: InputDecoration(
        hintText: search,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: transparentColor,
          ),
          borderRadius: context.lowBorderRadius,
        ),
        filled: true,
        fillColor: backgrounColorTwo,
        prefixIcon: Icon(
          Icons.search,
          color: quaternaryTextColor,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: transparentColor,
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
          borderRadius: context.lowBorderRadius,
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
      onError: onError,
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

    countryCtrl.text = "No data";
    districtCtrl.text = "No data";
    provienceCtrl.text = "No data";
    postCodeCtrl.text = "No data";

    for (var j = 0; j < detail.result.addressComponents.length; j++) {
      for (var k = 0;
          k < detail.result.addressComponents[j].types.length;
          k++) {
        String data = detail.result.addressComponents[j].types[k];

        switch (data) {
          case "country":
            countryCtrl.text = detail.result.addressComponents[j].longName;
            break;
          case "administrative_area_level_2":
            districtCtrl.text = detail.result.addressComponents[j].longName;
            break;
          case "administrative_area_level_1":
            provienceCtrl.text = detail.result.addressComponents[j].longName;
            break;
          case "postal_code":
            postCodeCtrl.text = detail.result.addressComponents[j].longName;
            break;
          default:
            break;
        }
      }
    }

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    final Uint8List customMarker = await getBytesFromAsset(
      path: 'assets/images/marker_icon.png',
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

    googleMapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0),
    );
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
