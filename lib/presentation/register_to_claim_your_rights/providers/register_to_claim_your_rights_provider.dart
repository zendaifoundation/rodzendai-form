import 'package:flutter/cupertino.dart';

class RegisterToClaimYourRightsProvider extends ChangeNotifier {
  RegisterToClaimYourRightsProvider() {
    _patientIdCardController.addListener(() {
      notifyListeners();
    });
  }
  final _patientIdCardController = TextEditingController();
  TextEditingController get patientIdCardController => _patientIdCardController;
}
