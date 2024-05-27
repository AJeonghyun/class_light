import 'package:class_light/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserPageController extends GetxController {
  RxBool isactivate = false.obs;

  // Firestore의 'isactivate' 상태를 실시간으로 듣는 함수
  void listenToActivateState(String inputCode) {
    FirebaseFirestore.instance
        .collection('room')
        .doc(inputCode)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        isactivate.value = data['isactivate'] ?? false;
      }
    });
  }
}

class UserPage extends StatefulWidget {
  final String inputCode; // EnterPage로부터 전달받은 inputCode

  UserPage({Key? key, required this.inputCode}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserPageController userPageController = Get.put(UserPageController());
  String? userId; // 사용자 ID를 저장할 변수
  String? selectedLight; // 선택된 라이트를 저장할 변수
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUserId(); // initState에서 사용자 ID를 가져오는 함수 호출
    userPageController.listenToActivateState(widget.inputCode); // isactivate 상태 변경을 실시간으로 듣기
  }

  // 현재 로그인한 사용자의 ID를 가져오는 함수
  void getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user?.uid; // 사용자 ID를 상태 변수에 저장
    });
  }

  // Open popup window for input and save the value to Firebase
  void _openEditPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Write your question'),
          content: Container(
            width: 300, // Fix width to 300
            height: 200, // Set initial height to 200
            child: TextField(
              controller: _textFieldController,
              maxLines: null, // Allow multiline input
              decoration: InputDecoration(hintText: "Enter your question"),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save the input value to Firebase
                if (_textFieldController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('room')
                      .doc(widget.inputCode)
                      .update({
                    'question': FieldValue.arrayUnion([_textFieldController.text])
                  });
                  _textFieldController.text = '';
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('room').doc(widget.inputCode).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

            List<dynamic> questions = data['question'] ?? [];

            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: [
                          const Text(
                            'Now You are class is',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "\" ${data['lecture']}\"",
                            style: const TextStyle(
                                color: Color(0xff0029FF),
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'class',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(48),
                            border: Border.all(width: 3)),
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              //red Light
                              Obx(() => buildLightWidget(
                                lightType: 'redLight',
                                iconPath: 'assets/bad.png',
                                label: 'Bad',
                                isactivate: userPageController.isactivate.value,
                              )),
                              // yellow light
                              Obx(() => buildLightWidget(
                                lightType: 'yellowLight',
                                iconPath: 'assets/normal.png',
                                label: 'Hard to understand',
                                isactivate: userPageController.isactivate.value,
                              )),
                              // green light
                              Obx(() => buildLightWidget(
                                lightType: 'greenLight',
                                iconPath: 'assets/good.png',
                                label: 'Good',
                                isactivate: userPageController.isactivate.value,
                              )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(courseCode: widget.inputCode.toString())),
                      );
                    },
                    icon: const Icon(Icons.message),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () {
                      userPageController.isactivate.value?
                      _openEditPopup(context) : null; // Open popup on edit icon tap
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 30,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('room')
                        .doc(widget.inputCode)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      Map<String, dynamic> streamData =
                      snapshot.data!.data() as Map<String, dynamic>;

                      List<dynamic> questionList =
                          streamData['question'] ?? [];
                      int questionLength = questionList.length;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(6),
                        child: Text(
                          questionLength.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator()); // 로딩 중
        },
      ),
    );
  }

  Widget buildLightWidget({
    required String lightType,
    required String iconPath,
    required String label,
    required bool isactivate,
  }) {
    final isSelected = selectedLight == lightType;

    return Column(
      children: [
        InkWell(
          onTap: isactivate
              ? () async {
            final DocumentReference documentReference =
            FirebaseFirestore.instance.collection('room').doc(widget.inputCode);

            final DocumentSnapshot documentSnapshot =
            await documentReference.get();
            if (documentSnapshot.exists) {
              Map<String, dynamic> docData =
              documentSnapshot.data() as Map<String, dynamic>;

              final List<dynamic> lightList = docData[lightType] ?? [];
              if (lightList.contains(userId)) {
                documentReference.update({
                  lightType: FieldValue.arrayRemove([userId])
                });
                setState(() {
                  selectedLight = null;
                });
              } else {
                if (selectedLight != null) {
                  documentReference.update({
                    selectedLight!: FieldValue.arrayRemove([userId])
                  });
                }
                documentReference.update({
                  lightType: FieldValue.arrayUnion([userId])
                });
                setState(() {
                  selectedLight = lightType;
                });
              }
            }
          }
              : null, // isactivate가 false일 때 onTap을 null로 설정하여 비활성화
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: isSelected ? 4 : 0,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Image.asset(
              iconPath,
              width: 170,
              height: 170,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.blue : null, // 선택된 경우 파란색으로 변경
          ),
        ),
      ],
    );
  }
}
