import 'package:LearnGun/screens/register.dart';
import 'package:LearnGun/widgets/Button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class pleaseLogin extends StatelessWidget {
  final isAppBar;
  const pleaseLogin({this.isAppBar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (isAppBar)
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              )
            : null,
        body: Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("You must login first",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center),
                  SizedBox(height: 15),
                  theme_buttons.material_button("Login".tr, 0.35, onTap: () {
                    Get.to(LoginRegisterScreen());
                  })
                ],
              )),
        ));
  }
}
