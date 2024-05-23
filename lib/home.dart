import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget {
  final String courseCode;

  HomePage({required this.courseCode});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String lecture = '';
  int questionCount = 0;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('room')
          .doc(widget.courseCode)
          .get();

      if (document.exists) {
        var data = document.data() as Map<String, dynamic>?;

        setState(() {
          lecture = data?['lecture'] ?? '';
          questionCount = data?['question'] != null ? (data!['question'] as List).length : 0;
          isLoading = false;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  void _showQuestionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('room')
              .doc(widget.courseCode)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Error: ${snapshot.error}'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
            if (!snapshot.hasData) {
              return AlertDialog(
                title: Text('Loading'),
                content: CircularProgressIndicator(),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }

            var data = snapshot.data?.data() as Map<String, dynamic>?;
            List<String> questions = data?['question'] != null ? List<String>.from(data!['question']) : [];

            return AlertDialog(
              title: Text('Questions'),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: questions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(questions[index]),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lecture),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('room')
            .doc(widget.courseCode)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data?.data() as Map<String, dynamic>?;
          int redLightCount = data?['redLight'] != null ? (data!['redLight'] as List).length : 0;
          int yellowLightCount = data?['yellowLight'] != null ? (data!['yellowLight'] as List).length : 0;
          int greenLightCount = data?['greenLight'] != null ? (data!['greenLight'] as List).length : 0;
          questionCount = data?['question'] != null ? (data!['question'] as List).length : 0;

          int total = redLightCount + yellowLightCount + greenLightCount;
          double redPercentage = total > 0 ? (redLightCount / total) * 100 : 0;
          double yellowPercentage = total > 0 ? (yellowLightCount / total) * 100 : 0;
          double greenPercentage = total > 0 ? (greenLightCount / total) * 100 : 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                badges.Badge(
                  showBadge: questionCount > 0,
                  badgeContent: Text(
                    '$questionCount',
                    style: TextStyle(color: Colors.white),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.message),
                    onPressed: _showQuestionsDialog,
                  ),
                ),
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
                      width: 600.0,
                      height: 600.0,
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
          );
        },
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
