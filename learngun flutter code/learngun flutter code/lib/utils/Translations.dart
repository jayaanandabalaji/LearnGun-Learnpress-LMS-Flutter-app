import 'package:get/get.dart';
import '../../utils/constants.dart';

class translations extends Translations {
  static Map<String, Map<String, String>> defaultTranslationArray = {};
  translations() {
    for (var language in Constants.translationSwitch) {
      defaultTranslationArray[language[1]] = {};
    }
  }

  @override
  Map<String, Map<String, String>> get keys => defaultTranslationArray;
}
