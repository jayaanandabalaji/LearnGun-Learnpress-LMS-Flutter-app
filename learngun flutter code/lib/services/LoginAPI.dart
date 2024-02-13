import 'BaseAPI.dart';

class LoginApi {
  static LoginByDefault(String login, String password) async {
    Map data = {"username": login, "password": password};
    var response = await baseAPI().postAsync("token", data);
    return response;
  }

  static SocialAuth(String email, String accessToken, String loginType) async {
    Map data = {"email": email, "accessToken": accessToken, "loginType": loginType};
    var response =
        await baseAPI().postAsync("learnpressapp/v1/social-login", data, customUrl: true, requires_license: true);
    return response;
  }
}
