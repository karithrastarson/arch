import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  @override
  void initState() {
    super.initState();
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
                      Text("Byggingarár:" + widget.building.createdDate)
                      ]
                ),
                Flexible(
                    child: Container(
                      width:600,
                      child: FutureBuilder<List<String>>(
                  future: getImageAssets(), // async work
                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting: return Text('Loading....');
                        default:
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else {
                            if(snapshot.data!.length == 0)
                              return Text('Engin gögn fundust. Ef þú vilt bæta við gögnum um þessa byggingu, sendu okkur tölvupóst á karithrastarson@gmail.com');
                            return ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(20.0),
                              children: snapshot.data!.map((data){
                                return Image.network(data);
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
}