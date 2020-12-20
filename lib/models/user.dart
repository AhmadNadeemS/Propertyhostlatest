import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OurUser{
  String uid;
  String email;

  Timestamp accountCreated;
  String displayName;
  String phoneNumber;
  String UserType;
  String image;


  OurUser({
    this.uid,
    this.email,
    this.accountCreated,
    this.displayName,
    this.phoneNumber,
    this.UserType,
    this.image,
  });

}
