import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/ProfileAPI.dart';
import '../../utils/constants.dart';
import '../../widgets/Button.dart';
import '../../widgets/Card.dart';
import '../../Models/Profile.dart';

class EditProfile extends StatefulWidget {
  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  var image = File("").obs;
  var isUpdateLoading = false.obs;

  late var _getUser;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getUser = ProfileApi.GetProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Edit profile".tr),
      ),
      body: FutureBuilder(
        future: _getUser,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            Profile profile = snapshot.data as Profile;
            Future.delayed(Duration.zero, () {
              firstNameController.text = profile.first_name;
              lastNameController.text = profile.last_name;
              displayNameController.text = profile.name;
              bioController.text = profile.description;
              facebookController.text = profile.social.facebook;
              youtubeController.text = profile.social.youtube;
              linkedinController.text = profile.social.linkedin;
              twitterController.text = profile.social.twitter;
            });
            return ListView(
              padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 30.h),
              children: [
                give_padding(
                  SizedBox(
                    height: 130.h,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Obx(() {
                              if (image.value.path != "") {
                                return Center(
                                    child: ExtendedImage.file(
                                  image.value,
                                  shape: BoxShape.circle,
                                  height: 130.h,
                                  width: 130.w,
                                ));
                              }
                              if (profile.avatar_url == "") {
                                return Center(
                                    child: ExtendedImage.asset("assets/user.png", height: 130.h, width: 130.w));
                              }
                              return Center(
                                  child: ExtendedImage.network(
                                profile.avatar_url,
                                shape: BoxShape.circle,
                                height: 130.h,
                                width: 130.w,
                                cache: false,
                              ));
                            }),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 130.h,
                            width: 130.w,
                            child: Align(
                              alignment: const Alignment(1.3, 1),
                              child: ElevatedButton(
                                onPressed: () {
                                  SelectAvatar();
                                },
                                child: const Icon(Icons.create_sharp, color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: EdgeInsets.all(5.h),
                                  primary: Constants.primary_color, // <-- Button color
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                give_padding(card.shadow_card(
                    TextFormField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          labelText: 'First Name'.tr),
                    ),
                    ContainerBorderRadius: 0)),
                give_padding(card.shadow_card(
                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          labelText: 'Last Name'.tr),
                    ),
                    ContainerBorderRadius: 0)),
                give_padding(card.shadow_card(
                    TextFormField(
                      controller: displayNameController,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          labelText: 'Display Name'.tr),
                    ),
                    ContainerBorderRadius: 0)),
                give_padding(card.shadow_card(
                    TextFormField(
                      controller: bioController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          labelText: 'Biographical Info'.tr),
                      minLines: 4,
                      maxLines: 10,
                    ),
                    ContainerBorderRadius: 0)),
                give_padding(card.shadow_card(
                    TextFormField(
                      controller: facebookController,
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(10.h),
                            child: const FaIcon(
                              FontAwesomeIcons.facebook,
                            ),
                          ),
                          labelText: 'Facebook'),
                    ),
                    ContainerBorderRadius: 0)),
                give_padding(card.shadow_card(
                    TextFormField(
                      controller: youtubeController,
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(10.h),
                            child: const FaIcon(
                              FontAwesomeIcons.youtube,
                            ),
                          ),
                          labelText: 'Youtube'),
                    ),
                    ContainerBorderRadius: 0)),
                give_padding(card.shadow_card(
                    TextFormField(
                      controller: linkedinController,
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(10.h),
                            child: const FaIcon(
                              FontAwesomeIcons.linkedin,
                            ),
                          ),
                          labelText: 'Linkedin'),
                    ),
                    ContainerBorderRadius: 0)),
                give_padding(card.shadow_card(
                    TextFormField(
                      controller: twitterController,
                      decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(10.h),
                            child: const FaIcon(
                              FontAwesomeIcons.twitter,
                            ),
                          ),
                          labelText: 'Twitter'),
                    ),
                    ContainerBorderRadius: 0)),
                Obx(() {
                  if (isUpdateLoading.value) {
                    return theme_buttons.material_button("", 1, is_circular: true);
                  }
                  return give_padding(theme_buttons.material_button("Update".tr, 1, onTap: () async {
                    isUpdateLoading.value = true;
                    await ProfileApi.edit_profile(
                        image.value,
                        firstNameController.text,
                        lastNameController.text,
                        displayNameController.text,
                        bioController.text,
                        facebookController.text,
                        youtubeController.text,
                        linkedinController.text,
                        twitterController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile updated successfully'.tr),
                      ),
                    );

                    isUpdateLoading.value = false;
                  }));
                }),
                changePassword()
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  var currentPasswordVisible = false.obs;
  var newPasswordVisible = false.obs;
  var newPasswordconfirmVisible = false.obs;
  var isChangePasswordLoading = false.obs;
  final _passwordKey = GlobalKey<FormState>();

  Widget changePassword() {
    return Form(
        key: _passwordKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.h,
            ),
            give_padding(Text(
              "Change password".tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            )),
            SizedBox(
              height: 10.h,
            ),
            give_padding(card.shadow_card(Obx(() {
              return TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text'.tr;
                    }
                    return null;
                  },
                  obscureText: !currentPasswordVisible.value,
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'Current Password'.tr,
                    suffixIcon: IconButton(
                      icon: (currentPasswordVisible.value)
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                      onPressed: () {
                        currentPasswordVisible.value = !currentPasswordVisible.value;
                      },
                    ),
                  ));
            }), ContainerBorderRadius: 0)),
            give_padding(card.shadow_card(Obx(() {
              return TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text'.tr;
                    }
                    return null;
                  },
                  obscureText: !newPasswordVisible.value,
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'New Password'.tr,
                    suffixIcon: IconButton(
                      icon:
                          (newPasswordVisible.value) ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                      onPressed: () {
                        newPasswordVisible.value = !newPasswordVisible.value;
                      },
                    ),
                  ));
            }), ContainerBorderRadius: 0)),
            give_padding(card.shadow_card(Obx(() {
              return TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter some text'.tr;
                    }
                    if (value != newPasswordController.text) {
                      return 'Password and confirm password doesnt match'.tr;
                    }
                    return null;
                  },
                  obscureText: !newPasswordconfirmVisible.value,
                  controller: newPasswordConfirmController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'Confirm New Password'.tr,
                    suffixIcon: IconButton(
                      icon: (newPasswordconfirmVisible.value)
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                      onPressed: () {
                        newPasswordconfirmVisible.value = !newPasswordconfirmVisible.value;
                      },
                    ),
                  ));
            }), ContainerBorderRadius: 0)),
            Obx(() {
              if (isChangePasswordLoading.value) {
                return theme_buttons.material_button("", 1, is_circular: true);
              }
              return give_padding(theme_buttons.material_button("Change password".tr, 1, onTap: () async {
                if (_passwordKey.currentState!.validate()) {
                  isChangePasswordLoading.value = true;
                  var response = await ProfileApi.change_password(
                      currentPasswordController.text, newPasswordConfirmController.text);
                  if (response["success"]) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Password updated succesfully.".tr)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Current password wrong.".tr)));
                  }

                  isChangePasswordLoading.value = false;
                }
              }));
            }),
          ],
        ));
  }

  static Widget give_padding(Widget childWidget) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10.h),
      child: childWidget,
    );
  }

  SelectAvatar() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? SelectedImage = await _picker.pickImage(source: ImageSource.gallery);
    image.value = File(SelectedImage!.path);
    /*image.value = await ImageCropper().cropImage(
            cropStyle: CropStyle.circle,
            sourcePath: SelectedImage!.path,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            androidUiSettings: AndroidUiSettings(
                toolbarTitle: 'Avatar'.tr,
                toolbarColor: Constants.primary_color,
                toolbarWidgetColor: Colors.white,
                activeControlsWidgetColor: Constants.primary_color,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            iosUiSettings: const IOSUiSettings(
              minimumAspectRatio: 1.0,
            )) ??
        File(SelectedImage.path);*/
  }
}
