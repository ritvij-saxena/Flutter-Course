import 'package:demo1/models/product.dart';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:demo1/widgets/products/helper/ensure-visible.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:demo1/models/location_data.dart';
import 'package:location/location.dart' as geoLocation;

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  LocationData _locationData;
  final FocusNode _addressInputFocusNode = new FocusNode();
  final TextEditingController _addressInputController = TextEditingController();
  Uri _staticMapUri;

//  Uri _staticMapUri_2;

  @override
  void initState() {
    _addressInputFocusNode.addListener(updateLocation);
//    forNullStaticMap();
    if (widget.product != null) {
      getStaticMap(widget.product.locationData.address, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(updateLocation);
    super.dispose();
  }

  void getStaticMap(String address,
      {bool geocode = true, double lat, double lng}) async {
    if (address == '') {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https(
          'maps.googleapis.com', '/maps/api/gecode/json', {
        'address': address,
        'key': 'AIzaSyBjD-J1bPXyniHW-hWKGO_o4a1zcePeBpI'
      });
      final http.Response response = await http.get(uri);
      final decodedResponse = json.decode(response.body);
      final formattedAddress =
          decodedResponse['results'][0]['formatted_address'];
      final coordinates = decodedResponse['results'][0]['geometry']['location'];
      _locationData = LocationData(
          address: formattedAddress,
          lat: coordinates['lat'],
          lng: coordinates['lng']);
    } else if (lat == null && lng == null) {
      _locationData = widget.product.locationData;
    } else {
      _locationData = LocationData(address: address, lat: lat, lng: lng);
    }
    if (mounted) {
      final StaticMapProvider staticMapProvider =
          StaticMapProvider('AIzaSyBjD-J1bPXyniHW-hWKGO_o4a1zcePeBpI');
      final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
        Marker('position', 'Position', _locationData.lat, _locationData.lng)
      ],
          center: Location(_locationData.lat, _locationData.lng),
          width: 500,
          height: 300,
          maptype: StaticMapViewType.roadmap);

      widget.setLocation(_locationData);

      setState(() {
        _addressInputController.text = _locationData.address;
        _staticMapUri = staticMapUri;
      });
    }
  }

  /*void forNullStaticMap() {
    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyBjD-J1bPXyniHW-hWKGO_o4a1zcePeBpI');
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers(
        [Marker('position', 'Position', 40.757296, 73.986053)],
        center: Location(40.757296, 73.986053),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);

    setState(() {
      _staticMapUri_2 = staticMapUri;
    });
  }*/

  void updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/gecode/json', {
      'latlng': '${lat.toString()},${lng.toString()}',
      'key': 'AIzaSyBjD-J1bPXyniHW-hWKGO_o4a1zcePeBpI'
    });
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _getUserLocation() async {
    final location = geoLocation.Location();
    try {
      final currentLocation = await location.getLocation();
      final address = await _getAddress(
          currentLocation['latitude'], currentLocation['longitude']);
      getStaticMap(address,
          geocode: false,
          lat: currentLocation['latitude'],
          lng: currentLocation['longitude']);
    } catch (error) {
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Could not fetch Location '),
          content: Text('Please add address nanually'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed:() => Navigator.pop(context),
            )
          ],
        );
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found';
              }
            },
            controller: _addressInputController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        IconButton(
          icon: Icon(Icons.location_on),
          onPressed: () {
            _getUserLocation;
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null
            ? Container(child: Text('Uri is null'))
            : Image.network(_staticMapUri.toString()),
      ],
    );
  }
}
