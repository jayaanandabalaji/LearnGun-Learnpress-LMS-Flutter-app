import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class AppTheme {
  static get_app_theme() {
    return ThemeData(
      textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.orange),
      textTheme: GoogleFonts.getTextTheme(
        Constants.font_family, // If this is not set, then ThemeData.light().textTheme is used.
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: MaterialColor(Constants.primary_color.value, color))
          .copyWith(secondary: Colors.white),
    );
  }
}

Map<int, Color> color = {
  50: const Color.fromRGBO(136, 14, 79, .1),
  100: const Color.fromRGBO(136, 14, 79, .2),
  200: const Color.fromRGBO(136, 14, 79, .3),
  300: const Color.fromRGBO(136, 14, 79, .4),
  400: const Color.fromRGBO(136, 14, 79, .5),
  500: const Color.fromRGBO(136, 14, 79, .6),
  600: const Color.fromRGBO(136, 14, 79, .7),
  700: const Color.fromRGBO(136, 14, 79, .8),
  800: const Color.fromRGBO(136, 14, 79, .9),
  900: const Color.fromRGBO(136, 14, 79, 1),
};
