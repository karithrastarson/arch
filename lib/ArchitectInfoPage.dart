import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'BuildingInfoPage.dart';
import 'Commons.dart';

// Architect Info Page
class ArchitectInfoPage extends StatefulWidget {
  ArchitectInfoPage({super.key, required this.name, required this.dob, required this.architectId});
  final String name;
  final String dob;
  final String architectId;


  @override
  State<ArchitectInfoPage> createState() => _ArchitectInfoPageState();
}
class _ArchitectInfoPageState extends State<ArchitectInfoPage> {
  List<Building> buildings = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.name),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(widget.name),
                Text(widget.dob),
                FutureBuilder<List<Building>>(
                  future: getBuildings(widget.architectId), // async work
                  builder: (BuildContext context, AsyncSnapshot<List<Building>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting: return Text('Loading....');
                      default:
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else {
                          if (snapshot.data!.length == 0){
                            return Text('Engin gögn fundust. Ef þú vilt bæta við gögnum um þennan arkitekt, sendu okkur tölvupóst á karithrastarson@gmail.com', textAlign: TextAlign.center);
                          } else {
                            return Expanded(
                              child: Container(
                                width:600,
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(20.0),
                                  children: snapshot.data!.map((data){
                                    return InkWell( onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => BuildingInfoPage(building: data)));
                                    },
                                        child:Stack(
                                          alignment: AlignmentDirectional.bottomEnd,
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.center,
                                              child: CachedNetworkImage(
                                                imageUrl: data.profileUrl,
                                                imageBuilder: (context, imageProvider) => Image.network(data.profileUrl),
                                                placeholder: (context, url) => CircularProgressIndicator(),
                                                errorWidget: (context, url, error) => Image(image: AssetImage('assets/placeholder.jpeg')),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.white,
                                              child: Text(
                                                  data.name,
                                                  textAlign:TextAlign.center),
                                            )
                                          ],
                                        ));
                                  }).toList(),
                                ),
                              ),
                            );}
                        }
                    }
                  },
                ),
              ])

      ),
    );
  }
  Future<List<Building>> getBuildings(String architectId) async {
    List<Building> buildingResults = [];
    try {
      var db = FirebaseFirestore.instance;
      await db.collection("byggingar").where('arkitekt-id',isEqualTo:FirebaseFirestore.instance.doc('arkitektar/'+architectId)).get().then((event) async {
        for (var building in event.docs) {
          var newBuilding = Building.fromJson(building.data(), building.id);

          if (newBuilding.profileImageName != ""){
            var ref = FirebaseStorage.instance.ref().child(building.id + "/" +newBuilding.profileImageName);
            var url = await ref.getDownloadURL();
            newBuilding.profileUrl = url;
          }

          buildingResults.add(newBuilding);
        }
      });

    } catch (e) {
      print(e.toString());
    }
    return buildingResults;
  }
}

