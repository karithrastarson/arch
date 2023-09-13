import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'ArchitectInfoPage.dart';
import 'Commons.dart';

// Building Info Page
class BuildingInfoPage extends StatefulWidget {
  BuildingInfoPage({super.key, required this.building});
  final Building building;

  @override
  State<BuildingInfoPage> createState() => _BuildingInfoPageState();
}
class _BuildingInfoPageState extends State <BuildingInfoPage> {
  List<String> images = [];

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    analytics = FirebaseAnalytics.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.building.name),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      Text(widget.building.name),
                      Text("Byggingarár:" + widget.building.createdDate),
                      FutureBuilder<Architect?>(
                        future: getArchitect(widget.building.architectReference), // async work
                        builder: (BuildContext context, AsyncSnapshot<Architect?> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting: return const Column(
                              children: [
                                CircularProgressIndicator(),
                                Text("Sæki gögn")
                              ],
                            );
                            default:
                              if (snapshot.hasError)
                                return Text('Error: ${snapshot.error}');
                              else {
                                if(snapshot.data == null)
                                  return const Text('Arkitektinn fannst ekki');
                                return
                                InkWell(
                                  child: Text(
                                    'Arkitekt:' + snapshot.data!.fullname
                                ),
                                  onTap: () {
                                    analytics.logEvent(name: "SearchArchitect", parameters: {"arkitekt": snapshot.data!.fullname, "arkitektId": snapshot.data!.architectId});
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ArchitectInfoPage(name: snapshot.data!.fullname,dob: snapshot.data!.dob,architectId:snapshot.data!.architectId)));
                                  },
                                  );
                              }
                          }
                        },
                      )
                      ]
                ),
                Flexible(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 1200),
                      child: FutureBuilder<List<String>>(
                  future: getImageAssets(), // async work
                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting: return const Column(
                          children: [
                            CircularProgressIndicator(),
                            Text('Sæki gögn')
                          ],
                        );
                        default:
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else {
                            if(snapshot.data!.length == 0)
                              return const Text('Engin gögn fundust. Ef þú vilt bæta við gögnum um þessa byggingu, sendu okkur tölvupóst á karithrastarson@gmail.com');
                            return ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(20.0),
                              children: snapshot.data!.map((data){
                                return InteractiveViewer(
                                    clipBehavior: Clip.none,
                                    child: Image.network(data));
                              }).toList(),
                            );
                          }
                      }
                  },
                ),
                    ))
              ])
      ),
    );
  }

  Future<List<String>> getImageAssets() async {
    List<String> urls = [];
    try {
      var result =
      await FirebaseStorage.instance.ref().child(widget.building.buildingId).listAll();
      for(var ref in result.items) {
        var url = await ref.getDownloadURL();
        urls.add(url);
      }
    }  catch (e) {
      print(e);
    }
    return urls;
  }

  Future<Architect?> getArchitect(var architectReference) async {
    //Fetch architect by id
    try {
      var result = await architectReference.get();
      return Architect.fromJson(result.data(), result.id);
    }  catch (e) {
      print(e);
      return null;
    }
  }
}