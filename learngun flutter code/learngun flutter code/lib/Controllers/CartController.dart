import 'dart:convert';
import 'package:get/get.dart';

import '../services/SharedPrefs.dart';
import '../Models/Courses.dart';

class cartController extends GetxController {
  var cart_items = [].obs;
  var cart_count = 0.obs;

  getCart() async {
    var tempCartList = [];
    List<String> getCart = await prefs.getStringList("cart") ?? [];
    for (String cartItem in getCart) {
      tempCartList.add(Courses.fromJson(jsonDecode(cartItem)));
    }
    cart_items.value = tempCartList;
    cart_count.value = tempCartList.length;
  }

  storeCart() async {
    List<String> tempCartList = [];
    for (Courses course in cart_items) {
      tempCartList.add(jsonEncode(course));
    }
    prefs.setStringList("cart", tempCartList);
  }

  addtocart(Courses course) async {
    if (!isInCart(course)) {
      cart_items.insert(0, course);
      cart_count.value++;
      await storeCart();
    }
  }

  isInCart<bool>(Courses course) {
    for (Courses singleCourse in cart_items) {
      if (singleCourse.id == course.id) {
        return true;
      }
    }
    return false;
  }

  Future remove_with_id(int courseid) async {
    for (var singleCourse in cart_items) {
      if (singleCourse.id == courseid) {
        cart_items.remove(singleCourse);
        cart_count.value--;
        await storeCart();
        break;
      }
    }
  }

  remove(var course) async {
    cart_items.remove(course);
    cart_count.value--;
    await storeCart();
  }

  removeall() async {
    cart_items.value = [];
    cart_count.value = 0;
    await storeCart();
  }
}
