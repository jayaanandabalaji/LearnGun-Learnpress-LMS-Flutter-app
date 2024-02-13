import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../../screens/Home.dart';
import '../../screens/MyCourses.dart';
import '../../screens/profile/Profile.dart';
import '../../screens/search.dart';
import '../../utils/constants.dart';
import '../screens/Wishlist.dart';

List<Widget> _buildScreens() {
  return [
    DashboardScreen(),
    SearchScreen(),
    const CoursesScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];
}

List<PersistentBottomNavBarItem> _navBarsItems() {
  return [
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.home),
      title: ("Home".tr),
      activeColorPrimary: Constants.primary_color,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.search),
      title: ("Search".tr),
      activeColorPrimary: Constants.primary_color,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.book),
      title: ("Courses".tr),
      activeColorPrimary: Constants.primary_color,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.favorite_border),
      title: ("Wishlists".tr),
      activeColorPrimary: Constants.primary_color,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(CupertinoIcons.person_crop_circle),
      title: ("Profile".tr),
      activeColorPrimary: Constants.primary_color,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
  ];
}

// ignore: must_be_immutable
class BottomNav extends StatelessWidget {
  PersistentTabController TabBarController = Get.put(PersistentTabController(initialIndex: 0));
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: TabBarController,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0.r),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style6, // Choose the nav bar style with this property.
    );
  }
}
