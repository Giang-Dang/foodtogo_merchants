import 'package:foodtogo_merchants/models/place_location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 10.763657726715575,
      longitude: 106.68419901361023,
      address: '',
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;

  @override
  State<StatefulWidget> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(_pickedLocation);
        },
        child: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? 'Pick your location' : 'Your location',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextFormField(
              decoration: InputDecoration(
                label: const Text('Enter your address'),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onTap: !widget.isSelecting
                  ? null
                  : (position) {
                      setState(() {
                        _pickedLocation = position;
                      });
                    },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.location.latitude,
                  widget.location.longitude,
                ),
                zoom: 16,
              ),
              markers: (_pickedLocation == null && widget.isSelecting)
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('m1'),
                        position: _pickedLocation ??
                            LatLng(
                              widget.location.latitude,
                              widget.location.longitude,
                            ),
                      ),
                    },
            ),
          ),
        ],
      ),
    );
  }
}
