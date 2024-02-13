<?php

use \Firebase\JWT\JWT;

add_action('rest_api_init', function () {
	$namespace = 'learnpressapp/v1';

	register_rest_route($namespace, 'quiz/finish/', array(
		'methods'             => WP_REST_Server::CREATABLE,
		'callback'            => 'submit_quiz_app',
		'permission_callback' => 'validate_token',
	));
});







function validate_token($output = true)
{
	/*
		 * Looking for the HTTP_AUTHORIZATION header, if not present just
		 * return the user.
		 */
	$auth = isset($_SERVER['HTTP_AUTHORIZATION']) ? sanitize_text_field($_SERVER['HTTP_AUTHORIZATION']) : false;

	/* Double check for different auth header string (server dependent) */
	if (!$auth) {
		$auth = isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION']) ? sanitize_text_field($_SERVER['REDIRECT_HTTP_AUTHORIZATION']) : false;
	}

	if (!$auth) {
		return new WP_Error(
			'lp_jwt_auth_no_auth_header',
			esc_html__('Authorization header not found.', 'learnpress'),
			array(
				'status' => 401,
			)
		);
	}

	/*
		 * The HTTP_AUTHORIZATION is present verify the format
		 * if the format is wrong return the user.
		 */
	list($token) = sscanf($auth, 'Bearer %s');
	if (!$token) {
		return new WP_Error(
			'lp_jwt_auth_bad_auth_header',
			esc_html__('Authentication token is missing.', 'learnpress'),
			array(
				'status' => 401,
			)
		);
	}

	/** Get the Secret Key */
	$secret_key = SECURE_AUTH_KEY;

	if (!$secret_key) {
		return new WP_Error(
			'lp_jwt_auth_bad_config',
			esc_html__('LearnPress JWT is not configurated properly, please contact the admin', 'learnpress'),
			array(
				'status' => 401,
			)
		);
	}

	/** Try to decode the token */
	try {
		$token = JWT::decode($token, $secret_key, array('HS256'));

		/** The Token is decoded now validate the iss */
		if ($token->iss != get_bloginfo('url')) {
			return new WP_Error(
				'lp_jwt_auth_bad_iss',
				esc_html__('The iss do not match with this server', 'learnpress'),
				array(
					'status' => 401,
				)
			);
		}

		/** So far so good, validate the user id in the token */
		if (!isset($token->data->user->id)) {
			return new WP_Error(
				'lp_jwt_auth_bad_request',
				esc_html__('User ID not found in the token', 'learnpress'),
				array(
					'status' => 401,
				)
			);
		}

		if (!isset($token->exp)) {
			return new WP_Error(
				'rest_authentication_missing_token_expiration',
				esc_html__('Token must have an expiration.', 'learnpress'),
				array(
					'status' => 401,
				)
			);
		}

		if (time() > $token->exp) {
			return new WP_Error(
				'rest_authentication_token_expired',
				esc_html__('Token has expired.', 'learnpress'),
				array(
					'status' => 401,
				)
			);
		}

		/** Everything looks good return the decoded token if the $output is false */
		if (!$output) {
			return true;
		}

		/** If the output is true return an answer to the request to show it */
		return array(
			'code'    => 'lp_jwt_auth_valid_token',
			'message' => esc_html__('Valid access token.', 'learnpress'),
			'data'    => array(
				'status' => 200,
				'exp'    => $token->data->user->id,
			),
		);
	} catch (Exception $e) {
		return false;
		return new WP_Error(
			'lp_jwt_auth_invalid_token',
			$e->getMessage(),
			array(
				'status' => 401,
			)
		);
	}
}


function submit_quiz_app($request)
{

	$response = array(
		'status'  => 'error',
		'message' => '',
	);

	try {
		$user_id    =  (int)validate_token()["data"]["exp"];
		$item_id    = $request['id'] ?? 0;
		global $wpdb;
		$course_id  = absint($wpdb->get_var(
			$wpdb->prepare(
				"SELECT c.ID FROM {$wpdb->posts} c
					INNER JOIN {$wpdb->learnpress_sections} s ON c.ID = s.section_course_id
					INNER JOIN {$wpdb->learnpress_section_items} si ON si.section_id = s.section_id
					WHERE si.item_id = %d ORDER BY si.section_id DESC LIMIT 1
					",
				$item_id
			)
		));
		$answered   = $request['answered'] ?? [];
		$time_spend = $request['time_spend'] ?? 0;
		$user       = learn_press_get_user($user_id);
		$course     = learn_press_get_course($course_id);
		if (!$course) {
			throw new Exception('Course is invalid!');
		}

		// Course is no required enroll
		if ($course->is_no_required_enroll()) {
			$no_required_enroll = new LP_Course_No_Required_Enroll($course);

			// Use for Review Quiz.
			$quiz = learn_press_get_quiz($item_id);

			if (!$quiz) {
				throw new Exception(__('Quiz is invalid!', 'learnpress'));
			}

			$result = $no_required_enroll->get_result_quiz($quiz, $answered);

			// Set time spent
			$interval             = new LP_Duration($time_spend);
			$interval             = $interval->to_timer();
			$result['time_spend'] = $interval;
			// End

			$result['status'] = LP_ITEM_COMPLETED;
			//$result['answered']  = $result['questions'];
			$result['attempts']  = [];
			$result['results']   = $result;
			$response['status']  = 'success';
			$response['results'] = $result;

			//learn_press_setcookie( 'quiz_submit_status_' . $course_id . '_' . $item_id . '', 'completed', time() + ( 7 * DAY_IN_SECONDS ), false );

			return rest_ensure_response($response);
		}

		$user_course = $user->get_course_data($course_id);

		// Course required enroll
		if (!$user_course) {
			throw new Exception('User not enrolled course!');
		}

		$user_quiz = $user_course->get_item($item_id);

		if (!$user_quiz) {
			throw new Exception();
		}

		$end_time = gmdate('Y-m-d H:i:s', strtotime($user_quiz->get_start_time('mysql') . " + $time_spend second"));
		$user_quiz->set_end_time($end_time);

		// For case save result when check instant answer
		$result_instant_check = LP_User_Items_Result_DB::instance()->get_result($user_quiz->get_user_item_id());
		if ($result_instant_check) {
			foreach ($result_instant_check['questions'] as $question_answer_id => $question_answer) {
				if (!empty($question_answer['answered'])) {
					$answered[$question_answer_id] = $question_answer['answered'];
				}
			}
		}

		// Calculate quiz result and save
		$result = $user_quiz->calculate_quiz_result($answered);
		// Save
		LP_User_Items_Result_DB::instance()->update($user_quiz->get_user_item_id(), wp_json_encode($result));

		if ($result['pass']) {
			$user_quiz->set_graduation(LP_COURSE_GRADUATION_PASSED);
		} else {
			$user_quiz->set_graduation(LP_COURSE_GRADUATION_FAILED);
		}

		$user_quiz->complete();

		$result['status']    = $user_quiz->get_status(); // Must be completed
		$result['attempts']  = $user_quiz->get_attempts();
		$result['answered']  = $result['questions'];
		$result['results']   = $result;
		$response['status']  = 'success';
		$response['results'] = $result;
	} catch (Throwable $e) {
		$response['message'] = $e->getMessage();
	}

	return rest_ensure_response($response);
}
