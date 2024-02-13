import 'dart:convert';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../widgets/NoData.dart';
import '../../Controllers/CartController.dart';
import '../../Controllers/CoursesController.dart';
import '../../widgets/Card.dart';
import '../../widgets/Button.dart';
import '../../Models/Courses.dart';
import '../../screens/Payments/PaypalPayment.dart';
import '../../utils/constants.dart';
import '../Controllers/HomeController.dart';
import '../widgets/PleaseLogin.dart';
import 'PaymentSuccess.dart';
import '../../services/SharedPrefs.dart';
import 'Payments/UPIPayment.dart';

class BuyNowScreen extends StatefulWidget {
  final courses;
  final app_bar_title;
  const BuyNowScreen(this.courses, this.app_bar_title);
  @override
  _BuyNowScreenstate createState() => _BuyNowScreenstate();
}

class _BuyNowScreenstate extends State<BuyNowScreen> {
  Map<String, dynamic>? paymentIntentData;

  final coursesController _coursesController = Get.put(coursesController());
  final cartController _cartController = Get.put(cartController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var selected_gateway = "".obs;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  var _subscription;
  var username = "";
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    prefs.getString('sensitive_user_meta_username').then((value) {
      username = value;
    });
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () {
      Get.back();
      return Future.value(true);
    }, child: Obx(() {
      if (_homeController.isLoggedIn.value) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(widget.app_bar_title),
          ),
          body: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 20.h),
              child: Obx(() {
                if (_cartController.cart_count.value == 0 &&
                    !(widget.app_bar_title == "Buy Now".tr)) {
                  return NoData.noData("empty-cart", "Your cart is empty".tr);
                }
                return Column(
                  children: [
                    Expanded(
                      flex: 93,
                      child: ListView(
                        children: [
                          Text(
                            "Your Items".tr,
                            style: TextStyle(
                                fontSize: 17.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          for (Courses course
                              in (widget.app_bar_title == "Your Cart".tr)
                                  ? _cartController.cart_items
                                  : widget.courses)
                            single_cart_widget(course),
                          SizedBox(
                            height: 15.h,
                          ),
                          Text(
                            "Payment Detail".tr,
                            style: TextStyle(
                                fontSize: 17.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          card.shadow_card(Container(
                            width: Get.width * 1.0,
                            padding: EdgeInsets.all(18.h),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Original Price".tr,
                                      style: TextStyle(fontSize: 17.sp),
                                    ),
                                    Text(
                                        _coursesController
                                                .get_origin_price(
                                                    widget.courses)
                                                .toString() +
                                            Constants.currency,
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Sale Price".tr,
                                      style: TextStyle(fontSize: 17.sp),
                                    ),
                                    Text(
                                        _coursesController
                                                .get_sale_price(widget.courses)
                                                .toString() +
                                            Constants.currency,
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                SizedBox(
                                  height: 1.0.h,
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 1.0, end: 1.0),
                                      height: 1.0.h,
                                      color: const Color(0xffD3D3D3),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total".tr,
                                      style: TextStyle(
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        _coursesController
                                                .get_sale_price(widget.courses)
                                                .toString() +
                                            Constants.currency,
                                        style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          )),
                          SizedBox(
                            height: 15.h,
                          ),
                          Text(
                            "Payment method".tr,
                            style: TextStyle(
                                fontSize: 17.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          SizedBox(
                            height: Get.height * 0.1,
                            width: Get.width * 1.0,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (String payment in (GetPlatform.isAndroid)
                                    ? Constants.payment_methods
                                    : ["in_app_purchase"])
                                  if (!(widget.app_bar_title ==
                                          "Your Cart".tr &&
                                      payment == "google_play"))
                                    payment_method(payment)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Total Amount".tr + " :",
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            Text(
                                _coursesController
                                        .get_sale_price(widget.courses)
                                        .toString() +
                                    Constants.currency,
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            theme_buttons.material_button("Place Order".tr, 0.4,
                                onTap: () {
                              if (selected_gateway.value != "") {
                                order_now(selected_gateway.value);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Please select atleast one payment gateway"
                                            .tr),
                                    duration: const Duration(seconds: 1)));
                              }
                            })
                          ],
                        ))
                  ],
                );
              })),
        );
      }
      return pleaseLogin(
        isAppBar: true,
      );
    }));
  }

  Widget payment_method(String name) {
    return GestureDetector(
      onTap: () {
        selected_gateway.value = name;
      },
      child: card.shadow_card(
          Container(
              width: Get.width * 0.6,
              padding: EdgeInsets.all(18.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ExtendedImage.asset(
                    ("assets/" + name + ".png"),
                    height: 30.h,
                  ),
                  if (selected_gateway == name)
                    Icon(
                      Icons.check_circle,
                      color: Constants.primary_color,
                    )
                ],
              )),
          shadow_color: const Color.fromRGBO(0, 0, 0, 0.03)),
    );
  }

  order_now(String Payment) async {
    if (Payment == "razorpay") {
      num amount = 0;
      for (var course in widget.courses) {
        amount += course.price;
      }

      var email = await prefs.getString("sensitive_user_meta_email");
      var name = await prefs.getString("sensitive_user_meta_username");
      var _razorpay = Razorpay();
      var options = {
        'key': Constants.razorPayApiKey,
        'amount': amount * Constants.CurrencyConversion * 100,
        'name': name,
        'description': (widget.courses[0] as Courses).name,
        'prefill': {'email': email}
      };
      _razorpay.open(options);
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          (PaymentSuccessResponse response) async {
        var coursesList =
            _coursesController.return_new_courseslist(widget.courses);
        for (var singleCourse in coursesList) {
          await _cartController.remove_with_id(singleCourse.id);
        }
        Get.off(PaymentSuccessScreen("Paypal", coursesList));
      });
    }
    if (Payment == "paypal") {
      Get.to(PaypalPayment(widget.courses));
    }
    if (Payment == "stripe") {
      await makePayment(widget.courses);
    }
    if (Payment == "upi") {
      num amount = 0;
      for (var course in widget.courses) {
        amount += course.price;
      }
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return UpiPayment(amount, widget.courses);
          });
    }

    if (Payment == "in_app_purchase" || Payment == "google_play") {
      late PurchaseParam purchaseParam;
      final bool available = await InAppPurchase.instance.isAvailable();
      if (available) {
        ProductDetailsResponse productDetailResponse = await _inAppPurchase
            .queryProductDetails({widget.courses[0].id.toString()});
        if (GetPlatform.isAndroid) {
          purchaseParam = GooglePlayPurchaseParam(
            productDetails: productDetailResponse.productDetails[0],
            applicationUserName: username,
          );
        } else {
          purchaseParam = PurchaseParam(
            productDetails: productDetailResponse.productDetails[0],
            applicationUserName: username,
          );
        }

        InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
      }
    }
  }

  Widget single_cart_widget(Courses course) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
      child: card.shadow_card(Container(
        height: 160.h,
        width: Get.width * 1.0,
        padding: EdgeInsets.all(10.h),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: ExtendedImage.network(
                course.image,
                height: 150.h,
                width: 120.w,
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 15.w,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    maxLines: 1,
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    course.instructor.name,
                    maxLines: 1,
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    course.price.toString() + Constants.currency,
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  const Divider(
                    thickness: 1,
                    color: Color(0xffD3D3D3),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            if (widget.app_bar_title == "Buy Now".tr) {
                              Navigator.pop(context);
                            } else {
                              _cartController.remove(course);
                            }
                            if (!_coursesController.isInWishlist(course)) {
                              _coursesController.changeWishlist(course);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.bookmark_border,
                                  color: Constants.primary_color),
                              Text(
                                "Move to \nwishlist".tr,
                                style: TextStyle(
                                    color: Constants.primary_color,
                                    fontWeight: FontWeight.w600),
                                maxLines: 2,
                              ),
                            ],
                          )),
                      GestureDetector(
                          onTap: () {
                            if (widget.app_bar_title == "Buy Now".tr) {
                              Navigator.pop(context);
                            } else {
                              _cartController.remove(course);
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              Text(
                                "Remove".tr,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            Get.off(PaymentSuccessScreen("In app purchases", widget.courses));
            for (var singleCourse in widget.courses) {
              _cartController.remove_with_id(singleCourse.id);
            }
          } else {}
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  Future<void> makePayment(var courses) async {
    try {
      paymentIntentData = await createPaymentIntent(
          courses, Constants.stripeCurrency); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Enable custom flow
          customFlow: false,
          // Main params
          merchantDisplayName: Constants.stripemerchantDisplayName,
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          // Customer keys
          customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
          customerId: paymentIntentData!['customer'],
          // Extra options
          testEnv: true,
          applePay: true,
          googlePay: true,
          style: ThemeMode.dark,
          merchantCountryCode: Constants.stripemerchantCountryCode,
        ),
      );
      displayPaymentSheet(courses);
    } catch (e) {}
  }

  displayPaymentSheet(var courses) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        //orderPlaceApi(paymentIntentData!['id'].toString());

        var coursesList = _coursesController.return_new_courseslist(courses);
        for (var singleCourse in coursesList) {
          _cartController.remove_with_id(singleCourse.id);
        }
        Get.off(PaymentSuccessScreen("Stripe", coursesList));
        paymentIntentData = null;
      }).onError((error, stackTrace) {});
    } on StripeException {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
    }
  }

  createPaymentIntent(var courses, String currency) async {
    try {
      num amount = 0;
      for (var course in courses) {
        amount += course.price;
      }
      Map<String, dynamic> body = {
        'amount': (amount * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ${Constants.stripeSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (err) {}
  }
}
