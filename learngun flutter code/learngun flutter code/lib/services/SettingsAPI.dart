import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/HomeController.dart';
import '../../themes/AppTheme.dart';
import '../../utils/constants.dart';
import '../../services/SharedPrefs.dart';
import 'BaseAPI.dart';
import '../../Models/settings.dart';
import '../../utils/Translations.dart';

class SettingsApi {
  final HomeController _homeController = Get.put(HomeController());

  GetSettings() async {
    setTranslations();
    set_theme_using_local();
    var response = await baseAPI().getAsync("learnpressapp/v1/app-settings",
        customUrl: true, requires_license: true);
    response = settings.fromJson(response);
    await SettingsController(response);
    var isRegistered = await prefs.getString("user_info_id");
    if (isRegistered == null) {
      isRegistered = false;
    } else {
      isRegistered = true;
    }
    _homeController.isLoggedIn.value = isRegistered;

    List returnList = [response, isRegistered];
    return returnList;
  }

  setTranslations() async {
    for (var language in Constants.translationSwitch) {
      String data = await DefaultAssetBundle.of(Get.context!)
          .loadString("translations/${language[1]}.json");
      for (var key in json.decode(data).keys.toList()) {
        translations.defaultTranslationArray[language[1]]![key] =
            json.decode(data)[key];
      }
    }
    if ((await prefs.getString("locale")) != null) {
      var locale = await prefs.getString("locale");
      Get.updateLocale(Locale(locale));
    }
  }

  SettingsController(settings response) async {
    var primaryColor = (response.PrimaryColor);
    var secondaryColor = (response.SecondaryColor);
    if (primaryColor != "") {
      Constants.primary_color = HexColor(primaryColor);
    }

    if (response.home_category_courses.isNotEmpty) {
      for (String category in response.home_category_courses) {
        _homeController.featured_categories.add(
            {"id": category.split("|")[0], "name": category.split("|")[1]});
      }
    }
    if (response.Typography.FontFamily != "") {
      Constants.font_family = response.Typography.FontFamily;
    }
    List bannerList = [];
    for (int i = 0; i < response.banner_title.length; i++) {
      var tempList = {};
      tempList["title"] = (response.banner_title[i]);
      tempList["image"] = (response.banner_image[i].url);
      tempList["type"] = (response.BannerType[i]);
      tempList["value"] = (response.type_value[i]);
      bannerList.add(tempList);
    }
    _homeController.banner_list = bannerList;
    await prefs.setString("primary-color", primaryColor);
    await prefs.setString("secondary-color", secondaryColor);
    Get.changeTheme(AppTheme.get_app_theme());
  }

  static set_theme_using_local() async {
    var primaryColor = await prefs.getString("primary-color");
    var secondaryColor = await prefs.getString("secondary-color");
    if (primaryColor != null &&
        secondaryColor != null &&
        primaryColor != "" &&
        secondaryColor != "") {
      Constants.primary_color = HexColor(primaryColor);
    }
    Get.changeTheme(AppTheme.get_app_theme());
  }
}
