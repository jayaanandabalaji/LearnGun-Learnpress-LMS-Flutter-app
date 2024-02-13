
import 'package:LearnGun/screens/memberships.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:LearnGun/widgets/Button.dart';
import '../../Controllers/HomeController.dart';
import '../../Controllers/ProfileController.dart';
import '../../screens/profile/MyOrders.dart';
import '../../services/ProfileAPI.dart';
import '../../widgets/Card.dart';
import '../../services/SharedPrefs.dart';
import '../../utils/constants.dart';
import '../../widgets/PleaseLogin.dart';
import '../PaymentSuccess.dart';
import 'EditProfile.dart';
import '../../services/CoursesAPI.dart';
import '../../widgets/Notify/notify.dart';
import '../../screens/MyCourses.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

Future fetchMeta(String meta) async {
  if (meta == "image") {
    return prefs.getString('user_info_avatar');
  }
  if (meta == "name") {
    return prefs.getString('sensitive_user_meta_username');
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  var _subscription;
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
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
    return Obx(() {
      if (_homeController.isLoggedIn.value) {
        return Scaffold(
          appBar: AppBar(
            title: Text("My Account".tr),
          ),
          body: FutureBuilder(
              future: fetchMeta("name"),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return ListView(
                    children: [
                      BuildProfile(snapshot.data.toString()),
                      BuildRows("Edit profile".tr, Icons.create_rounded,
                          EditProfile()),
                      if (Constants.enableMembership)
                        BuildRows(
                          "Membership Plans".tr,
                          Icons.bookmark,
                          membershipsScreen(),
                        ),
                      BuildRows(
                          "My orders".tr, Icons.shopping_cart, MyOrders()),
                      BuildRows("Change Language".tr, Icons.language, null,
                          isChangeLanguage: true),
                      BuildRows(
                          "Downloaded Courses".tr,
                          Icons.cloud_download,
                          const CoursesScreen(
                            IsOffline: true,
                          )),
                      if (Constants.becomeInstructorURL != "")
                        BuildRows("Become Instructor".tr, Icons.school, null,
                            isBecomeInst: true),
                      if (GetPlatform.isIOS ||
                          Constants.payment_methods.contains("google_play"))
                        BuildRows("Restore Purchases".tr, Icons.restore, null,
                            isRestore: true),
                      BuildRows("Delete account".tr, Icons.delete, null,
                          isDeleteAccount: true),
                      BuildRows("Logout".tr, Icons.logout, MyOrders(),
                          isLogout: true),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              }),
        );
      }
      return pleaseLogin();
    });
  }

  Widget BuildRows(String title, var icon, var RedirectScreen,
      {bool isLogout = false,
      bool isChangeLanguage = false,
      bool isBecomeInst = false,
      bool isRestore = false,
      bool isDeleteAccount = false}) {
    return InkWell(
        onTap: () async {
          if (isLogout) {
            showAlertDialog(context);
          } else if (isDeleteAccount) {
            showDeleteDialog(context);
          } else if (isChangeLanguage) {
            showDialog(
                context: context,
                builder: (BuildContext context) => Dialog(
                      child: ChangeLanguageDialog(),
                    ));
          } else if (isBecomeInst) {
            if (!await launchUrl(Uri.parse(Constants.becomeInstructorURL)))
              throw 'Could not launch';
          } else if (isRestore) {
            ConfirmRestoreDialog(context);
          } else {
            Get.to(RedirectScreen);
          }
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: const Color(0xffD3D3D3), width: 2.w))),
          width: Get.width * 1.0,
          padding: EdgeInsets.all(20.h),
          margin: EdgeInsets.fromLTRB(15.w, 0, 15.w, 0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 25,
                color: (isLogout) ? Colors.red : Constants.primary_color,
              ),
              Container(width: 20.w),
              SizedBox(
                width: Get.width - 115.w,
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: (isLogout) ? Colors.red : Colors.black),
                ),
              ),
            ],
          ),
        ));
  }

  final formKey = GlobalKey<FormState>();

  TextEditingController password = TextEditingController();
  showDeleteDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          //this right here
          child: Container(
            padding: EdgeInsets.all(20),
            height: 400.h,
            width: 450.w,
            child: ListView(
              children: <Widget>[
                Text("Are you sure you want to delete this account?"),
                Text(
                    "Please read how account deletion works before you delete your account"),
                SizedBox(height: 5),
                Text(
                  "Account",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                    "Your account will be deleted from our database. All courses will be deleted from your account."),
                SizedBox(height: 5),
                Text(
                  "Type DELETE to confirm account deletion",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      card.shadow_card(
                          TextFormField(
                            controller: password,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 10.h),
                                hintText: 'Confirmation'.tr),
                            validator: (text) {
                              if (text!.isEmpty) {
                                return "This field is required.";
                              }
                              if (text != "DELETE") {
                                return "Please enter DELETE";
                              }
                              return null;
                            },
                          ),
                          ContainerBorderRadius: 0),
                      SizedBox(height: 10),
                      theme_buttons.material_button("Delete", 0.8,
                          onTap: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          notify.showLoadingDialog("Deleting Account");
                          var response = await ProfileApi.DeleteAccount();
                          if (response["message"] ==
                              "Account deleted successfully.") {
                            Get.back();
                            ProfileController().logout();
                          } else {
                            Get.back();
                            notify.showDialog("Error ", response["message"],
                                on_confirm: () {
                              Get.back();
                            });
                          }
                        }
                      })
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget ChangeLanguageDialog() {
    return SizedBox(
        height: 200.h,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Change Language".tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(Icons.close),
                    )
                  ],
                )),
            for (var language in Constants.translationSwitch)
              LanguageRow(language)
          ],
        ));
  }

  Widget LanguageRow(var Language) {
    return InkWell(
        onTap: () async {
          await ProfileController().changeLocale(Language[1]);
          Get.back();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Language Changed Successfully".tr)));
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
          child: Row(
            children: [
              Image.asset("assets/flags/" + Language[1] + ".png",
                  height: 20.h, width: 30.w, fit: BoxFit.contain),
              SizedBox(
                width: 20.w,
              ),
              Text(
                Language[0],
                style: TextStyle(fontSize: 18.sp),
              )
            ],
          ),
        ));
  }

  Widget BuildProfile(String name) {
    return InkWell(
        onTap: () async {},
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: const Color(0xffD3D3D3), width: 2.w))),
          width: Get.width * 1.0,
          padding: EdgeInsets.all(20.h),
          margin: EdgeInsets.fromLTRB(15.w, 0, 15.w, 0),
          child: Row(
            children: [
              Image.asset(
                'assets/user.png',
                height: 50.h,
              ),
              Container(width: 20.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello".tr,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    name.replaceAll("@gmail.com", ""),
                    style:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  ConfirmRestoreDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel".tr),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes".tr),
      onPressed: () async {
        await InAppPurchase.instance.restorePurchases();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Restore".tr),
      content: Text(
          "Are you Sure, Do you really want to restore courses purchased using In-App Purchases?"
              .tr),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel".tr),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Logout".tr),
      onPressed: () async {
        ProfileController().logout();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout".tr),
      content: Text("Do you really want to logout?".tr),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    Navigator.of(context, rootNavigator: true).pop();
    if (purchaseDetailsList.isEmpty) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nothing available to restore".tr)));
    }
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          notify.showLoadingDialog("Restoring courses...".tr);
          var coursesList = "";
          for (var purchaseDetails in purchaseDetailsList) {
            coursesList += purchaseDetails.productID.toString() + ",";
          }
          var response = await CoursesApi().GetCourses(
              {"include": coursesList.substring(0, coursesList.length - 1)});

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Courses Restored Successfully".tr)));
          Get.off(PaymentSuccessScreen(
            "In app purchases",
            response,
            titleText: "Courses restored",
          ));
          for (var singleCourse in response) {
            response.remove_with_id(singleCourse.id);
          }
        } else {}
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }
}
