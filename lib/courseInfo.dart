import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'course_code_page.dart';
import 'firebase_options.dart';



class courseInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Information',
      home: CourseForm(),
    );
  }
}

class CourseForm extends StatefulWidget {
  @override
  _CourseFormState createState() => _CourseFormState();
}

class _CourseFormState extends State<CourseForm> {
  final _formKey = GlobalKey<FormState>();
  String instructorName = '';
  String courseName = '';
  String semester = '';
  int courseCode = 0; // 코드 추가

  @override
  void initState() {
    super.initState();
    generateCode(); // 코드 생성 함수 호출
  }

  // 코드 생성 함수
  void generateCode() {
    setState(() {
      courseCode = (Random().nextInt(9000) + 1000); // 랜덤 코드 생성
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수업 정보 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '수업 정보',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Text(
                '강의자',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '강의자 이름을 입력하세요',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '강의자 이름을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  instructorName = value ?? '';
                },
              ),
              SizedBox(height: 16.0),
              Text(
                '수업 이름',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '수업 이름을 입력하세요',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '수업 이름을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  courseName = value ?? '';
                },
              ),
              SizedBox(height: 16.0),
              Text(
                '수강 학기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: '수강 학기를 입력하세요',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '수강 학기를 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  semester = value ?? '';
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        try {
                          await FirebaseFirestore.instance.collection('room').doc(courseCode.toString()).set({
                            'lecture': courseName,
                            'professor': instructorName,
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseCodePage(courseCode: courseCode),
                            ),
                          );
                        } catch (e) {
                          print('FirebaseException occurred: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xFF01FF02),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                    ),
                    child: Text('OK',style: TextStyle(color: Colors.black),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

