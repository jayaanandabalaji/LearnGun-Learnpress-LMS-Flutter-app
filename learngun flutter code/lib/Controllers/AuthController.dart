import 'package:LearnGun/services/CoursesAPI.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/apple_id_credential.dart';
import '../services/LoginAPI.dart';
import '../services/SharedPrefs.dart';
import '../services/RegisterAPI.dart';
import '../widgets/BottomNav.dart';
import 'HomeController.dart';

class AuthController extends GetxController {
  final HomeController _homeController = Get.put(HomeController());

  facebookAuth(var userData) async {
    if (userData != null) {
      var jsonResponse = await LoginApi.SocialAuth(
          userData["email"], userData["id"].toString(), "Facebook");
      prefs.setString("token", jsonResponse['token']);
      prefs.setString('user_info_id', jsonResponse['user_id']);
      prefs.setString(
          'sensitive_user_meta_username', jsonResponse['user_login']);
      prefs.setString('sensitive_user_meta_email', jsonResponse['user_email']);
      prefs.setString(
          'sensitive_user_meta_password', jsonResponse['user_display_name']);
      Get.off(() => BottomNav());
      _homeController.isLoggedIn.value = true;
      _homeController.courseslist.value = await CoursesApi().GetCourses({});
      return null;
    }
  }

  AppleAuth(AppleIdCredential? credential) async {
    if (credential != null) {
      var jsonResponse = await LoginApi.SocialAuth(credential.email ?? "",
          credential.fullName?.givenName ?? "", "Apple");
      prefs.setString("token", jsonResponse['token']);
      prefs.setString('user_info_id', jsonResponse['user_id']);
      prefs.setString(
          'sensitive_user_meta_username', jsonResponse['user_login']);
      prefs.setString('sensitive_user_meta_email', jsonResponse['user_email']);
      prefs.setString(
          'sensitive_user_meta_password', jsonResponse['user_display_name']);
      Get.off(() => BottomNav());
      _homeController.isLoggedIn.value = true;
      _homeController.courseslist.value = await CoursesApi().GetCourses({});
      return null;
    }
  }

  GoogleAuth(GoogleSignInAccount googlesigninaccount) async {
    var jsonResponse = await LoginApi.SocialAuth(
        googlesigninaccount.email, googlesigninaccount.id, "Google");
    prefs.setString("token", jsonResponse['token']);
    prefs.setString('user_info_id', jsonResponse['user_id']);
    prefs.setString(
        'sensitive_user_meta_username', jsonResponse['user_login']);
    prefs.setString('sensitive_user_meta_email', jsonResponse['user_email']);
    prefs.setString('sensitive_user_meta_password', googlesigninaccount.id);
    Get.off(() => BottomNav());
    _homeController.isLoggedIn.value = true;
    _homeController.courseslist.value = await CoursesApi().GetCourses({});
    return null;
  }

  signup(String name, String password, String email) async {
    var jsonResponse =
        await RegisterApi().RegisterByDefault(name, password, email);
    try {
      prefs.setString("token", jsonResponse['token']);
      prefs.setString('user_info_id', jsonResponse['user_id']);
      prefs.setString('sensitive_user_meta_username', name);
      prefs.setString('sensitive_user_meta_email', email);
      prefs.setString('sensitive_user_meta_password', password);
      Get.off(() => BottomNav());
    } finally {
      _homeController.isLoggedIn.value = true;
      _homeController.courseslist.value = await CoursesApi().GetCourses({});
      return null;
    }
  }

  Signin(String name, String password) async {
    var jsonResponse = await LoginApi.LoginByDefault(name, password);
    try {
      prefs.setString('user_info_id', jsonResponse['user_id']);
      prefs.setString(
          'sensitive_user_meta_username', jsonResponse['user_login']);
      prefs.setString('sensitive_user_meta_email', name);
      prefs.setString("token", jsonResponse["token"]);
      prefs.setString('sensitive_user_meta_password', password);
      Get.off(() => BottomNav());
    } finally {
      _homeController.isLoggedIn.value = true;
      _homeController.courseslist.value = await CoursesApi().GetCourses({});
      return null;
    }
  }
}
