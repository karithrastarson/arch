import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'ArchitectInfoPage.dart';
import 'BuildingInfoPage.dart';
import 'Commons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/* Search Page page */
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.title, required this.search});
  final String title;
  final SearchType search;

  @override
  State<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  List<Architect> architectResultList = [];
  List<Building> buildingResultList = [];

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    analytics = FirebaseAnalytics.instance;

    switch(widget.search) {
      case SearchType.architect:
        getAllArchitects();
        break;
      case SearchType.building:
        getTenBuildings();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
                onChanged: (text) {
                  if(text.length > 0) {
                    switch(widget.search) {
                      case SearchType.architect:
                        getArchitects(text);
                        break;
                      case SearchType.building:
                        getBuildings(text);
                        break;
                    }
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Sláðu inn leitarstreng',
                  hintStyle: TextStyle(
                      color: Colors.grey
                  ),
                )
            ),
            (() {
              if (widget.search == SearchType.architect) {
                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    children: architectResultList.map((data){
                      return ListTile(
                        onTap: () {
                          analytics.logEvent(name: "SearchArchitect", parameters: {"arkitekt": data!.fullname, "arkitektId": data!.architectId});
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ArchitectInfoPage(name: data.fullname,dob: data.dob,architectId:data.architectId)));
                        },
                        hoverColor: Theme.of(context).colorScheme.onPrimary,
                        leading: Icon(
                          Icons.north_east,
                          color: Colors.black,
                          size: 24.0,
                          semanticLabel: 'Text to announce in accessibility modes',
                        ),
                        title: Text(data.fullname!, textAlign:TextAlign.center,),
                        subtitle: Text(data.dob!, textAlign:TextAlign.center,),
                      );
                    }).toList(),
                  ),
                );
              } else {
                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    children: buildingResultList.map((data){
                      return ListTile(
                        onTap: () {
                          analytics.logEvent(name: "SearchBuilding", parameters: {"building": data.name, "buildingId": data.buildingId});
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BuildingInfoPage(building: data)));
                        },
                        hoverColor: Theme.of(context).colorScheme.onPrimary,
                        leading: Icon(
                          Icons.north_east,
                          color: Colors.black,
                          size: 24.0,
                          semanticLabel: 'Text to announce in accessibility modes',
                        ),
                        title: Text(data.name, textAlign:TextAlign.center,),
                        subtitle: Text(data.createdDate, textAlign:TextAlign.center,),
                      );
                    }).toList(),
                  ),
                );
              }
            }()),
            ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String?> getArchitects(String fullname) async {
    try {
      var db = FirebaseFirestore.instance;
      architectResultList.clear();

      await db.collection("arkitektar").get().then((event) {
        for (var arch in event.docs) {
          if (arch.data()["fullname"].toString().toLowerCase().contains(fullname.toLowerCase())){
            architectResultList.add(Architect.fromJson(arch.data(), arch.id));
          }

        }
        setState(() {
          architectResultList = architectResultList;
        });
      });

    } catch (e) {
      return e.toString();
    }
  }
  Future<String?> getAllArchitects() async {
    try {
      var db = FirebaseFirestore.instance;
      architectResultList.clear();

      await db.collection("arkitektar").get().then((event) {
        for (var arch in event.docs) {
            architectResultList.add(Architect.fromJson(arch.data(), arch.id));
        }
        setState(() {
          architectResultList = architectResultList;
        });
      });

    } catch (e) {
      return e.toString();
    }
  }
  Future<String?> getBuildings(String searchTerm) async {
    try {
      var db = FirebaseFirestore.instance;
      buildingResultList.clear();

      await db.collection("byggingar").get().then((event) {
        for (var building in event.docs) {
          if (building.data()["name"].toString().toLowerCase().contains(searchTerm.toLowerCase())){
            buildingResultList.add(Building.fromJson(building.data(), building.id));
          }

        }
        setState(() {
          buildingResultList = buildingResultList;
        });
      });

    } catch (e) {
      return e.toString();
    }
  }
  Future<String?> getTenBuildings() async {
    try {
      var db = FirebaseFirestore.instance;
      buildingResultList.clear();

      await db.collection("byggingar").get().then((event) {
        //First 10 results
        for (var building in event.docs.take(10)) {
          buildingResultList.add(Building.fromJson(building.data(), building.id));
        }
        setState(() {
          buildingResultList = buildingResultList;
        });
      });

    } catch (e) {
      return e.toString();
    }
  }
}
