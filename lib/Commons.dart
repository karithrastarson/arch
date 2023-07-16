//Entity classes
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
  final String profileImageName;
  String profileUrl = "";

  Building(this.name, this.createdDate, this.postalcode, this.buildingId, this.profileImageName);

  factory Building.fromJson(Map<String, dynamic> json, String id)  {
    return Building(
        json['name'],
        json['created-date'],
        json['postal-code'],
        id,
        json['profile-url'] ?? ""
    );
  }
}

enum SearchType {
  architect,
  building
}