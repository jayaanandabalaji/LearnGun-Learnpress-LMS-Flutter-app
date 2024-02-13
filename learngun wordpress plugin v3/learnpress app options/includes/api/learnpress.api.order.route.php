<?php
add_action('rest_api_init', function () {
    $namespace = 'learnpressapp/v1';

    register_rest_route($namespace, 'create-order/', array(
        'methods'  => WP_REST_Server::ALLMETHODS,
        'callback' => 'learnpress_create_order',
    ));
    register_rest_route($namespace, 'get-orders/', array(
        'methods'  => WP_REST_Server::ALLMETHODS,
        'callback' => 'learnpress_get_orders',
        'permission_callback' => 'validate_token',
    ));
});

function learnpress_create_order($request)
{
    $app_settings = get_option('learnpress_app');
    $parameters = $request->get_params();
    $bearertoken = str_replace("Bearer ", "", $request->get_header('authorization'));
    if ($bearertoken != $app_settings["license_key"]) {
        return new WP_Error('license_failed', 'License Verification Failed.', array(
            'status' => 401
        ));
    }
    if (!class_exists('LP_Jwt_Public')) {
        return new WP_Error('learnpress_error', 'Learnpress not installed or misconfigured.', array(
            'status' => 401
        ));
    }
    $courses = $request["courses"];
    $user_id = $request["user_id"];
    $payment_method = $request["payment_method"];
    $total = 0;
    foreach ($courses as $item) {
        $total += learn_press_get_course($item)->get_price();
    }
    $order = new LP_Order();
    $order->set_status(learn_press_default_order_status('lp-'));
    $order->set_total($total);
    $order->set_subtotal($total);
    $order->set_user_ip_address(learn_press_get_ip());
    $order->set_user_agent(learn_press_get_user_agent());
    $order->set_created_via('checkout');
    $order->set_user_id($user_id);

    $order_id = $order->save();
    foreach ($courses as $item) {
        $order->add_item($item);
    }

    $order->payment_complete();
    update_post_meta($order_id, '_payment_method', $payment_method);
    update_post_meta($order_id, '_payment_method_title', $payment_method);
    $return = array();
    $return["success"] = true;
    $return["order_id"] = $order_id;
    $return["payment_method"] = $payment_method;
    $return["subtotal"] = $total;
    $return["total"] = $total;
    $return["order_date"] = date("Y/m/d");
    $course_details = [];
    foreach ($courses as $item) {
        $course_details[] = (array(
            'title' => learn_press_get_course($item)->get_title(),
            'price' => floatval(learn_press_get_course($item)->get_price()),
            'origin_price' => floatval(learn_press_get_course($item)->get_origin_price()),
            'sale_price' => floatval(learn_press_get_course($item)->get_sale_price())
        ));
    }
    $return["courses"] = $course_details;
    return $return;
}

function learnpress_get_orders($request)
{
    $user_id = (int)validate_token()["data"]["exp"];
    $curd       = new LP_User_CURD();
    $orders = $curd->get_orders($user_id, array('group_by_order' => true));
    $response = [];
    foreach ($orders as $order_id => $course_ids) {
        $child_order = learn_press_get_order($order_id);
        $response[] = array('items' => learn_press_get_order($order_id), 'id' => $order_id, 'status' => $child_order->get_status(), 'key' => $child_order->get_order_key(), 'method' => get_post_meta($order_id, '_payment_method'), 'date' => ($child_order->get_order_date()), 'total' => $child_order->get_formatted_order_total());
    }
    return $response;
}
