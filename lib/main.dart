import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkitektagáttin',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightGreen),

        useMaterial3: true,
      ),
      home: const StartPage(title: 'Arkitektagáttin Demo'),
    );
  }
}
/* Start Page */
class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.title});

  final String title;

  @override
  State<StartPage> createState() => _StartPageState();
}
class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Text(
                'Veldu leitarmáta',
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        SearchPage(title: "Leit eftir arkitekt")),
                  );
                },
                child: const Text('Leit eftir arkitekt'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        SearchPage(title: "Leit eftir byggingu")),
                  );
                },
                child: const Text('Leit eftir byggingu'),
              ),
            ]
        ),
      ),
    );
  }
}

/* Search Page page */
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.title});
  final String title;

  @override
  State<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  List<Architect> resultList = [];

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
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             TextField(
              onChanged: (text) {
                if(text.length > 0) {
                  getArch(text);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Sláðu inn nafn',
                hintStyle: TextStyle(
                    color: Colors.grey
                ),
              )
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: resultList.map((data){
                  return ListTile(
                    onTap: () {
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
            )],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String?> getArch(String fullname) async {
    try {
      var db = FirebaseFirestore.instance;
      resultList.clear();

      await db.collection("arkitektar").get().then((event) {
        for (var arch in event.docs) {
          if (arch.data()["fullname"].toString().toLowerCase().contains(fullname.toLowerCase())){
            resultList.add(Architect.fromJson(arch.data(), arch.id));
          }

        }
        setState(() {
          resultList = resultList;
        });
      });

    } catch (e) {
    return e.toString();
  }}
}

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
    WidgetsBinding.instance.addPostFrameCallback((_){
      getBuildings(widget.architectId);
    });
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
      Expanded(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: buildings.map((data){
            return InkWell( onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuildingInfoPage(building: data)));
            },
            child:Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                Image.network(data.profileUrl),
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
      )
    ])

      ),
    );
  }
  void getBuildings(architectId) async {

    try {
      List<Building> buildingResults = [];
      var db = FirebaseFirestore.instance;
      await db.collection("byggingar").where('arkitekt-id',isEqualTo:FirebaseFirestore.instance.doc('arkitektar/'+architectId)).get().then((event) async {
        for (var building in event.docs) {
          var newBuilding = Building.fromJson(building.data(), building.id);

          var ref = FirebaseStorage.instance.ref().child(building.id + "/" +newBuilding.profileImageName);
          var url = await ref.getDownloadURL();
          print(url);
          newBuilding.profileUrl = url;
          buildingResults.add(newBuilding);
        }
      });
      setState(() {
        buildings = buildingResults;
      });
    } catch (e) {
      print(e.toString());
    }

  }
}

// Building Info Page
class BuildingInfoPage extends StatefulWidget {
  BuildingInfoPage({super.key, required this.building});
  final Building building;

  @override
  State<BuildingInfoPage> createState() => _BuildingInfoPageState();
}
class _BuildingInfoPageState extends State <BuildingInfoPage> {
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
                Image.network(widget.building.profileUrl)
              ])

      ),
    );
  }
}


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
      json['profile-url']
    );
  }
}

// Helper methods
Future<String> getDownloadUrl(String buildingId, String assetName) async {
  var imgLocation = buildingId + "/" + assetName;
  return await FirebaseStorage.instance
      .ref()
      .child(imgLocation)
      .getDownloadURL();
}