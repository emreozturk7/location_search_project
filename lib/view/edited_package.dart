library flutter_google_places.src;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart';
import 'package:location_search_project/core/color_palette.dart';
import 'package:location_search_project/core/context_extensions.dart';
import 'package:rxdart/rxdart.dart';

class PlacesAutocompleteWidget extends StatefulWidget {
  final ValueChanged<PlacesAutocompleteResponse>? onError;
  final String? proxyBaseUrl;
  final BaseClient? httpClient;

  const PlacesAutocompleteWidget({
    this.onError,
    Key? key,
    this.proxyBaseUrl,
    this.httpClient,
  }) : super(key: key);

  @override
  State<PlacesAutocompleteWidget> createState() =>
      _PlacesAutocompleteOverlayState();

  static PlacesAutocompleteState? of(BuildContext context) =>
      context.findAncestorStateOfType<PlacesAutocompleteState>();
}

class _PlacesAutocompleteOverlayState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final header = Material(
      color: primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Expanded(
            flex: 2,
            child: Icon(Icons.search, color: quaternaryTextColor),
          ),
          const Spacer(),
          Expanded(
            flex: 45,
            child: _textField(context),
          ),
        ],
      ),
    );

    Widget body;

    if (_searching) {
      body = Stack(
        children: [
          _Loader(),
        ],
      );
    } else if (_queryTextController.text.isEmpty ||
        _response == null ||
        _response!.predictions.isEmpty) {
      body = Material(
        color: primaryColor,
        child: null,
      );
    } else {
      body = SingleChildScrollView(
        child: Material(
          color: primaryColor,
          child: ListBody(
            children: _response!.predictions
                .map(
                  (p) => PredictionTile(
                    prediction: p,
                    onTap: Navigator.of(context).pop,
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    final container = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: transparentColor,
      body: Padding(
        padding: EdgeInsets.only(
          left: context.mediumValue,
          right: context.mediumValue,
          top: context.mediumValue,
          bottom: context.lowValue,
        ),
        child: Column(
          children: [
            const Spacer(flex: 7),
            Expanded(
              flex: 8,
              child: header,
            ),
            Expanded(
              flex: 24,
              child: body,
            ),
            const Spacer(flex: 36),
          ],
        ),
      ),
    );

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return container;
    }
    return container;
  }

  Widget _textField(BuildContext context) => TextField(
        autofocus: true,
        controller: _queryTextController,
        cursorColor: secondaryTextColor,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: transparentColor,
            ),
          ),
          filled: true,
          fillColor: primaryColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: transparentColor,
            ),
          ),
        ),
      );
}

class _Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 2.0),
      child: const LinearProgressIndicator(),
    );
  }
}

class PlacesAutocompleteResult extends StatefulWidget {
  final ValueChanged<Prediction>? onTap;

  const PlacesAutocompleteResult({Key? key, this.onTap}) : super(key: key);

  @override
  _PlacesAutocompleteResult createState() => _PlacesAutocompleteResult();
}

class _PlacesAutocompleteResult extends State<PlacesAutocompleteResult> {
  @override
  Widget build(BuildContext context) {
    final state = PlacesAutocompleteWidget.of(context)!;

    if (state._queryTextController.text.isEmpty ||
        state._response == null ||
        state._response!.predictions.isEmpty) {
      final children = <Widget>[];
      if (state._searching) {
        children.add(_Loader());
      }
      children.add(Container());
      return Stack(children: children);
    }
    return PredictionsListView(
      predictions: state._response!.predictions,
      onTap: widget.onTap,
    );
  }
}

class PredictionsListView extends StatelessWidget {
  final List<Prediction> predictions;
  final ValueChanged<Prediction>? onTap;

  const PredictionsListView({Key? key, required this.predictions, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: predictions
          .map((Prediction p) => PredictionTile(prediction: p, onTap: onTap))
          .toList(),
    );
  }
}

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final ValueChanged<Prediction>? onTap;

  const PredictionTile({Key? key, required this.prediction, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Material(
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Expanded(
                  flex: 2,
                  child: Icon(Icons.search, color: quaternaryTextColor),
                ),
                const Spacer(flex: 3),
                Expanded(
                  flex: 45,
                  child: InkWell(
                    onTap: () {
                      if (onTap != null) {
                        onTap!(prediction);
                      }
                    },
                    child: Text(
                      prediction.description!,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: fifthTextColor,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

abstract class PlacesAutocompleteState extends State<PlacesAutocompleteWidget> {
  final TextEditingController _queryTextController = TextEditingController();
  PlacesAutocompleteResponse? _response;
  GoogleMapsPlaces? _places;
  late bool _searching;
  Timer? _debounce;
  final _queryBehavior = BehaviorSubject<String>.seeded('');

  @override
  void initState() {
    super.initState();

    _initPlaces();
    _searching = false;

    _queryTextController.addListener(_onQueryChange);

    _queryBehavior.stream.listen(doSearch);
  }

  Future<void> _initPlaces() async {
    final kGoogleApiKey = FlutterConfig.get('API_KEY').toString();

    _places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      baseUrl: widget.proxyBaseUrl,
      httpClient: widget.httpClient,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
  }

  Future<void> doSearch(String value) async {
    if (mounted && value.isNotEmpty && _places != null) {
      setState(() {
        _searching = true;
      });

      final res = await _places!.autocomplete(value);

      if (res.errorMessage?.isNotEmpty == true ||
          res.status == "REQUEST_DENIED") {
        onResponseError(res);
      } else {
        onResponse(res);
      }
    } else {
      onResponse(null);
    }
  }

  void _onQueryChange() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!_queryBehavior.isClosed) {
        _queryBehavior.add(_queryTextController.text);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _places?.dispose();
    _debounce?.cancel();
    _queryBehavior.close();
    _queryTextController.removeListener(_onQueryChange);
  }

  @mustCallSuper
  void onResponseError(PlacesAutocompleteResponse res) {
    if (!mounted) return;

    if (widget.onError != null) {
      widget.onError!(res);
    }
    setState(() {
      _response = null;
      _searching = false;
    });
  }

  @mustCallSuper
  void onResponse(PlacesAutocompleteResponse? res) {
    if (!mounted) return;

    setState(() {
      _response = res;
      _searching = false;
    });
  }
}

class PlacesAutocomplete {
  static Future<Prediction?> show({
    required BuildContext context,
    ValueChanged<PlacesAutocompleteResponse>? onError,
    String? proxyBaseUrl,
    Client? httpClient,
  }) {
    builder(BuildContext ctx) => PlacesAutocompleteWidget(
          onError: onError,
          proxyBaseUrl: proxyBaseUrl,
          httpClient: httpClient as BaseClient?,
        );
    return showDialog(
      context: context,
      builder: builder,
      barrierColor: transparentColor,
    );
  }
}
