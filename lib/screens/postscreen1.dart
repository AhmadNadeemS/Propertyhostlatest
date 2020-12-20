
import 'package:cloud_firestore_platform_interface/src/geo_point.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:signup/models/Adpost.dart';
import 'package:signup/screens/postscreen2.dart';
import '../AppLogic/validation.dart';
import 'package:signup/choseOnMap.dart';



class PostFirstScreen extends StatefulWidget {

  @override
  _PostFirstScreenState createState() => _PostFirstScreenState();


}


class _PostFirstScreenState extends State<PostFirstScreen>{





// Controllers of text fields


  TextEditingController titleController = new TextEditingController();
  TextEditingController descController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();

  TextEditingController MetTimeController = new TextEditingController();
  TextEditingController AvailDays = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController propertySize = new TextEditingController();

  // ends here

  String _selectedUnitArea;

  List<String> _UnitArea =[
    'Marla',
    'Canal'
  ];


  String title; String desc; int price;String location; String purpose;

  String description;

  String dropdownTo;
  String dropdownFrom;
  String dropdownCondition;
  String _selectedPurpose;
  GeoPoint CordFromMap;


  List<String> _purpose = ['For Sale', 'For Rent'];




  GlobalKey<FormState> _key = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _validate = false;
  AdPost adpost = new AdPost();

  @override
  void initState(){

    super.initState();
  }


  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(content: new Text(value)));

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(

    child:Scaffold(
      key: _scaffoldKey,
//      backgroundColor: Colors.grey[600],
      body: Container(
//        decoration: BoxDecoration(
//          image: DecorationImage(
//            image: AssetImage("assets/background.png"),
//            fit: BoxFit.cover,
//          ),
//        ),
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Center(
                child: Text(
                  "Post New Ad",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              AddPost(context),

              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
              ),
            ], //:TODO: implement upload pictures
          ),
        ),
      ),
    ));
  }

  Widget AddPost(BuildContext context) {
    return Form(
      key: _key,
      autovalidate: _validate,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: Column(
            children: <Widget>[
              TextFormField(
                controller: titleController,
                keyboardType: TextInputType.text,
                validator: validateTitle,
                onSaved: (String val) {
                  title = val;
                },
                maxLines: 1,
                autofocus: false,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.title,
                      color: Color(0xff2470c7),
                    ),
                  //  hintText: widget.adPost.title,
                    labelText: 'Title'),
              ),
              TextFormField(
                controller: descController,
                keyboardType: TextInputType.text,
                validator: ValidateDescp,
                onSaved: (String val) {
                  description = val;
                },
                maxLines: 2,
                autofocus: false,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.description,
                      color: Color(0xff2470c7),
                    ),
                    labelText: 'Description'),
                //textAlign: TextAlign,
              ),
              TextFormField(
                controller:priceController,
                keyboardType: TextInputType.number,
                autofocus: false,
                validator: validatePrice,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Color(0xff2470c7),
                    ),
                    labelText: 'Price'),
              ),
              TextFormField(
                controller: cityController,
                keyboardType: TextInputType.text,
                validator: ValidateDescp,
                onSaved: (String val) {
                  description = val;
                },
                maxLines: 2,
                autofocus: false,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.location_city,
                      color: Color(0xff2470c7),
                    ),
                    labelText: 'City'),
                //textAlign: TextAlign,
              ),
              TextFormField(
                controller: addressController,
                keyboardType: TextInputType.text,
                validator: ValidateLocation,
                onSaved: (String val) {
                  description = val;
                },
                maxLines: 1,
                //autofocus: true,
                decoration: InputDecoration(
                    prefixIcon: Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.pin_drop,
                        color: Color(0xff2470c7),
                      ),
                    ),
                    labelText: 'Enter Address ! Example: G-10/1 Islamabad ,'),

              ),
              _showonMap(context),
              _getPurposeDropDown(),
              _UnitAreaDropDown(),
              _propertySize(),
              _selectMeetingTime(),


              RaisedButton(
                child: Text("Next"),
                onPressed: () {
                  Navigator.push(
                      this.context, MaterialPageRoute(builder: (context) {
                    return PostSecondScreen(adpost);
                  }));

             /*     if(_key.currentState.validate()) {
                    _key.currentState.save();

                    if (CordFromMap != null) {
                      adpost.title = titleController.text;
                      adpost.desc = descController.text;
                      adpost.price = int.parse(priceController.text);
                      adpost.City = cityController.text;
                      adpost.Address = addressController.text;
                      adpost.purpose = _selectedPurpose;
                      adpost.unitArea = _selectedUnitArea;
                      adpost.AvailDays = AvailDays.text;
                      adpost.time = MetTimeController.text;
                      adpost.propertySize = propertySize.text;
                      adpost.location = CordFromMap;


                      Navigator.push(
                          this.context, MaterialPageRoute(builder: (context) {
                        return PostSecondScreen(adpost);
                      }));
                    } else{
                    showInSnackBar("Please choose your location");
                    }
                  }

                 else{

                    setState(() {
                      _validate = true;
                    });
                  }*/

//                      setState(() {
//                        isButtonPressed7 = !isButtonPressed7;
//                      });
                },
                textColor: Colors.black,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                splashColor: Colors.grey,
              ),
            ]

        ),
      ),
    );
  }


  Widget _UnitAreaDropDown() {
    return Row(
      children: <Widget>[
        //Icon(Icons.map, color: Colors.grey),
        Container(

        ),
        Flexible(

          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  prefixIcon: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.ac_unit,
                      color: Color(0xff2470c7),
                    ),
                  ),
                  labelText: 'Unit Area'),
              value: _selectedUnitArea,
              onChanged: (newValue) {
                setState(() {
                  _selectedUnitArea = newValue;
                  //                _selectedPropertyTypeData = _getCities().first;
                });
              },
              items: _UnitArea.map((unitarea) {
                return DropdownMenuItem(
                  child: Text(unitarea),
                  value: unitarea,
                );
              }).toList(),
              validator: (value) =>
              value == null ? 'Please select a Unit Area' : null,
            ),
          ),
        ),
      ],
    );
  }


  Widget _selectMeetingTime() {
    return Container(
      //constraints: BoxConstraints(maxWidth: 250),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(right: 10, top: 15),
                  child: Text(
                    'Available Days:',
                    style: TextStyle(fontSize: 15),
                  )),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    child: Container(
                      width: 200,
                      child: TextFormField(
                        controller:AvailDays ,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        //autofocus: true,

                        decoration: InputDecoration(

                            labelText: 'Monday-Wednesday ,'),

                        validator: (value) =>
                        value.isEmpty ? 'Field can\'t be empty' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),


          Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(right: 10, top: 15),
                  child: Text(
                    'Mention Time :',
                    style: TextStyle(fontSize: 15),
                  )),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                    child: Container(
                      width: 200,
                      child: TextFormField(
                        controller: MetTimeController,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        //autofocus: true,

                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.access_time,
                              color: Color(0xff2470c7),
                            ),
                            labelText: '1-3 pm ,'),

                        validator: (value) =>
                        value.isEmpty ? 'Time Field can\'t be empty' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _propertySize() {
    return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: Container(
                      child: TextFormField(
                        controller:propertySize ,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        validator: validatePropertySize,
                        //autofocus: true,

                        decoration: InputDecoration(
                            prefixIcon: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Icon(
                                    Icons.mode_edit,
                                    color: Color(0xff2470c7),
                                    ),
                                    ),

                            labelText: 'Enter property size'),
                      ),
                    ),
                  ),
                ],
          );
  }


  Widget _showonMap(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15, left: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: RaisedButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.map,
                color: Colors.white,
                textDirection: TextDirection.ltr,
              ),
              label: FlatButton(
                onPressed: () {
                  _navigateAndDisplaySelection(context);


                },
                child: Text(
                  'Select Area on Map',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    CordFromMap = await Navigator.push(context, MaterialPageRoute(builder: (context) => ChoseOnMap()),);
    print("${CordFromMap} "+" got result from map screen");
  }

  Widget _getPurposeDropDown() {
    return Row(
      children: <Widget>[
        //Icon(Icons.map, color: Colors.grey),
        Container(
          //margin: EdgeInsets.only(left: 5,),
          //width: 7.0,
        ),
        Flexible(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                  prefixIcon: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.home,
                      color: Color(0xff2470c7),
                    ),
                  ),
                  labelText: 'Select Purpose'),
              value: _selectedPurpose,
              onChanged: (newValue) {
                setState(() {
                  _selectedPurpose = newValue;
                  //                _selectedPropertyTypeData = _getCities().first;
                });
              },
              items: _purpose.map((purpose) {
                return DropdownMenuItem(
                  child: Text(purpose),
                  value: purpose,
                );
              }).toList(),

              validator: (value) =>
              value == null ? 'Please select a purpose' : null,
            ),
          ),
        ),
      ],

      );

  }



}