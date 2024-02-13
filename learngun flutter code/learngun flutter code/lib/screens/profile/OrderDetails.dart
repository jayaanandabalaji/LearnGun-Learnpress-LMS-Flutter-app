import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Models/GetOrders.dart';
import '../../utils/Extensions.dart';
import '../../widgets/Card.dart';
import '../../utils/constants.dart';
import '../Coursesloading.dart';

class OrderDetails extends StatefulWidget {
  final GetOrders order;
  const OrderDetails(this.order);
  @override
  OrderDetailsState createState() => OrderDetailsState();
}

class OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order #" + widget.order.id.toString())),
      body: ListView(
        children: [
          build_title("Order".tr + " " + "Details".tr),
          SizedBox(
            height: 8.h,
          ),
          give_padding(card.shadow_card(Container(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
              child: Column(
                children: [
                  for (var item in widget.order.items.order_items_loaded.keys.toList()) build_item(item),
                ],
              )))),
          SizedBox(
            height: 15.h,
          ),
          give_padding(Row(
            children: [
              Text(
                "Order key".tr + ": ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
              ),
              Text(
                widget.order.key,
                style: TextStyle(fontSize: 17.sp),
              )
            ],
          )),
          SizedBox(
            height: 10.h,
          ),
          give_padding(Row(
            children: [
              Text(
                "Order status".tr + ": ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
              ),
              Text(
                widget.order.status.toCapitalized(),
                style: TextStyle(
                    fontSize: 17.sp,
                    color: (widget.order.status == "failed" || widget.order.status == "cancelled")
                        ? Colors.red
                        : (widget.order.status == "processing" || widget.order.status == "pending")
                            ? Colors.orange
                            : Colors.green),
              )
            ],
          )),
          SizedBox(
            height: 10.h,
          ),
          give_padding(card.shadow_card(Container(
            padding: EdgeInsets.all(20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: Get.width * 0.4,
                  decoration: BoxDecoration(
                      border: Border(
                    right: BorderSide(
                      //                   <--- left side
                      color: Colors.black.withOpacity(0.1),
                      width: 2.w,
                    ),
                  )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date".tr,
                        style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        widget.order.date,
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Constants.primary_color),
                      )
                    ],
                  ),
                ),
                if (widget.order.method[0] != "")
                  Container(
                    padding: EdgeInsets.fromLTRB(10.w, 0, 0, 0),
                    width: Get.width * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment method".tr,
                          style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Text(
                          widget.order.method[0],
                          style:
                              TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Constants.primary_color),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ))),
          SizedBox(
            height: 20.h,
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subtotal".tr,
                    style: TextStyle(color: Colors.grey, fontSize: 18.sp),
                  ),
                  Text(
                    HtmlUnescape().convert(widget.order.total),
                    style: TextStyle(color: Colors.grey, fontSize: 18.sp),
                  )
                ],
              )),
          SizedBox(
            height: 20.h,
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total".tr,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                  Text(
                    HtmlUnescape().convert(widget.order.total),
                    style: TextStyle(fontSize: 20.sp),
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget build_item(var item) {
    ItemLoadedBean orderItem = ItemLoadedBean.fromJson(widget.order.items.order_items_loaded[item]);
    return Container(
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
          //                   <--- left side
          color: (item !=
                  widget.order.items.order_items_loaded.keys
                      .toList()[widget.order.items.order_items_loaded.keys.length - 1])
              ? Colors.black.withOpacity(0.1)
              : Colors.transparent,
          width: 2.w,
        ),
      )),
      padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(CourseLoading(orderItem.course_id));
            },
            child: SizedBox(
              width: Get.width * 0.7,
              child: Text(
                HtmlUnescape().convert(orderItem.name),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
                maxLines: 2,
              ),
            ),
          ),
          Text(
            Constants.currency + orderItem.subtotal,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green),
          )
        ],
      ),
    );
  }

  static Widget give_padding(childWidget) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
      child: childWidget,
    );
  }

  static Widget build_title(String title) {
    return give_padding(Text(
      title,
      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
    ));
  }
}
