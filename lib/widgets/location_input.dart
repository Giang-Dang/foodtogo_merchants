
import 'dart:developer';
import 'dart:math';

import 'package:foodtogo_merchants/services/location_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/models/place_location.dart';
import 'package:foodtogo_merchants/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({
    super.key,
    required this.onSelectLocation,
  });

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  var locationServices = LocationServices();

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;

    return locationServices.getlocationImageUrl(lat, lng);
  }

  void _savePlace(double lat, double lng) async {
    final address = await locationServices.getAddress(lat, lng);

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );
      _isGettingLocation = false;
    });

    widget.onSelectLocation(_pickedLocation!);
  }

  void _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    double locationAccuracy = 200.0;
    Position locationData = await locationServices.determinePosition();

    int attempts = 0;
    while (locationAccuracy > 50.0 && attempts < 10) {
      locationData = await locationServices.determinePosition();
      locationAccuracy = min(locationAccuracy, locationData.accuracy);
      attempts++;
    }

    final lat = locationData.latitude;
    final lng = locationData.longitude;
    inspect(locationData);

    _savePlace(lat, lng);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  void initState() {
    super.initState();
    _pickedLocation = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: KColors.kPrimaryColor,
          ),
    );

    Widget overlayMapContent = const SizedBox();

    if (_pickedLocation != null) {
      previewContent = FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: NetworkImage(locationImage),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
      inspect(_pickedLocation);
      if (_pickedLocation!.address.isNotEmpty) {
        overlayMapContent = Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 44,
            ),
            child: Text(
              _pickedLocation!.address,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KColors.kOnBackgroundColor,
                fontSize: 12,
              ),
            ),
          ),
        );
      }
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 170,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: previewContent,
            ),
            overlayMapContent,
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(
                Icons.my_location,
                size: 25,
              ),
              label: const Text(
                'My Location',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(
                Icons.pin_drop,
                size: 25,
              ),
              label: const Text(
                'Select on Map',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
