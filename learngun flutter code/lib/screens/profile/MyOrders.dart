import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';

import '../../Models/GetOrders.dart';
import '../../screens/profile/OrderDetails.dart';
import '../../services/OrderAPI.dart';
import '../../widgets/Button.dart';
import '../../widgets/Card.dart';
import '../../utils/Extensions.dart';
import '../../widgets/NoData.dart';

class MyOrders extends StatefulWidget {
  @override
  MyOrdersState createState() => MyOrdersState();
}

class MyOrdersState extends State<MyOrders> {
  late var _getOrders;
  @override
  void initState() {
    super.initState();
    _getOrders = OrderApi.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Orders".tr,
        ),
      ),
      body: FutureBuilder(
        future: _getOrders,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if ((snapshot.data as dynamic)!.length == 0) {
              return NoData.noData("no_order", "You dont have any orders yet.".tr, imageHeight: 120);
            }
            return ListView(
              padding: EdgeInsets.all(10.h),
              children: [for (var order in snapshot.data as dynamic) build_order(order)],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  static Widget build_order(GetOrders order) {
    return card.shadow_card(Container(
      width: Get.width,
      padding: EdgeInsets.all(10.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order".tr + " #" + order.id.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
              ),
              Text(
                order.date,
                style: TextStyle(color: Colors.grey, fontSize: 17.sp),
              )
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Courses".tr + ": ",
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                  ),
                  Text(
                    order.items.order_items_loaded.length.toString(),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp),
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    "Total amount".tr + ": ",
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                  ),
                  Text(
                    HtmlUnescape().convert(order.total),
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.sp),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              theme_buttons.TagsButton("Details".tr, onTap: () {
                Get.to(OrderDetails(order));
              }),
              Text(
                order.status.toCapitalized(),
                style: TextStyle(
                    color: (order.status == "failed" || order.status == "cancelled")
                        ? Colors.red
                        : (order.status == "processing" || order.status == "pending")
                            ? Colors.orange
                            : Colors.green,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    ));
  }
}
