import 'BaseAPI.dart';

class RegisterApi {
  RegisterByDefault(String name, String password, String email) async {
    Map data = {
      'email': email,
      'username': name,
      'password': password,
      'confirm_password': password,
    };
    var response = await baseAPI().postAsync("token/register", data);
    return response;
  }
}
