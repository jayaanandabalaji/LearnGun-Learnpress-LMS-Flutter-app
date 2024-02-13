import 'dart:ui';

class Constants {
  static const String appName = 'LearnGun';
  static const String base_url = 'https://test.digitalbloging.com';
  static const String purchase_code = '123-4567-1234567-123';
  static Color primary_color = HexColor('#02579D');
  static String font_family = 'Poppins';
  static String defaultLanguage = 'en';
  static List translationSwitch = [
    ["English", 'en'],
    ["French", "fr"],
    ["Haitian Creole", "ht"]
  ];
  static String currency = '\$';
  static List payment_methods = [
    "stripe",
    "paypal",
    "google_play",
    "razorpay",
    "upi"
  ];
  static bool cacheImages = true;
  static bool isProtected = true;
  static String becomeInstructorURL = "https://techgun.net/";
  static List resourcesSection = ["blogs", "webinar", "others"];
  static bool enableMembership = true;
  //Google ads
  static bool ShowAds = true;
  static String InterstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // zoom
  static String zoomSdkKey = "cXq6Pj9HWytD1TWfHHnSrmDw31KrG7MKSrX6";
  static String zoomSdkSecret = "HfYE05RmFQZE5qwJ67ucjPhEydt1m1zwsx8k";

  //razorpay
  static String razorPayApiKey = "rzp_test_1tgjO3iUu0FWHw";

  //paypal
  static String paypal_clientId =
      "ARPnYa2j3_eeMOkT3wA5mdOLSMJ-OiF-46yKya-cfrSj_0mMZl3H6VCw_L9w2aaV6hnLqMOdUXcDKjcO";
  static String paypal_secret =
      "EOc_KilwBucMB55_qYhbbkH4iMBtP1krx-NzRRVy8qPMMvntHHJH12daFRoWupKeqZdTgZPsSn3iNhKF";
  static String returnURL = 'test.skillup.com';
  static String cancelURL = 'cancel.example.com';
  static String paypal_transaction_description =
      "The payment transaction description.";
  static String paypal_note_payer =
      "Contact us for any questions on your order.";
  static bool isSandbox = true;
  static String paypalCurrency = "USD";

  //stripe
  static String stripePublishableKey =
      "pk_live_51KjO05SIZIXyeU3AUydw3InU4s40aMcMfjakB2Y6S6481UsACJwyRDkSrCdcxYWeqk6fIa2BWXTkt0FDY8HPjqfb00ynbaRw1i";
  static String stripeSecretKey =
      "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";
  static String stripeCurrency = "USD";
  static String stripemerchantCountryCode = "US";
  static String stripemerchantDisplayName = "LearnGun";

  //UPI
  static String receiverUpiId = "jayakannan@fbl";
  static String receiverName = "Jaya Ananda Balaji";
  static num CurrencyConversion = 78;
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
