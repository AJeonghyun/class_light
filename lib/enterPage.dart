import 'package:class_light/userPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class EnterPage extends StatefulWidget {
  const EnterPage({super.key});

  @override
  State<EnterPage> createState() => _EnterPageState();
}

class _EnterPageState extends State<EnterPage> {
  String inputCode = ''; // 사용자가 입력한 숫자를 저장할 변수
  // 숫자를 추가하는 함수
  void addNumber(String number) {
    if (inputCode.length < 4) {
      // 숫자가 4자리 미만일 때만 추가
      setState(() {
        inputCode += number;
      });
    }
  }

  // 마지막 숫자를 지우는 함수
  void deleteLastNumber() {
    if (inputCode.isNotEmpty) {
      // 입력한 숫자가 있을 때만 작동
      setState(() {
        inputCode = inputCode.substring(0, inputCode.length - 1);
      });
    }
  }

  // OK 버튼을 눌렀을 때 호출되는 함수
  void checkDocumentInFirestore() async {
    // Firestore 인스턴스 생성
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // 특정 ID를 가진 문서 조회
      var documentSnapshot =
      await firestore.collection('room').doc(inputCode).get();

      // 문서가 존재하는지 확인
      if (documentSnapshot.exists) {
        // 문서가 존재하면 실행할 로직, 예를 들어 성공 메시지 표시
        print("문서가 존재합니다: $inputCode");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EnterPage2(inputCode: inputCode)));
      } else {
        // 문서가 존재하지 않으면 실행할 로직, 예를 들어 오류 메시지 표시
        print("문서가 존재하지 않습니다: $inputCode");
        _showSnackBar();
      }
    } catch (e) {
      // 오류 처리, 예를 들어 오류 메시지 표시
      print("에러 발생: $e");
    }
  }

  void _showSnackBar() {
    final snackBar = SnackBar(
      content: const Text('The room with the given code does not exist.'),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // SnackBar의 "Close" 버튼을 누르면 할 행동
        },
      ),
    );

    // SnackBar 표시
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 200),
          const Text(
            '수강할 수업의 코드를 입력해주세요',
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // 입력된 코드를 보여주는 부분
          Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              color: inputCode.length > 0
                  ? const Color(0xffFFF002)
                  : null, // 조건에 따른 색상 적용
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              // 텍스트를 중앙에 배치하기 위해 Center 위젯 추가
              child: Text(
                inputCode.padRight(4, ' • '), // 입력하지 않은 자리는 점으로 표시
                style:
                const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),
          // OK 버튼, 4자리 숫자가 모두 입력되었을 때만 보임
          if (inputCode.length == 4)
            ElevatedButton(
              onPressed: () {
                checkDocumentInFirestore();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all(const Color(0xFF00FF47)),
              ),
            ),

          const SizedBox(height: 20),

          // 숫자 키패드
          Wrap(
            children: <Widget>[
              // 1부터 9까지의 숫자 버튼 생성
              for (int i = 1; i < 10; i++)
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 100,
                  child: InkWell(
                    onTap: () => addNumber(i.toString()), // 사용자 탭 이벤트 처리
                    child: Center(
                      child: Text(
                        i.toString(),
                        style: const TextStyle(fontSize: 25), // 글꼴 크기 설정
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
              ),
              // 0번 숫자 버튼
              Container(
                width: MediaQuery.of(context).size.width / 3,
                height: 100,
                child: InkWell(
                  onTap: () => addNumber('0'), // 사용자 탭 이벤트 처리
                  child: const Center(
                    child: Text(
                      '0',
                      style: TextStyle(fontSize: 25), // 글꼴 크기 설정
                    ),
                  ),
                ),
              ),
              // 지우기 버튼
              Container(
                width: MediaQuery.of(context).size.width / 3,
                height: 100,
                child: InkWell(
                  onTap: deleteLastNumber, // 사용자 탭 이벤트 처리
                  child: const Center(
                    child: Icon(
                      Icons.backspace,
                      size: 25, // 아이콘 크기 설정
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EnterPage2 extends StatelessWidget {
  final String inputCode; // EnterPage로부터 전달받을 inputCode

  // 생성자에서 inputCode를 받습니다.
  const EnterPage2({Key? key, required this.inputCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Firestore 인스턴스 생성
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('room').doc(inputCode).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  const Text(
                    'Your class is',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "\" ${data['lecture']}\"",
                    style: const TextStyle(
                        color: Color(0xff83BCFF),
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  InkWell(
                    onTap: () async {
                      // Firebase 익명 로그인
                      try {
                        final userCredential =
                        await FirebaseAuth.instance.signInAnonymously();
                        print("Signed in with temporary account.");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserPage(
                                  inputCode: inputCode,
                                )));
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case "operation-not-allowed":
                            print(
                                "Anonymous auth hasn't been enabled for this project.");
                            break;
                          default:
                            print("Unknown error.");
                        }
                      }
                    },
                    child: Container(
                      width: 300,
                      height: 120,
                      decoration: BoxDecoration(
                          color: Color(0xff00FF47),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                        child: Text(
                          'Activate',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      // 현재 페이지에서 나가기
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 300,
                      height: 120,
                      decoration: BoxDecoration(
                          color: Color(0xffC4C4C4),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                        child: Text(
                          'Deactivate',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator()); // 로딩 중
        },
      ),
    );
  }
}