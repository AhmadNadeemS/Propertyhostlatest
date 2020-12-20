import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';
import 'package:signup/AppLogic/validation.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/services/PostAdCreation.dart';

import 'Arguments.dart';
import 'ImageCarousel.dart';
import 'navigation.dart';

Column _bottomLayerMenu() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ListTile(
        leading: Icon(
          Icons.school,
          color: Colors.blue,
        ),
        title: Text('Schools'),
      ),
      ListTile(
        leading: Icon(
          Icons.local_hospital,
          color: Colors.blue,
        ),
        title: Text(
          'Hospitals',
        ),
      ),
    ],
  );
}

class SearcResult extends StatefulWidget {
  @override
  _SearcResult createState() => _SearcResult();
}

class AppState extends InheritedWidget {
  const AppState({
    bool checkedSchool,
    bool checkedHospital,
    Key key,
    this.mode,
    Widget child,
  })  : assert(mode != null),
        assert(child != null),
        super(key: key, child: child);

  final Geocoding mode;

  static AppState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppState);
  }

  @override
  bool updateShouldNotify(AppState old) => mode != old.mode;
}

class _SearcResult extends State<SearcResult> {
  String token =
      'sk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGJvMnlhMTAwMG8yeG5vNXdlY2w2aTYifQ.maEiJc8WGc_0c1nZuWWeyQ';
  final String style = 'mapbox://styles/mapbox/streets-v11';

  Stream search;
  var infoWindowVisible = false;

  GlobalKey<FormState> _key = new GlobalKey();
  List<GlobalKey<FormState>> formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _validate = false;

  List<Marker> allmarkers = List<Marker>();
  Location location = new Location();
  latLng.LatLng center;
  AdPost adpost = new AdPost();
  TextEditingController priceFrom = new TextEditingController();
  TextEditingController searchField = new TextEditingController();
  TextEditingController priceTo = new TextEditingController();
  TextEditingController NoOfRoom = new TextEditingController();
  TextEditingController NoOfBath = new TextEditingController();


  @override
  void initState() {
    getLatlongOfAds();
    _determinePosition();

  }

  @override
  void dispose() {
    super.dispose();
    priceFrom.dispose();
    priceTo.dispose();
    NoOfRoom.dispose();
    NoOfBath.dispose();
  }

  getLatlongOfAds() {
    PostAddFirebase().getCordinatesOfAds().then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }

  _determinePosition() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }


    _locationData = await location.getLocation();
    setState(() {
      center = latLng.LatLng(_locationData.latitude, _locationData.longitude);
    });

  }


  ForSaleRentAds(AdPost adPost) {
    print(adPost.purpose);
    PostAddFirebase().getForSaleAds(adPost).then((snapshots) {

      if(adPost.purpose =="For Sale") {
        setState(() {
          search = snapshots;
          print("we got the data + ${search.toString()}");
        });
      }else{
        setState(() {
          search = snapshots;
          print("we got the data + ${search.toString()}");
        });
      }

    });
  }


  ForPriceAds(AdPost adPost) {
    print(adPost.priceFrom.toString());
    PostAddFirebase().ByPriceAds(adPost).then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }

  ForBedsBathAds(AdPost adPost) {
    print(adPost.bathrooms.toString());
    PostAddFirebase().ByBedBaths(adPost).then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }

  ForPropertyTypeandSubType(AdPost adPost) {
    print(adPost.propertyType.toString());
    PostAddFirebase().ByPropertyTypeSubType(adPost).then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }

  ForAllPropertyTypes(AdPost adPost) {
    print(adPost.propertyType.toString());
    PostAddFirebase().ByAllPropertyType(adPost).then((snapshots) {
      setState(() {
        search = snapshots;
        print("we got the data + ${search.toString()}");
      });
    });
  }


  bool isLoading = false;

  searchForCordinates(AdPost adPost) async {

    try {
      var geocoding = Geocoder.local;
      var centers = await geocoding.findAddressesFromQuery(adPost.Address);
      print("we got the cordinates agaisnt address + ${centers.toString()}+ ${centers.first.coordinates.toString()}");
    setState(() {
      center = latLng.LatLng(centers.first.coordinates.latitude, centers.first.coordinates.longitude);


    });
    print(center.toString() + " searched data");


    } catch (e) {
      print("Error occured in getting cordinates: $e");

  }
  }

  Stack _buildCustomMarker() {
    return Stack(
      children: <Widget>[marker()],
    );
  }

  marker() {
    return Icon(Icons.home);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  MapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    color: Color(0xFF737373),
                    child: Container(
                      child: _bottomLayerMenu(),
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10),
                          topRight: const Radius.circular(10),
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
        backgroundColor: Colors.grey[600],
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Property Host'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[800], Colors.blue[800]],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.5, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  height: 35.0,
                  child: Form(
              //      key: formKeys[0],
                    autovalidate: _validate,
                    child: TextFormField(
                      controller: searchField,
                   //   validator: ValidateLocation,
                      keyboardType: TextInputType.streetAddress,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                        letterSpacing: 2.0,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.pink[700], width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[100], width: 2.0),
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(
                            left: 15.0, bottom: 0.0, top: 10.0),
                        suffixIcon: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(width: 1.0, color: Colors.black),
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.search),
                            color: Colors.grey[800],
                            onPressed: () async{
                              adpost.Address = searchField.text.toString();
                              print("Search button pressed" + searchField.text.toString());
                              await searchForCordinates(adpost);


                            },
                          ),
                        ),
                      ),
                    ),
                  )),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                color: Color(0xFF737373),
                                child: Container(
                                  child: _bottomForSaleMenu(),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(10),
                                      topRight: const Radius.circular(10),
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                      child: Text('For Sale'),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.0),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            // isScrollControlled: true,
                            builder: (context) {
                              return Container(
                                height: 400,
                                color: Color(0xFF737373),
                                child: Container(
                                  child: _bottomPriceMenu(),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(10),
                                      topRight: const Radius.circular(10),
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                      child: Text('Price'),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.0),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                color: Color(0xFF737373),
                                height: 600,
                                child: Container(
                                  child: _bottomRoomsMenu(),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(10),
                                      topRight: const Radius.circular(10),
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                      child: Text('Beds & Baths'),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.0),
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return Container(
                                color: Color(0xFF737373),
                                height: 180,
                                child: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(Icons.home),
                                        title: Text('Home'),
                                        onTap: () {
                                          setState(() {
                                            adpost.propertyType = 'Homes';
                                          });
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return Container(
                                                  color: Color(0xFF737373),
                                                  height: 240,
                                                  child: Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        ListTile(
                                                          title: Text('House'),
                                                          onTap: () {
                                                            adpost.propertyDeatil ='House';
                                                            ForPropertyTypeandSubType(adpost);
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text('Flat'),
                                                          onTap: () {
                                                              adpost.propertyDeatil ='Flat';
                                                              ForPropertyTypeandSubType(adpost);
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text(
                                                              'Upper Portion'),
                                                          onTap: () {
                                                            adpost.propertyDeatil ='Upper Portion';
                                                            ForPropertyTypeandSubType(adpost);

                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text(
                                                              'Lower Portion'),
                                                          onTap: () {
                                                            adpost.propertyDeatil ='Lower Portion';
                                                            ForPropertyTypeandSubType(adpost);
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text('All'),
                                                          onTap: () {
                                                            adpost.propertyType ='Homes';
                                                            ForAllPropertyTypes(adpost);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .canvasColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(10),
                                                        topRight: const Radius
                                                            .circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.map),
                                        title: Text('Plot'),
                                        onTap: () {
                                             adpost.propertyType = 'Plots';
                                             ForAllPropertyTypes(adpost);
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return Container(
                                                  color: Color(0xFF737373),
                                                  height: 180,
                                                  child: Container(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        ListTile(
                                                          title: Text(
                                                              'Residential Plot'),
                                                          onTap: () {
                                                              adpost.propertyDeatil ='Residential Plot';
                                                              ForPropertyTypeandSubType(adpost);
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text(
                                                              'Commercial Plot'),
                                                          onTap: () {
                                                              adpost.propertyDeatil = 'Commercial Plot';
                                                              ForPropertyTypeandSubType(adpost);
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text('All'),
                                                          onTap: () {
                                                            adpost.propertyType ='Plots';
                                                            ForAllPropertyTypes(adpost);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .canvasColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(10),
                                                        topRight: const Radius
                                                            .circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.location_city),
                                        title: Text('Commercial'),
                                        onTap: () {
                                          adpost.propertyType = 'Commercial';
                                          ForAllPropertyTypes(adpost);
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return Container(
                                                  color: Color(0xFF737373),
                                                  height: 240,
                                                  child: Container(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        ListTile(
                                                          title: Text('Office'),
                                                          onTap: () {
                                                            adpost.propertyDeatil = 'Office';
                                                            ForPropertyTypeandSubType(adpost);
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text('Shop'),
                                                          onTap: () {
                                                            adpost.propertyDeatil = 'Shop';
                                                            ForPropertyTypeandSubType(adpost);
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text(
                                                              'Ware House'),
                                                          onTap: () {
                                                            adpost.propertyDeatil = 'Ware House';
                                                            ForPropertyTypeandSubType(adpost);
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text('All'),
                                                          onTap: () {
                                                            adpost.propertyType = 'Commercial';
                                                            ForAllPropertyTypes(adpost);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .canvasColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(10),
                                                        topRight: const Radius
                                                            .circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(10),
                                      topRight: const Radius.circular(10),
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                      child: Text('Home Type'),
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height / 1.32,
                    child: Stack(
                      children: <Widget>[
                        StreamBuilder(
                            stream: search,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return Text('Loading maps...Please Wait');
                              allmarkers = [];
                              debugPrint(snapshot.data.documents.length.toString());
                              for (int i = 0; i < snapshot.data.documents.length; i++) {
                                double lat = snapshot.data.documents[i]['Location'].latitude;
                                double lng = snapshot.data.documents[i]['Location'].longitude;
                               // debugPrint(lng.toString());

                                allmarkers.add(new Marker(
                                  point: latLng.LatLng(lat, lng),
                                  builder: (context) => GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return Container(
                                                height: 180,
                                                color: Color(0xFF737373),
                                                child: Container(
                                                  child: Column(
                                                    children: <Widget>[
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.attach_money),
                                                        title: Text(snapshot
                                                            .data
                                                            .documents[i]
                                                                ['Price']
                                                            .toString()),
                                                      ),
                                                      ListTile(
                                                          leading: Icon(
                                                              Icons.details),
                                                          title: Text(
                                                              'View Detail'),
                                                          onTap: () => Navigator
                                                                  .of(context)
                                                              .pushNamed(
                                                                  ImageCarousel
                                                                      .routeName,
                                                                  arguments: ScreenArguments(
                                                                      snapshot.data.documents[i].documentID.toString(), snapshot.data.documents[i].data['uid'].toString()))),
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.directions),
                                                        title: Text(
                                                            'Navigate to property'),
                                                        onTap: () {
                                                          double lat = snapshot
                                                              .data
                                                              .documents[i]
                                                              .data['Location']
                                                              .latitude;
                                                          double long = snapshot
                                                              .data
                                                              .documents[i]
                                                              .data['Location']
                                                              .longitude;

                                                          //   Navigator.pushNamed(context, '/navigation');
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => Navigation(
                                                                      latitude:
                                                                          lat,
                                                                      longitude:
                                                                          long)));
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .canvasColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              10),
                                                      topRight:
                                                          const Radius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                        debugPrint(
                                            "Tapp tapp loot ka no mazak");
                                      },
                                      child: _buildCustomMarker()),
                                ));
                              }
                              return FlutterMap(
                                  options: new MapOptions(
                                      plugins: [
                                        MarkerClusterPlugin(),
                                      ],
                                      zoom: 12,
                                      minZoom: 8.0,
                                      maxZoom: 18.0,
                                      interactive: true,
                                      center: new latLng.LatLng(center.latitude,center.longitude),                      /*new LatLng(33.692705, 73.047778)*/),

                                  layers: [
                                    new TileLayerOptions(
                                        urlTemplate:
                                            "https://api.mapbox.com/styles/v1/mawais/ckhbnqs160ohy19kbat8opzj3/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWF3YWlzIiwiYSI6ImNraGE2bHhkaDA5MDAydHJzMGMxZG1jeWkifQ.K_7JYzNOsuRLWyOhiw7EJQ",
                                        additionalOptions: {
                                          'accessToken': token,
                                          'id': 'mapbox.mapbox-streets-v8'
                                        }),
                                    MarkerClusterLayerOptions(
                                      maxClusterRadius: 120,
                                      size: Size(30, 30),
                                      fitBoundsOptions: FitBoundsOptions(
                                        padding: EdgeInsets.all(50),
                                      ),
                                      markers: allmarkers,
                                      polygonOptions: PolygonOptions(
                                          borderColor: Colors.blueAccent,
                                          color: Colors.black12,
                                          borderStrokeWidth: 3),
                                      builder: (context, markers) {
                                        return FloatingActionButton(
                                          child: Text(markers.length.toString()),
                                          onPressed: null,
                                        );
                                      },
                                    ),

                                  ],

                              );
                            })
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Column _bottomForSaleMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.home,
            color: Colors.black,
          ),
          title: Text('For Sale'),
          onTap: () {
            setState(() {
              adpost.purpose ="For Sale";
              ForSaleRentAds(adpost);
            });

            },
        ),
        ListTile(
          leading: Icon(
            Icons.home,
            color: Colors.green,
          ),
          title: Text('For Rent'),
          onTap: () {
            setState(() {
              adpost.purpose ="For Rent";
              ForSaleRentAds(adpost);
            });

          },
        ),
      ],
    );
  }

  Column _bottomPriceMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(
                "Set Price Range",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Form(
          autovalidate: _validate,
          key: formKeys[2],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 120,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'From'),
                  controller: priceFrom,
                  validator: validatePrice,
                ),
              ),
              Container(
                width: 120,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'To'),
                  controller: priceTo,
                  validator: validatePrice,
                ),
              ),
            ],
          ),
        ),
        RaisedButton(
          elevation: 5.0,
          padding: EdgeInsets.fromLTRB(40, 10, 40, 9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Colors.grey[600], width: 2.0)),
          onPressed: () {
            if (formKeys[2].currentState.validate()) {
              formKeys[2].currentState.save();
              adpost.priceFrom = priceFrom.text.toString();
              adpost.priceTo = priceTo.text.toString();
              ForPriceAds(adpost);

            } else {
              setState(() {
                _validate = true;
              });
            }
          },
          child: Text(
            'Set',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          color: Colors.grey[800],
        )
      ],
    );
  }

  Column _bottomRoomsMenu() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(
                "Rooms",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Form(
          autovalidate: _validate,
          key: formKeys[1],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 130,
                child: TextFormField(
                  validator: validatePrice,
                  controller: NoOfRoom,
                  decoration: InputDecoration(labelText: 'Rooms'),
                ),
              ),
              Container(
                width: 120,
                child: TextFormField(
                  validator: validatePrice,
                  controller: NoOfBath,
                  decoration: InputDecoration(labelText: 'Baths'),
                ),
              ),
            ],
          ),
        ),
        RaisedButton(
          elevation: 5.0,
          padding: EdgeInsets.fromLTRB(40, 10, 40, 9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Colors.grey[600], width: 2.0)),
          onPressed: () {
            if (formKeys[1].currentState.validate()) {
              formKeys[1].currentState.save();
              adpost.bathrooms = NoOfBath.text.toString();
              adpost.Rooms = NoOfRoom.text.toString();
              ForBedsBathAds(adpost);

            } else {
              setState(() {
                _validate = true;
              });
            }
          },
          child: Text(
            'Set',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          color: Colors.grey[800],
        )
      ],
    );
  }
}
