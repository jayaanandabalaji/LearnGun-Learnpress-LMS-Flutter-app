import 'package:LearnGun/Models/Membership.dart';
import 'package:LearnGun/services/SharedPrefs.dart';

import 'BaseAPI.dart';

class membershipsApi {
  static getMemberships() async {
    var response = await baseAPI().getAsync("learnpressapp/v1/memberships",
        data: {"requirestoken": true}, customUrl: true);
    try {
      Membership.fromJson(response);
    } catch (error) {
      
    }
    return Membership.fromJson(response);
  }

  static enrollMembership(int membershipId) async {
    var userId = await (prefs.getString("user_info_id"));
    var response = await baseAPI().getAsync(
        "learnpressapp/v1/enroll-membership?user_id=${userId}&membership_id=${membershipId}",
        customUrl: true,
        requires_license: true);
    return response;
  }
}
