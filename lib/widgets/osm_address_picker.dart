// lib/screens/osm_address_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../colors.dart';

class OSMAddressPicker extends StatefulWidget {
  final Function(Map<String, String>) onAddressSelected;

  const OSMAddressPicker({
    super.key,
    required this.onAddressSelected,
  });

  @override
  State<OSMAddressPicker> createState() => _OSMAddressPickerState();
}

class _OSMAddressPickerState extends State<OSMAddressPicker> {
  LatLng _selectedLocation = const LatLng(11.5564, 104.9282);
  String _selectedAddress = '';
  bool _isLoading = false;
  final MapController _mapController = MapController();

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedLocation = position;
      _getAddressFromCoordinates(position);
    });
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    setState(() => _isLoading = true);
    try {
      final addresses = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (addresses.isNotEmpty) {
        final place = addresses[0];
        setState(() {
          _selectedAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _confirmAddress() {
    if (_selectedAddress.isNotEmpty) {
      widget.onAddressSelected({
        'address': _selectedAddress,
        'lat': _selectedLocation.latitude.toString(),
        'lng': _selectedLocation.longitude.toString(),
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          if (_selectedAddress.isNotEmpty)
            TextButton(
              onPressed: _confirmAddress,
              child: const Text('Confirm', style: TextStyle(color: MyColors.primary)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedAddress.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: MyColors.primary.withOpacity(0.05),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: MyColors.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_selectedAddress)),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 14,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                if (_selectedAddress.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: _selectedLocation,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Current Location'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedAddress.isNotEmpty ? _confirmAddress : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() {
    // Use location package or skip
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Use location package to get current position'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}