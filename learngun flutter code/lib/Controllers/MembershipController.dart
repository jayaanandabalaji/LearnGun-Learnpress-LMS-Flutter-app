
import 'package:LearnGun/Models/Membership.dart';
import 'package:LearnGun/services/membershipsApi.dart';
import 'package:get/get.dart';

class MembershipController extends GetxController {
  var membership = {}.obs;

  Future getMembership() async {
    membership.value = {};
    var reponse = await membershipsApi.getMemberships();
    membership.value = (reponse as Membership).toJson();
  }
}
