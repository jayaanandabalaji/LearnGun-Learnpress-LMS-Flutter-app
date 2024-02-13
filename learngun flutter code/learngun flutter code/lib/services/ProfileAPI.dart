import 'dart:io';

import '../../services/SharedPrefs.dart';
import '../../Models/Profile.dart';
import '../../Models/Instructor.dart';
import 'BaseAPI.dart';

class ProfileApi {
  static GetProfile() async {
    var response = await baseAPI().getAsync(
        "users/" + await prefs.getString('user_info_id'),
        data: {"requirestoken": "true"});
    return Profile.fromJson(response);
  }

  static DeleteAccount() async {
    var userId = await prefs.getString("user_info_id");
    var response = await baseAPI().postAsync(
        "learnpressapp/v1/delete-account", {"user_id": userId},
        requires_license: true, customUrl: true);
    return response;
  }

  static get_instructors() async {
    var response = await baseAPI().getAsync("users?who=authors");
    return response.map((value) => Instructor.fromJson(value)).toList();
  }

  static edit_profile(
      File file,
      String firstName,
      String lastName,
      String displayName,
      String bio,
      String facebook,
      String youtube,
      String linkedin,
      String twitter) async {
    var response;
    if (file.path != "") {
      response = await baseAPI().postAsync(
          "learnpressapp/v1/user/edit-profile",
          {
            "requirestoken": "true",
            "file": {"avatar": file},
            "first_name": firstName,
            "last_name": lastName,
            "display_name": displayName,
            "description": bio,
            "facebook": facebook,
            "youtube": youtube,
            "linkedin": linkedin,
            "twitter": twitter
          },
          customUrl: true);
    } else {
      response = await baseAPI().postAsync(
          "learnpressapp/v1/user/edit-profile",
          {
            "requirestoken": "true",
            "first_name": firstName,
            "last_name": lastName,
            "display_name": displayName,
            "description": bio,
            "facebook": facebook,
            "youtube": youtube,
            "linkedin": linkedin,
            "twitter": twitter
          },
          customUrl: true);
    }
    return response;
  }

  static change_password(String oldPass, String newPass) async {
    var response = await baseAPI().postAsync(
        "learnpressapp/v1/user/change-password",
        {
          "old_password": oldPass,
          "new_password": newPass,
          "requirestoken": "true"
        },
        customUrl: true);
    return response;
  }
}
