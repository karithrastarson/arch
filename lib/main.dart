import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Commons.dart';
import 'SearchPage.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initData();
  runApp(const MyApp());
}

initData() async {
  //Uncomment to add buildings programmatically

  /*
  var collectionRef = FirebaseFirestore.instance.collection('byggingar');
  //Add new item

  List<Map<String, dynamic>> buildings =
  [
    {
      "name": "Hlyngerði 8",
      "postal-code": "108",
      "created-date": "1974-76",
      "arkitekt-id": FirebaseFirestore.instance.doc("/arkitektar/1")
    }];

  var nextBuildingId = int.parse(await getNextBuildingId());
  for(var building in buildings) {
    var buildingName = building['name'].replaceAll(RegExp('\\s+'), '-');
    var buildingId = nextBuildingId.toString() + "-" + buildingName;
    FirebaseStorage.instance.ref().child(buildingId+"/meta").putString("meta");
    await collectionRef.doc(buildingId).set(building);
    nextBuildingId++;
  }

  var systemRef = FirebaseFirestore.instance.collection('system');
  await systemRef.doc('id-counters').update({'next-building-id': nextBuildingId});
  */
}

Future<String> getNextBuildingId() async {
  var collectionRef = FirebaseFirestore.instance.collection('system');
  var counters = collectionRef.doc('id-counters').get();
  var nextBuildingId = await counters.then((value) => value.data()!['next-building-id']);
  return nextBuildingId.toString();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkitektagáttin',
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            }),

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
            seedColor: Colors.amber),

        useMaterial3: true,
      ),
      home: const StartPage(title: 'Arkitektagáttin'),
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

              Container(
                margin: const EdgeInsets.all(20.0),
                child: const Text(
                  style: TextStyle(fontSize: 36),
                  'Veldu leitarmáta',
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                width: 300,
                height: 200,
                child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )
                      )
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                      const SearchPage(title: "Leita eftir arkitekt",
                          search: SearchType.architect)),
                    );
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 60),
                      Text('Leita eftir arkitekt',
                          style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
              ),
              Container(
                width: 300,
                height: 200,
                margin: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )
                      )
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                      const SearchPage(title: "Leita eftir byggingu",
                          search: SearchType.building)),
                    );
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.house, size: 60),
                      Text('Leita eftir byggingu',
                          style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
              ),
            ]
        ),
      ),

    );
  }
}


