import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:get/get.dart';

import '../../Controllers/CartController.dart';
import '../../screens/CartScreen.dart';
import '../../utils/constants.dart';
import '../Controllers/SearchController.dart';

class CoursesAppBarActions {
  final SearchController _searchController = Get.put(SearchController());
  final cartController _cartController = Get.put(cartController());
  Widget cart_widget({Color widget_color = Colors.black}) {
    return (GetPlatform.isIOS)
        ? Container()
        : GestureDetector(
            onTap: () {
              Get.to(BuyNowScreen(_cartController.cart_items as dynamic, "Your Cart"));
            },
            child: Container(
              height: 55.h,
              padding: EdgeInsets.fromLTRB(0, 0, 20.h, 0),
              child: Badge(
                badgeContent: Obx(() =>
                    Text(_cartController.cart_count.value.toString(), style: const TextStyle(color: Colors.white))),
                child: Icon(
                  Icons.shopping_cart,
                  color: widget_color,
                  size: 30,
                ),
                toAnimate: true,
                shape: BadgeShape.circle,
                badgeColor: Constants.primary_color,
                borderRadius: BorderRadius.circular(8.r),
                position: BadgePosition.topEnd(top: 0, end: -5),
              ),
            ),
          );
  }

  Widget search() {
    return IconButton(
        onPressed: () {
          _searchController.gotoCategory({"id": 0, "name": "All Categories".tr}, openSearch: true);
        },
        icon: const Icon(
          Icons.search,
          color: Colors.white,
        ));
  }
}
