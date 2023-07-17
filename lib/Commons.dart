//Entity classes
import 'package:cloud_firestore/cloud_firestore.dart';

class Architect {
  final String fullname;
  final String dob;
  final String profileUrl;
  final String architectId;
  final String uni;

  Architect(this.fullname, this.dob, this.profileUrl, this.uni, this.architectId);

  factory Architect.fromJson(Map<String, dynamic> json, String id) {
    return Architect(
        json['fullname'],
        json['dob'],
        json['profile-url'],
        json['uni'],
        id
    );
  }
}

class Building {
  final String name;
  final String createdDate;
  final String postalcode;
  final String buildingId;
  String profileUrl = "";
  DocumentReference<Map<String,dynamic>> architectReference;

  Building(this.name, this.createdDate, this.postalcode, this.buildingId, this.architectReference);

  factory Building.fromJson(Map<String, dynamic> json, String id)  {
    return Building(
        json['name'],
        json['created-date'],
        json['postal-code'],
        id,
        json['arkitekt-id']
    );
  }
}

enum SearchType {
  architect,
  building
}