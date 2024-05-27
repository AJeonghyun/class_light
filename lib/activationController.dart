import 'package:get/get.dart';

class ActivationController extends GetxController {
  var isactivate = true.obs;

  void activate() {
    isactivate.value = true;
  }

  void deactivate() {
    isactivate.value = false;
  }
}
