import 'dart:core';
import 'package:LearnGun/Controllers/MembershipController.dart';
import 'package:LearnGun/Models/Membership.dart';
import 'package:LearnGun/services/membershipsApi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Controllers/CoursesController.dart';
import '../../Controllers/CartController.dart';
import '../../Controllers/HomeController.dart';
import '../../services/CoursesAPI.dart';
import '../../widgets/Notify/notify.dart';
import '../../utils/constants.dart';
import '../../services/PaypalServices.dart';
import '../PaymentSuccess.dart';

class PaypalPayment extends StatefulWidget {
  final courses;
  final membership;
  PaypalPayment(this.courses, {this.membership = ""});
  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState(courses);
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  var courses;
  PaypalPaymentState(this.courses);
  var checkoutUrl;
  var executeUrl;
  var accessToken;
  PaypalServices services = PaypalServices();
  var isLoading = true.obs;
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "${Constants.currency} ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": Constants.paypalCurrency
  };

  String returnURL = Constants.returnURL;
  String cancelURL = Constants.cancelURL;
  final cartController _cartController = Get.put(cartController());
  final coursesController _coursesController = Get.put(coursesController());
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();
        final transactions = getOrderParams();
        final res =
            await services.createPaypalPayment(transactions, accessToken);
        setState(() {
          checkoutUrl = res["approvalUrl"] ?? "";
          executeUrl = res["executeUrl"] ?? "";
        });
      } catch (e) {}
    });
  }

  Map<String, dynamic> getOrderParams() {
    List items = [];
    String totalAmount = "";
    if (widget.membership == "") {
      for (var course in courses) {
        items.add({
          "name": course.name,
          "quantity": 1,
          "price": course.price,
          "currency": defaultCurrency["currency"]
        });
      }
      num amount = 0;
      for (var course in courses) {
        amount += course.price;
      }
      totalAmount = amount.toString();
    } else {
      items.add({
        "name": (widget.membership as PlansBean).name,
        "quantity": 1,
        "price": (widget.membership as PlansBean).initial_payment,
        "currency": defaultCurrency["currency"]
      });
      totalAmount = (widget.membership as PlansBean).initial_payment.toString();
    }
    String subTotalAmount = totalAmount;
    String shippingCost = '0';
    int shippingDiscountCost = 0;

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": subTotalAmount,
              "shipping": shippingCost,
              "shipping_discount": ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": Constants.paypal_transaction_description,
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
          }
        }
      ],
      "note_to_payer": Constants.paypal_note_payer,
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paypal Payment"),
      ),
      body: (checkoutUrl != null)
          ? WillPopScope(
              child: Stack(
                children: [
                  WebView(
                    initialUrl: checkoutUrl,
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (finish) {
                      setState(() {
                        isLoading.value = false;
                      });
                    },
                    navigationDelegate: (NavigationRequest request) {
                      if (request.url.contains(returnURL)) {
                        final uri = Uri.parse(request.url);
                        final payerID = uri.queryParameters['PayerID'];
                        if (payerID != null) {
                          services
                              .executePayment(executeUrl, payerID, accessToken)
                              .then((id) async {
                            if (widget.membership == "") {
                              var coursesList = _coursesController
                                  .return_new_courseslist(courses);
                              for (var singleCourse in coursesList) {
                                await _cartController
                                    .remove_with_id(singleCourse.id);
                              }
                              Get.off(
                                  PaymentSuccessScreen("Paypal", coursesList));
                            } else {
                              notify.showLoadingDialog("Verifying payment");
                              await membershipsApi.enrollMembership(int.parse(
                                  (widget.membership as PlansBean).id));
                              Get.back();
                              Get.back();
                              Get.put(MembershipController()).getMembership();
                              Get.put(HomeController()).courseslist.value =
                                  await CoursesApi().GetCourses({});
                            }
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      }
                      if (request.url.contains(cancelURL)) {
                        Navigator.of(context).pop();
                      }
                      return NavigationDecision.navigate;
                    },
                  ),
                  Obx(() {
                    if (isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return Stack();
                    }
                  }),
                ],
              ),
              onWillPop: _promptconfirmation,
            )
          : Center(child: Container(child: const CircularProgressIndicator())),
    );
  }

  Future<bool> _promptconfirmation() async {
    return await notify.showDialog("Cancel transaction",
        "Are you sure, do you want to cancel this transaction?",
        confirm_text: "Yes", cancel_text: "cancel", on_confirm: () {
      Get.back();
      Get.back();
      notify.show_snackbar(
          "Payment cancelled".tr, "Paypal " + "transaction failed".tr + ".");
    });
  }
}
