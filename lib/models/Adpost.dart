import 'package:cloud_firestore/cloud_firestore.dart';

class AdPost {
  String postId;
  String title;
      String desc;
  int price;
      String City;
  String AvailDays;
      String time;
  String unitArea;
      GeoPoint location;
      String Address;
  String purpose;
  String propertyType;
      String propertyDeatil;
  String buildyear;
      String Rooms;
  String ParkingSpace;
      String Floors;
      String bathrooms;
  String Kitchens;
  String Flooring;
      bool Elevators;
  bool MaintenanceStaff;
      bool Security;
  bool WasteDisposal;
  bool possesion;
      bool ParkingSpaces;
  bool corners;
      bool disputed;
  bool balloted;
      bool suiGas;
  bool waterSupply;
      bool sewarge;
  String propertySize;
      List ImageUrls;
      String priceFrom;
      String priceTo;


      AdPost({
        this.postId,
        this.title,
        this.desc,
        this.price,
        this.City,
        this.AvailDays,
        this.time,
        this.unitArea,
        this.location,
        this.Address,
        this.purpose,
        this.propertyType,
        this.propertyDeatil,
        this.buildyear,
        this.Rooms,
        this.ParkingSpace,
        this.Floors,
        this.bathrooms,
        this.Kitchens,
        this.Flooring,
        this.Elevators,
        this.MaintenanceStaff,
        this.Security,
        this.WasteDisposal,
        this.possesion,
        this.ParkingSpaces,
        this.corners,
        this.disputed,
        this.balloted,
        this.suiGas,
        this.waterSupply,
        this.sewarge,
        this.propertySize,
        this.ImageUrls,
        this.priceFrom,
        this.priceTo
      });


}
