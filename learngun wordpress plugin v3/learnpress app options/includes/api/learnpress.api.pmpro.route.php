<?php

add_action('rest_api_init', function () {
	register_rest_route('learnpressapp/v1', 'memberships', array(
		'methods'  => 'GET',
		'callback' => 'get_lp_app_memberships',
		'permission_callback' => 'validate_token',
	));

	register_rest_route('learnpressapp/v1', 'enroll-membership', array(
		'methods'  => 'GET',
		'callback' => 'enroll_lp_app_memberships',
	));
});

function enroll_lp_app_memberships($request)
{
	global $wp, $wpdb;
	$app_settings = get_option('learnpress_app');
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
	$user_id = $request['user_id'];
	$membership_id = $request['membership_id'];
	foreach (pmpro_getAllLevels(false, true) as $plan) {
		cancel_lp_order_membership($user_id, $plan->id);
	}
	$morder = new MemberOrder();
	$morder->user_id = $user_id;
	$morder->membership_id = $membership_id;
	$pmpro_level = $wpdb->get_row("SELECT * FROM $wpdb->pmpro_membership_levels WHERE id = '" . $membership_id . "' LIMIT 1");
	$pmpro_level = apply_filters("pmpro_checkout_level", $pmpro_level);
	$startdate = apply_filters("pmpro_checkout_start_date", "'" . current_time("mysql") . "'", $morder->user_id, $pmpro_level);
	$enddate = "'" . date("Y-m-d", strtotime("+ " . $pmpro_level->expiration_number . " " . $pmpro_level->expiration_period, current_time("timestamp"))) . "'";
	$custom_level = array(
		'user_id'           => $morder->user_id,
		'membership_id'     => $pmpro_level->id,
		'code_id'           => '',
		'initial_payment'   => $pmpro_level->initial_payment,
		'billing_amount'    => $pmpro_level->billing_amount,
		'cycle_number'      => $pmpro_level->cycle_number,
		'cycle_period'      => $pmpro_level->cycle_period,
		'billing_limit'     => $pmpro_level->billing_limit,
		'trial_amount'      => $pmpro_level->trial_amount,
		'trial_limit'       => $pmpro_level->trial_limit,
		'startdate'         => $startdate,
		'enddate'           => $enddate
	);
	$morder->InitialPayment = $pmpro_level->initial_payment;  //not the initial payment, but the order class is expecting this
	$morder->PaymentAmount = $pmpro_level->initial_payment;
	$morder->expirationmonth = get_user_meta($user_id, "pmpro_ExpirationMonth", true);
	$morder->expirationyear = get_user_meta($user_id, "pmpro_ExpirationYear", true);
	$morder->ExpirationDate = $morder->expirationmonth . $morder->expirationyear;
	$morder->ExpirationDate_YdashM = $morder->expirationyear . "-" . $morder->expirationmonth;
	if (pmpro_changeMembershipLevel($custom_level, $morder->user_id, 'changed')) {
		$morder->status = "success";
		$morder->saveOrder();
	}
	$morder->getMemberOrderByID($morder->id);
	do_action('pmpro_subscription_payment_completed', $morder);

	return $morder;
}

function get_lp_app_memberships($request)
{
	$user_id = (int)validate_token()["data"]["exp"];
	$plans = array_map('change_membership_app_api', pmpro_getAllLevels(false, true));
	return array('plans' => array_values($plans), 'membership' => pmpro_getMembershipLevelForUser($user_id));
}

function change_membership_app_api($membership)
{
	$returnArr = $membership;
	$returnArr->categories = get_option('LP_app_pmpro_categories_' . $membership->id, 0);
	return $returnArr;
}


add_action('pmpro_save_membership_level', 'LP_app_pmpro_save_settings');
function LP_app_pmpro_save_settings($level_id)
{
	$categories = $_REQUEST['category'];
	update_option(
		'LP_app_pmpro_categories_' . $level_id,
		$categories
	);
	return $level_id;
}

add_action(
	'pmpro_after_change_membership_level',
	'create_lp_orders_when_change_membership_level_app',
	11,
	3
);
add_action(
	'pmpro_membership_post_membership_expiry',
	'cancel_lp_order_membership',
	10,
	2
);
function create_lp_orders_when_change_membership_level_app($level_id = 0, $user_id = 0, $cancel_level = 0)
{

	global $wpdb;

	if (!empty($cancel_level)) { // Cancel level
		cancel_lp_order_membership($user_id, $cancel_level);
	}
	if (!empty($level_id) && !empty($user_id)) {
		$pmpro_level = $wpdb->get_row("SELECT * FROM $wpdb->pmpro_membership_levels WHERE id = '" . $level_id . "' LIMIT 1");
		$categories = get_option('LP_app_pmpro_categories_' . $level_id, 0);
		$courses = [];
		if (in_array("All Categories", $categories)) {
			$args = array(
				'post_type' => 'lp_course',
			);
			$posts = get_posts($args);
			foreach ($posts as $post) {
				array_push($courses, $post->ID);
			}
		} else {
			foreach ($categories as $category) {
				$args = array(
					'post_type' => 'lp_course',
					'tax_query' => array(
						array(
							'taxonomy' => 'course_category',
							'field'    => 'name',
							'terms'    => $category,
						),
					),
				);
				$posts = get_posts($args);
				foreach ($posts as $post) {
					array_push($courses, $post->ID);
				}
			}
		}

		$payment_method = 'Memberships';
		$total = $pmpro_level->initial_payment;
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
		update_post_meta($order_id, '_lp_pmpro_level_app', $level_id);
	}
}

function cancel_lp_order_membership($user_id = 0, $membership_id = 0)
{
	global $wpdb;
	$query = $wpdb->prepare(
		"SELECT p_meta.post_id FROM $wpdb->postmeta as p_meta
					WHERE p_meta.meta_key = '_user_id'
					AND p_meta.meta_value = %d
					AND p_meta.post_id IN
					(SELECT p_meta.post_id
						FROM $wpdb->postmeta as p_meta
						WHERE p_meta.meta_key = '_lp_pmpro_level_app'
						AND p_meta.meta_value = %d)
						ORDER BY p_meta.post_id DESC
					LIMIT %d",
		$user_id,
		$membership_id,
		1
	);

	$lpOrder = $wpdb->get_row($query);
	if (isset($lpOrder->post_id)) {
		$order = learn_press_get_order($lpOrder->post_id);
		$order->update_status('cancelled');
	}
}
