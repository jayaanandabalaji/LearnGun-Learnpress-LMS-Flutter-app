import 'package:shared_preferences/shared_preferences.dart';

import '../../services/BaseAPI.dart';

GetToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString("token") != null) {
    return prefs.getString("token");
  } else {
    var token = await baseAPI().postAsync("token", {
      'username': prefs.getString('sensitive_user_meta_email'),
      'password': prefs.getString('sensitive_user_meta_password')
    })["token"];
    prefs.setString("token", token);
    return token;
  }
}
