import 'dart:math';
import 'package:LearnGun/services/membershipsApi.dart';
import 'package:LearnGun/widgets/Notify/notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:upi_india/upi_india.dart';

import '../../Controllers/CartController.dart';
import '../../Controllers/HomeController.dart';
import '../../Controllers/MembershipController.dart';
import '../../services/CoursesAPI.dart';
import '../PaymentSuccess.dart';
import '../../utils/constants.dart';

class UpiPayment extends StatefulWidget {
  final num amount;
  final courses;
  final plan;
  const UpiPayment(this.amount, this.courses, {this.plan = ""});
  @override
  _UpiPaymentState createState() => _UpiPaymentState();
}

class _UpiPaymentState extends State<UpiPayment> {
  final cartController _cartController = Get.put(cartController());
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;
  final _membershipController = Get.put(MembershipController());

  TextStyle header = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14.sp,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    super.initState();
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    var rnd = Random();
    num amount = widget.amount;

    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: Constants.receiverUpiId,
      receiverName: Constants.receiverName,
      transactionRefId: 'payment#' + rnd.nextInt(100).toString(),
      transactionNote: Constants.appName + " course purchase",
      amount: (amount * Constants.CurrencyConversion).toDouble(),
    );
  }

  Widget displayUpiApps() {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                  setState(() {});
                },
                child: SizedBox(
                  height: 100.h,
                  width: 100.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60.h,
                        width: 60.w,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Pay Using your UPI Apps",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
              )),
          Expanded(
            child: displayUpiApps(),
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder:
                  (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    Future.microtask(() => ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(
                            content: Text(
                                _upiErrorHandler(snapshot.error.runtimeType)
                                    .tr),
                            duration: const Duration(seconds: 1))));
                    return Container();
                  }

                  // If we have data then definitely we will have UpiResponse.
                  // It cannot be null
                  UpiResponse _upiResponse = snapshot.data!;

                  // Data in UpiResponse can be null. Check before printing

                  String status = _upiResponse.status ?? 'N/A';

                  if (status == UpiPaymentStatus.SUCCESS ||
                      status == UpiPaymentStatus.SUBMITTED) {
                    if (widget.plan == "") {
                      Future.microtask(() {
                        for (var singleCourse in widget.courses) {
                          _cartController.remove_with_id(singleCourse.id);
                        }
                        Get.back();
                        Get.off(PaymentSuccessScreen("UPI", widget.courses));
                      });
                    }
                  } else {
                    notify.showLoadingDialog("Verifying payment");
                    membershipsApi
                        .enrollMembership(int.parse(widget.plan.id))
                        .then((_) async {
                      Get.back();
                      Get.back();
                      _membershipController.getMembership();
                      Get.put(HomeController()).courseslist.value =
                          await CoursesApi().GetCourses({});
                    });
                  }

                  return Container();
                } else {
                  return const Center(
                    child: Text(''),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
