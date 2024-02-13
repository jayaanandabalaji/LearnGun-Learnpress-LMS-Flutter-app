import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' as convert;

import '../../utils/constants.dart';

class PaypalServices {
  String domain =
      (Constants.isSandbox) ? "https://api.sandbox.paypal.com" : "https://api.paypal.com"; // for sandbox mode
//  String domain = "https://api.paypal.com"; // for production mode

  // change clientId and secret with your own, provided by paypal
  String clientId = Constants.paypal_clientId;
  String secret = Constants.paypal_secret;

  // for getting the access token from Paypal
  Future<String> getAccessToken() async {
    try {
      String basicAuth = 'Basic ' + base64Encode(utf8.encode('$clientId:$secret'));
      var client = http.Client();

      var response = await client.post(Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'),
          headers: <String, String>{'authorization': basicAuth});
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return body["access_token"];
      }
      return "";
    } catch (e) {
      rethrow;
    }
  }

  // for creating the payment request with Paypal
  Future<Map<String, String>> createPaypalPayment(transactions, accessToken) async {
    try {
      var response = await http.post(Uri.parse("$domain/v1/payments/payment"),
          body: convert.jsonEncode(transactions),
          headers: {"content-type": "application/json", 'Authorization': 'Bearer ' + accessToken});

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];
          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approval_url", orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute", orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
        return {};
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> executePayment(url, payerId, accessToken) async {
    try {
      var response = await http.post(Uri.parse(url),
          body: jsonEncode({"payer_id": payerId}),
          headers: {"content-type": "application/json;charset=UTF-8", 'Authorization': 'Bearer ' + accessToken});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body["id"];
      }
      return "";
    } catch (e) {
      rethrow;
    }
  }
}
