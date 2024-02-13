import '../../Models/OrderComplete.dart';
import '../../Models/GetOrders.dart';
import 'BaseAPI.dart';
import '../../services/SharedPrefs.dart';

class OrderApi {
  static Future GetSettings(String PaymentMethod, List courses) async {
    var userId = await (prefs.getString("user_info_id"));
    Map data = {
      "courses": courses,
      "user_id": userId,
      "payment_method": PaymentMethod,
    };
    var response =
        await baseAPI().postAsync("learnpressapp/v1/create-order", data, customUrl: true, requires_license: true);
    return complete_order.fromJson(response);
  }

  static Future getOrders() async {
    var response = await baseAPI().postAsync(
      "learnpressapp/v1/get-orders",
      {"requirestoken": true},
      customUrl: true,
    );
    return response.map((value) => GetOrders.fromJson(value)).toList();
  }
}
