import 'dart:convert';
import 'package:LearnGun/Controllers/HomeController.dart';
import 'package:LearnGun/services/CoursesAPI.dart';
import 'package:LearnGun/services/SharedPrefs.dart';
import 'package:LearnGun/widgets/Notify/notify.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;

import 'package:LearnGun/Controllers/MembershipController.dart';
import 'package:LearnGun/Models/Membership.dart';
import 'package:LearnGun/services/membershipsApi.dart';
import 'package:LearnGun/utils/constants.dart';
import 'package:LearnGun/widgets/Button.dart';
import 'package:LearnGun/widgets/Card.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'Payments/PaypalPayment.dart';
import 'Payments/UPIPayment.dart';

class membershipsScreen extends StatefulWidget {
  const membershipsScreen({Key? key}) : super(key: key);

  @override
  State<membershipsScreen> createState() => _membershipsScreenState();
}

class _membershipsScreenState extends State<membershipsScreen> {
  final _membershipController = Get.put(MembershipController());
  var selected_gateway = "paypal".obs;
  Map<String, dynamic>? paymentIntentData;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  var username = "";
  var currentPlan;
  var MemberShipLoop = {
    1: [
      [
        Color(0xff279AA1),
        Color(0xff64D8BF),
      ],
      "membership-1.png"
    ],
    2: [
      [
        Color(0xffB6A536),
        Color(0xffDAD385),
      ],
      "membership-2.png"
    ],
    3: [
      [
        Color(0xffEC5358),
        Color(0xffF195B2),
      ],
      "membership-3.png"
    ]
  };
  var _subscription;
  @override
  void initState() {
    super.initState();
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
    _membershipController.getMembership();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Membership"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Obx(() {
            if (_membershipController.membership.toString() != "{}") {
              
              var membership;
              if ((_membershipController.membership)["membership"] != false) {
                membership = Membershipbean.fromJson(
                    (_membershipController.membership)["membership"]);
              }
              return Column(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if ((_membershipController.membership)["membership"] !=
                        false)
                      Text(membership.name,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Constants.primary_color)),
                    SizedBox(height: 10),
                    if ((_membershipController.membership)["membership"] !=
                        false)
                      Text("Your plan will expire on " +
                          DateFormat('dd/MM/yyyy, HH:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(membership.enddate) * 1000))),
                    if ((_membershipController.membership)["membership"] ==
                        false)
                      Text(
                          "You currently don't have any active membership plans.",
                          textAlign: TextAlign.center)
                  ],
                ),
                for (int i = 0;
                    i < (_membershipController.membership)["plans"].length;
                    i++)
                  planCard((_membershipController.membership)["plans"][i])
              ]);
            }
            return Container(
                height: Get.height * 0.8,
                child: Center(child: CircularProgressIndicator()));
          })
        ],
      ),
    );
  }

  int index = 0;

  Widget planCard(PlansBean plan) {
    var CategoriesStr = "";
    if (plan.categories != "") {
      for (String category in plan.categories) {
        CategoriesStr += category + ", ";
      }
    }

    if (MemberShipLoop.length == index) {
      index = 1;
    } else {
      index++;
    }
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: MemberShipLoop[index]![0] as dynamic,
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 70,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/${MemberShipLoop[index]![1]}",
                          height: 35,
                        ),
                        Text(plan.name)
                      ]),
                ),
                SizedBox(width: 10),
                Container(
                  width: Get.width - 150,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                                Constants.currency +
                                    plan.initial_payment.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                ((int.parse(plan.expiration_number) != 1)
                                        ? (" for " + plan.expiration_number)
                                        : " per") +
                                    " " +
                                    plan.expiration_period,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400))
                          ],
                        ),
                        SizedBox(height: 5),
                        Html(data: """
                    ${plan.description}
                    """, style: {
                          "body": Style(
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                          ),
                          "h1": Style(color: Colors.white),
                          "h2": Style(color: Colors.white),
                          "h3": Style(color: Colors.white),
                          "h4": Style(color: Colors.white),
                          "h6": Style(color: Colors.white),
                          "h5": Style(color: Colors.white),
                          "li": Style(color: Colors.white),
                          "p": Style(color: Colors.white),
                          "b": Style(color: Colors.white),
                        }),
                        if (CategoriesStr != "")
                          Text("Categories: " +
                              (CategoriesStr)
                                  .substring(0, CategoriesStr.length - 2)),
                        GestureDetector(
                          onTap: () {
                            currentPlan = plan.id;
                            Get.bottomSheet(
                              bottomPaymentSheet(plan),
                              isDismissible: true,
                            );
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(((_membershipController
                                            .membership)["membership"] ==
                                        false)
                                    ? "Choose plan"
                                    : "change plan"),
                                Text(
                                    String.fromCharCode(
                                        Icons.arrow_forward_ios.codePoint),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily:
                                            Icons.arrow_forward_ios.fontFamily,
                                        fontWeight: FontWeight.w400))
                              ]),
                        ),
                      ]),
                )
              ],
            ),
          ),
        ));
  }

  Widget bottomPaymentSheet(PlansBean plan) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        height: 250,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Payment method".tr,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            SizedBox(
              height: Get.height * 0.1,
              width: Get.width * 1.0,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  for (String payment in Constants.payment_methods)
                    Obx(() {
                      return payment_method(payment);
                    })
                ],
              ),
            ),
            Expanded(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Total".tr + " : ",
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        Text(
                            plan.initial_payment.toString() +
                                Constants.currency,
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        theme_buttons.material_button("Pay Now".tr, 0.4,
                            onTap: () {
                          if (selected_gateway.value != "") {
                            Get.back();
                            order_now(selected_gateway.value, plan);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Please select atleast one payment gateway"
                                        .tr),
                                duration: const Duration(seconds: 1)));
                          }
                        })
                      ],
                    )))
          ],
        ));
  }

  order_now(String Payment, PlansBean plan) async {
    if (Payment == "razorpay") {
      var email = await prefs.getString("sensitive_user_meta_email");
      var name = await prefs.getString("sensitive_user_meta_username");
      var _razorpay = Razorpay();
      var options = {
        'key': Constants.razorPayApiKey,
        'amount': plan.initial_payment * Constants.CurrencyConversion * 100,
        'name': name,
        'description': plan.name,
        'prefill': {'email': email}
      };
      _razorpay.open(options);
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          (PaymentSuccessResponse response) async {
        notify.showLoadingDialog("Verifying payment");

        await membershipsApi.enrollMembership(int.parse(plan.id));
        Get.back();
        Get.put(MembershipController()).getMembership();
        Get.put(HomeController()).courseslist.value =
            await CoursesApi().GetCourses({});
      });
    }
    if (Payment == "paypal") {
      await Get.to(PaypalPayment(
        null,
        membership: plan,
      ));
      _membershipController.getMembership();
    }
    if (Payment == "stripe") {
      await makePayment(plan);
    }
    if (Payment == "upi") {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return UpiPayment(plan.initial_payment, null);
          });
    }

    if (Payment == "in_app_purchase" || Payment == "google_play") {
      late PurchaseParam purchaseParam;
      final bool available = await InAppPurchase.instance.isAvailable();
      if (available) {
        ProductDetailsResponse productDetailResponse =
            await _inAppPurchase.queryProductDetails({plan.id.toString()});
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

        InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
      }
    }
  }

  Future<void> makePayment(PlansBean plan) async {
    try {
      paymentIntentData = await createPaymentIntent(
          plan, Constants.stripeCurrency); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
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
      displayPaymentSheet(plan);
    } catch (e) {}
  }

  displayPaymentSheet(PlansBean plan) async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet().then((newValue) async {
        //orderPlaceApi(paymentIntentData!['id'].toString());
        notify.showLoadingDialog("Verifying payment");
        await membershipsApi.enrollMembership(int.parse(plan.id));
        Get.back();
        _membershipController.getMembership();
        Get.put(HomeController()).courseslist.value =
            await CoursesApi().GetCourses({});

      }).onError((error, stackTrace) {});
    } on stripe.StripeException {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
    }
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

  createPaymentIntent(PlansBean plan, String currency) async {
    try {
      num amount = plan.initial_payment;

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
            notify.showLoadingDialog("Verifying payment");
            await membershipsApi.enrollMembership(int.parse(currentPlan));
            Get.back();
            _membershipController.getMembership();
            Get.put(HomeController()).courseslist.value =
                await CoursesApi().GetCourses({});

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
}
