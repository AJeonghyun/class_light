import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'home.dart';


class CourseCodePage extends StatelessWidget {
  final int courseCode;

  CourseCodePage({required this.courseCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('수업 코드 생성'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF671),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: courseCode.toString().split('').map((char) {
                      return Text(
                        char,
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: courseCode.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('코드가 클립보드에 복사되었습니다')),
                    );
                  },
                  child: Text('복사'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Share.share('수업 코드: ${courseCode.toString()}');
                  },
                  child: Text('공유'),
                ),
              ],
            ),
            SizedBox(height: 32.0), // 공백 추가
            ElevatedButton( // 확인 버튼 추가
              onPressed: () {
                // 새로운 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF01FF02), // 확인 버튼 색상 설정
              ),
              child: Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
