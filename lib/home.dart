import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  final String courseCode;

  HomePage({required this.courseCode});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int redLightCount = 0;
  int yellowLightCount = 0;
  int greenLightCount = 0;
  bool isLoading = true;
  String lecture = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('room')
          .doc(widget.courseCode)
          .get();

      if (document.exists) {
        setState(() {
          redLightCount = (document.data() as Map<String, dynamic>)['redLight'] != null
              ? (document['redLight'] as List).length
              : 0;
          yellowLightCount = (document.data() as Map<String, dynamic>)['yellowLight'] != null
              ? (document['yellowLight'] as List).length
              : 0;
          greenLightCount = (document.data() as Map<String, dynamic>)['greenLight'] != null
              ? (document['greenLight'] as List).length
              : 0;
          lecture = document['lecture'];
          isLoading = false;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = redLightCount + yellowLightCount + greenLightCount;
    double redPercentage = total > 0 ? (redLightCount / total) * 100 : 0;
    double yellowPercentage = total > 0 ? (yellowLightCount / total) * 100 : 0;
    double greenPercentage = total > 0 ? (greenLightCount / total) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(lecture),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            Row(
              children: <Widget>[
                buildLegend('Red', Colors.red, redPercentage),
                buildLegend('Yellow', Colors.yellow, yellowPercentage),
                buildLegend('Green', Colors.green, greenPercentage),
              ],
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 300.0,
                  height: 300.0,
                  child: Stack(
                    children: <Widget>[
                      buildCircle('Red', redLightCount, Colors.red, 0),
                      buildCircle('Yellow', yellowLightCount, Colors.yellow, 1),
                      buildCircle('Green', greenLightCount, Colors.green, 2),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLegend(String label, Color color, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: color,
            radius: 10,
          ),
          SizedBox(width: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildCircle(String label, int count, Color color, int index) {
    double size = 50.0 + count * 10.0;
    double offsetX = (index - 1) * 100.0;
    double offsetY = (index % 2 == 0) ? 0 : 50.0;

    return Positioned(
      left: 100 + offsetX,
      top: 100 + offsetY,
      child: CircleAvatar(
        backgroundColor: color,
        radius: size / 2,
        child: Center(
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
