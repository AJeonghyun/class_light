import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivationController extends GetxController {
  var isactivate = true.obs;

  // Firestore의 'isactivate' 상태를 실시간으로 듣는 함수
  void listenToActivateState(String roomCode) {
    FirebaseFirestore.instance
        .collection('room')
        .doc(roomCode)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        isactivate.value = data['isactivate'] ?? false;
      }
    });
  }

  // Firestore의 'isactivate' 상태를 활성화하는 함수
  void activate(String roomCode) async {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomCode)
        .update({'isactivate': true});
    isactivate.value = true;
  }

  // Firestore의 'isactivate' 상태를 비활성화하는 함수
  void deactivate(String roomCode) async {
    await FirebaseFirestore.instance
        .collection('room')
        .doc(roomCode)
        .update({'isactivate': false});
    isactivate.value = false;
  }
}
