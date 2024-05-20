import 'package:class_light/courseInfo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'enterPage.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 2),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const MyHomePage(title: 'Flutter Demo Home Page')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo1.png',
          width: 200, // 너비를 200으로 설정
          height: 200, // 높이를 200으로 설정
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/logo2.png',
              width: 200, // 너비를 200으로 설정
              height: 200, // 높이를 200으로 설정
            ),
            const SizedBox(height: 20,),
            const Text('What do you want to do about the class?'),
            const SizedBox(height: 50,),
            const Text('Do you have a class code?'),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnterPage()),
                );
              },
              child: Container(
                width: 300,
                height: 120,
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: const Center(
                  child: Text('Enter',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            const Text('Do you have a class code?'),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => courseInfoPage()),
                );
              },
              child: Container(
                width: 300,
                height: 120,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: const Center(
                  child: Text('Create',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
