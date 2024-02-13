import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:get/get.dart';

import '../Controllers/AuthController.dart';
import '../../widgets/Card.dart';
import '../../widgets/Notify/notify.dart';
import '../Controllers/ProfileController.dart';
import '../utils/constants.dart';

isJsonParsable({required var String}) {
  try {
    json.decode(String);
  } catch (e) {
    return false;
  }
  return true;
}

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final Future<bool> _isAvailableFuture = TheAppleSignIn.isAvailable();

  final AuthController _authController = Get.put(AuthController());
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  final _signupFormKey = GlobalKey<FormState>();
  final _signinFormKey = GlobalKey<FormState>();

  TextEditingController signupNameController = TextEditingController();
  TextEditingController signinNameController = TextEditingController();
  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupPassController = TextEditingController();
  TextEditingController signinPassController = TextEditingController();

  var googlesigninaccount;

  final _signupPasswordVisible = false.obs;
  final _signupConfirmPasswordVisible = false.obs;
  final _signinPasswordVisible = false.obs;

  var GoogleButtonLoading = false.obs;
  var AppleButtonLoading = false.obs;
  var FacebookButtonLoading = false.obs;
  var SignUpButtonLoading = false.obs;
  var SigninButtonLoading = false.obs;

  final signupemailfocus = FocusNode();
  final signuppassfocus = FocusNode();
  final signinpassfocus = FocusNode();
  final signupconfirmpassfocus = FocusNode();

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      GoogleButtonLoading.value = true;
      googlesigninaccount = account;
      _authController.GoogleAuth(googlesigninaccount).then((response) {
        GoogleButtonLoading.value = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                Constants.appName,
                style: TextStyle(fontSize: 20.sp),
              ),
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    text: "Sign up".tr,
                  ),
                  Tab(
                    text: "Sign in".tr,
                  ),
                ],
              ),
            ),
            body: TabBarView(children: [
              ListView(
                padding: EdgeInsets.all(30.h),
                children: [
                  BuildSignup(),
                ],
              ),
              ListView(
                padding: EdgeInsets.all(30.h),
                children: [
                  BuildSignin(),
                ],
              ),
            ])));
  }

  Widget BuildSignup() {
    return Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Create a new account".tr,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 20.h,
            ),
            card.shadow_card(
                TextFormField(
                  controller: signupNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text'.tr;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(signupemailfocus);
                  },
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'Login'.tr),
                ),
                ContainerBorderRadius: 0),
            SizedBox(
              height: 20.h,
            ),
            card.shadow_card(
                TextFormField(
                  focusNode: signupemailfocus,
                  controller: signupEmailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text'.tr;
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email'.tr;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(signuppassfocus);
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: 'Email'.tr),
                ),
                ContainerBorderRadius: 0),
            SizedBox(
              height: 20.h,
            ),
            card.shadow_card(Obx(() {
              return TextFormField(
                focusNode: signuppassfocus,
                controller: signupPassController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text'.tr;
                  }
                  if (value.length < 6) {
                    return 'Password length cannot be smaller than 6'.tr;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(signupconfirmpassfocus);
                },
                keyboardType: TextInputType.text,
                obscureText: !_signupPasswordVisible
                    .value, //This will obscure text dynamically
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Password'.tr,
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _signupPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      _signupPasswordVisible.value =
                          !_signupPasswordVisible.value;
                    },
                  ),
                ),
              );
            }), ContainerBorderRadius: 0),
            SizedBox(
              height: 20.h,
            ),
            card.shadow_card(Obx(() {
              return TextFormField(
                focusNode: signupconfirmpassfocus,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text'.tr;
                  }
                  if (value != signupPassController.text) {
                    return 'Password and confirm password doesnt match'.tr;
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) async {
                  if (!SignUpButtonLoading.value) {
                    if (_signupFormKey.currentState!.validate()) {
                      _signupFormKey.currentState!.save();
                      SignUpButtonLoading.value = true;
                      _authController
                          .signup(
                              signupNameController.text,
                              signupPassController.text,
                              signupEmailController.text)
                          .then((response) {
                        SignUpButtonLoading.value = false;
                      });
                    }
                  }
                },
                keyboardType: TextInputType.text,
                obscureText: !_signupConfirmPasswordVisible
                    .value, //This will obscure text dynamically
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Confirm Password'.tr,
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _signupConfirmPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () async {
                      _signupConfirmPasswordVisible.value =
                          !_signupConfirmPasswordVisible.value;
                    },
                  ),
                ),
              );
            }), ContainerBorderRadius: 0),
            SizedBox(
              height: 20.h,
            ),
            FractionallySizedBox(
                widthFactor: 1, // means 100%, you can change this to 0.8 (80%)
                child: MaterialButton(
                  color: Constants.primary_color,
                  textColor: Colors.white,
                  padding: EdgeInsets.only(top: 15.h, bottom: 15.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  onPressed: () async {
                    if (!SignUpButtonLoading.value) {
                      if (_signupFormKey.currentState!.validate()) {
                        _signupFormKey.currentState!.save();
                        SignUpButtonLoading.value = true;
                        _authController
                            .signup(
                          signupNameController.text,
                          signupPassController.text,
                          signupEmailController.text,
                        )
                            .then((response) {
                          SignUpButtonLoading.value = false;
                        });
                      }
                    }
                  },
                  child: Obx(() {
                    if (SignUpButtonLoading.value) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    }
                    return Text("Sign up".tr,
                        style: TextStyle(fontSize: 17.sp));
                  }),
                )),
            SizedBox(
              height: 20.h,
            ),
            SocialLoginButtons(),
          ],
        ));
  }

  Widget BuildSignin() {
    return Form(
      key: _signinFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Login with your existing account".tr,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 20.h,
          ),
          card.shadow_card(
              TextFormField(
                controller: signinNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text'.tr;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(signinpassfocus);
                },
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: 'Login'.tr),
              ),
              ContainerBorderRadius: 0),
          SizedBox(
            height: 20.h,
          ),
          card.shadow_card(Obx(() {
            return TextFormField(
              focusNode: signinpassfocus,
              controller: signinPassController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text'.tr;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (value) async {
                if (!SigninButtonLoading.value) {
                  if (_signinFormKey.currentState!.validate()) {
                    _signinFormKey.currentState!.save();
                    SigninButtonLoading.value = true;
                    _authController.Signin(signinNameController.text,
                            signinPassController.text)
                        .then((response) {
                      SigninButtonLoading.value = false;
                    });
                  }
                }
              },
              keyboardType: TextInputType.text,
              obscureText: !_signinPasswordVisible
                  .value, //This will obscure text dynamically
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: 'Password'.tr,
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _signinPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    _signinPasswordVisible.value =
                        !_signinPasswordVisible.value;
                  },
                ),
              ),
            );
          }), ContainerBorderRadius: 0),
          SizedBox(
            height: 20.h,
          ),
          FractionallySizedBox(
              widthFactor: 1, // means 100%, you can change this to 0.8 (80%)
              child: MaterialButton(
                  color: Constants.primary_color,
                  textColor: Colors.white,
                  padding: EdgeInsets.only(top: 15.h, bottom: 15.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  onPressed: () async {
                    if (!SigninButtonLoading.value) {
                      if (_signinFormKey.currentState!.validate()) {
                        _signinFormKey.currentState!.save();
                        SigninButtonLoading.value = true;
                        _authController.Signin(signinNameController.text,
                                signinPassController.text)
                            .then((response) {
                          SigninButtonLoading.value = false;
                        });
                      }
                    }
                  },
                  child: Obx(() {
                    if (SigninButtonLoading.value) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    }
                    return Text("Sign in".tr,
                        style: TextStyle(fontSize: 17.sp));
                  }))),
          SizedBox(
            height: 20.h,
          ),
          SocialLoginButtons()
        ],
      ),
    );
  }

  Widget SocialLoginButtons() {
    return SizedBox(
      width: Get.width,
      child: Column(children: [
        Row(children: <Widget>[
          const Expanded(
              child: Divider(
            color: Colors.black,
            thickness: 1,
          )),
          SizedBox(
            width: 10.w,
          ),
          Text(
            "OR".tr,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(
            width: 10.w,
          ),
          const Expanded(
              child: Divider(
            color: Colors.black,
            thickness: 1,
          )),
        ]),
        SizedBox(
          height: 20.h,
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: Get.width * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GoogleSignInButton(),
                    FacebookSignInButton(),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              FutureBuilder<bool>(
                future: _isAvailableFuture,
                builder: (context, isAvailableSnapshot) {
                  if (!isAvailableSnapshot.hasData) {
                    return Container(child: const CircularProgressIndicator());
                  }
                  return isAvailableSnapshot.data!
                      ? AppleSigninButton()
                      : Container();
                },
              )
            ]),
        SizedBox(
          height: 20.h,
        ),
        SizedBox(
            width: 200.w,
            child: OutlinedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                            child: ChangeLanguageDialog(),
                          ));
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                            "assets/flags/" + Get.locale!.languageCode + ".png",
                            height: 17.h,
                            width: 30.w,
                            fit: BoxFit.contain),
                        SizedBox(width: 10.w),
                        Text(getLanguageName(),
                            style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.w700))
                      ],
                    ))))
      ]),
    );
  }

  getLanguageName() {
    for (var language in Constants.translationSwitch) {
      if (Get.locale!.languageCode == language[1]) {
        return language[0];
      }
    }
    return "";
  }

  Widget FacebookSignInButton() {
    return SizedBox(
        height: 45.h,
        width: 45.w,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () async {
                if (!FacebookButtonLoading.value) {
                  FacebookButtonLoading.value = true;
                  final LoginResult result = await FacebookAuth.instance
                      .login(); // by default we request the email and the public profile
                  if (result.status == LoginStatus.success) {
                    final userData = await FacebookAuth.instance.getUserData();
                    await _authController.facebookAuth(userData);
                  } else {}
                  FacebookButtonLoading.value = false;
                }
              },
              child: ExtendedImage.asset(
                "assets/facebook_logo.png",
                height: 45.h,
                shape: BoxShape.circle,
              ),
            ),
            Obx(() {
              if (FacebookButtonLoading.value) {
                return Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 30.h,
                    width: 30.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.w,
                    ),
                  ),
                );
              }
              return Container();
            }),
          ],
        ));
  }

  Widget AppleSigninButton() {
    return Center(
        child: Stack(
      children: [
        GestureDetector(
          onTap: () async {
            AppleButtonLoading.value = true;
            final AuthorizationResult result =
                await TheAppleSignIn.performRequests([
              const AppleIdRequest(
                  requestedScopes: [Scope.email, Scope.fullName])
            ]);

            switch (result.status) {
              case AuthorizationStatus.authorized:
                AppleIdCredential? credential = result.credential;
                await _authController.AppleAuth(credential);
                break;
              case AuthorizationStatus.error:
                AppleButtonLoading.value = false;
                break;
              case AuthorizationStatus.cancelled:
                break;
            }
            AppleButtonLoading.value = false;
          },
          child:
              ExtendedImage.asset("assets/apple.png", width: Get.width * 0.7),
        ),
        Obx(() {
          if (AppleButtonLoading.value) {
            return Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 30.h,
                width: 30.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3.w,
                ),
              ),
            );
          }
          return Container();
        }),
      ],
    ));
  }

  Widget GoogleSignInButton() {
    return SizedBox(
        height: 45.h,
        width: 45.w,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () async {
                if (!GoogleButtonLoading.value) {
                  try {
                    await _googleSignIn.signIn();
                  } catch (error) {
                    notify.showDialog("Error", error.toString());
                  }
                }
              },
              child: ExtendedImage.asset(
                "assets/google_logo.png",
                height: 45.h,
                shape: BoxShape.circle,
              ),
            ),
            Obx(() {
              if (GoogleButtonLoading.value) {
                return Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 30.h,
                    width: 30.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.w,
                    ),
                  ),
                );
              }
              return Container();
            }),
          ],
        ));
  }

  Widget ChangeLanguageDialog() {
    return SizedBox(
        height: 200,
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
}
