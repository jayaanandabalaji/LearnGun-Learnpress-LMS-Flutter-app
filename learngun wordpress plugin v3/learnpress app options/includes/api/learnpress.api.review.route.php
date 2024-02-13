<?php

add_action('rest_api_init', function () {
	$namespace = 'learnpressapp/v1';

	register_rest_route($namespace, 'get-review/', array(
		'methods'             => WP_REST_Server::CREATABLE,
		'callback'            => 'learnpress_get_review',
	));


	register_rest_route($namespace, 'add-review/', array(
		'methods'             => WP_REST_Server::CREATABLE,
		'callback'            => 'learnpress_add_review',
		'permission_callback' => 'validate_token',
	));
});







function learnpress_get_review($request)
{
	$returnList = [];
	foreach (learn_press_get_course_review($request["course_id"], 0, 30)["reviews"] as $review) {
		$temp = $review;

		$user = learn_press_get_user($temp->ID);

		$avatar = $user->get_upload_profile_src();
		$temp->avatar = $avatar;
		$temp->time = human_time_diff(strtotime(get_comment($temp->comment_id)->comment_date), current_time('U')) . " ago";

		unset($temp->user_pass);
		$returnList[] = $temp;
	}

	return $returnList;
}

function learnpress_add_review($request)
{
	$response = array('result' => 'success');
	$user_id    =  (int)validate_token()["data"]["exp"];

	$return     = learn_press_add_course_review(
		array(
			'user_id'   => $user_id,
			'course_id' => $request["course_id"],
			'rate'      => $request["rate"],
			'title'     => $request["title"],
			'content'   => $request["content"]
		)
	);
	$response['comment'] = $return;
	return $response;
}
