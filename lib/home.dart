import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup/MainScreenUsers.dart';
import 'package:signup/login.dart';
import 'package:signup/main_screen.dart';
import 'package:signup/signup.dart';

import 'helper/helperfunctions.dart';

class RoleCheck extends StatefulWidget {
  @override
  _RoleCheckState createState() => _RoleCheckState();
}

class _RoleCheckState extends State<RoleCheck> {
  //RoleCheck(this.isAdmin);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //bool isAgent = false;

//  Future<String> currentUser() async {
//    user = await _auth.currentUser();
//    return user != null ? user.uid : null;
//  }

  FirebaseUser user;

  @override
  void initState() {
    super.initState();

    initUser();
  }

  String userid;
  initUser() async {
    user = await _auth.currentUser();
    //Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    setState(() {});
  }
//
//  initUser() async {
//    user = await _auth.currentUser();
//    if (user != null) {
//      userid = user.uid;
//   //   print(widget.isAgent);
//    } else {
//      print("user.uid");
//      // User is not available. Do something else
//    }
//    setState(() {
//
//    });
//  }
  @override
  Widget build(BuildContext context) {
    return user != null ? Scaffold(
//        appBar: AppBar(title: Text('Home ${user.email}'),),

      body : StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
              // ignore: missing_return
              builder: (BuildContext context,AsyncSnapshot<DocumentSnapshot> snapshot) {

                if(snapshot.hasError )
                  return Center(child: Text("Something went wrong  please come back later"),);

                switch(snapshot.connectionState){
                  case ConnectionState.none:
                    return Center(child:Text("Please check your internet"));
                    break;
                  case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator(),);
                        break;
                  default:
                            HelperFunctions.saveUserLoggedInSharedPreference(true);
                            HelperFunctions.saveUserNameSharedPreference(snapshot.data["displayName"]);

                        /*    HelperFunctions.saveUserEmailSharedPreference(
                                snapshot.data["email"]);*/
                            HelperFunctions.saveUserPhoneNoSharedPreference(
                                snapshot.data["phoneNumber"]);
                            return _checkRole(snapshot.data);
                            break;
                                            //: Text('No Data');
                }

              })
    ):LoginPage();
  }

  _checkRole(DocumentSnapshot snapshot) {
    if (snapshot.data['User Type'] == 'Agent') {
      //isAdmin =true;
     // print('agent');
      //MainScreen(isAdmin: true,);
      return MainScreen(
        isAgent: true,
      );
      //return MainScreen(isAdmin);

    } else {
      //isAdmin= false;
     // print('other');
      //return MainScreen();
      return MainScreen(
        isAgent: false,
      );
    }
  }
}
