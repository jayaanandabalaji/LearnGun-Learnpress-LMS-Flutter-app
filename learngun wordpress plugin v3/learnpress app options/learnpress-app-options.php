<?php

/**
 * Plugin Name: Learnpress app options
 * Plugin URI: https://techgun.net/
 * Description: Learnpress app options
 * Version: 1.3
 * Author: Techgun
 * Author URI: https://techgun.net/
 **/

if (!defined('LEARNPRESS_APP_DIR_URI')) {
	define('LEARNPRESS_APP_DIR_URI', plugin_dir_path(__FILE__));
}

require_once LEARNPRESS_APP_DIR_URI . '/app-option/option-set.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpressapp.api.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/learnpress_category_meta.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/app_resources.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/H5P.php';

add_action('pmpro_membership_level_after_other_settings', 'pmpro_membership_level_after_other_settings_app');
function pmpro_membership_level_after_other_settings_app()
{
	require_once __DIR__ . DIRECTORY_SEPARATOR . 'includes' . DIRECTORY_SEPARATOR . 'PM-edit.php';
}
register_rest_field('zoom-meetings', 'details', array(
	'get_callback' => function ($data) {
		$returnJson = get_post_meta($data['id'], '_meeting_zoom_details', '')[0];
		$returnJson->host_name = get_user_by_email(get_post_meta($data['id'], '_meeting_zoom_details', '')[0]->host_email)->data->display_name;
		return $returnJson;
	},
));


function submit_quiz($request)
{
	$user_id     = get_current_user_id();
	$item_id     = $request['item_id'];
	$course_id   = $request['course_id'];
	$answered    = $request['answered'];
	$user        = learn_press_get_user($user_id);
	$course      = learn_press_get_course($course_id);
	$user_course = $user->get_course_data($course_id);
	$results     = array();
	$user_quiz   = false;

	if ($course->is_no_required_enroll()) {
		$no_required_enroll = new LP_Course_No_Required_Enroll();
		// Course is no required enroll
		$success  = true;
		$response = array(
			'success' => $success,
			'message' => __('Success!', 'learnpress'),
		);
		if ($success) {
			// Use for Review Quiz.
			$quiz = learn_press_get_quiz($item_id);
			if (get_post_meta($item_id, '_lp_review', true) === 'yes') {

				$question_ids = $quiz->get_question_ids();
				if ($question_ids) {
					foreach ($question_ids as $id) {
						$question = learn_press_get_question($id);

						$results['questions'][$id] = array(
							'explanation' => $question->get_explanation(),
							'options'     => learn_press_get_question_options_for_js(
								$question,
								array(
									'include_is_true' => get_post_meta($item_id, '_lp_show_correct_review', true) === 'yes',
									'answer'          => isset($answered[$id]) ? $answered[$id] : '',
								)
							),
						);
					}
				}
			}

			$results['answered'] = $no_required_enroll->guest_get_quiz_answered($request['answered'], $item_id);
			$results['status']   = 'completed';
			$results['results']  = $no_required_enroll->guest_quiz_get_results('', false, $item_id, $request['answered'], $course_id);
			$results['attempts'] = $no_required_enroll->guest_quiz_get_attempts($item_id, $request['answered'], $course_id);
			$response['results'] = $results;

			learn_press_setcookie('quiz_submit_status_' . $course_id . '_' . $item_id . '', 'completed', time() + (7 * DAY_IN_SECONDS), false);
		}
	} else {
		// Course required enroll
		if ($user_course) {
			$user_quiz = $user_course->get_item($item_id);

			if ($user_quiz) {
				$user_quiz->add_question_answer($answered);
			}
		}

		$finished = $user->finish_quiz($item_id, $course_id, true);
		$success  = !is_wp_error($finished);

		$response = array(
			'success' => $success,
			'message' => !$success ? $finished->get_error_message() : __('Success!', 'learnpress'),
		);

		if ($success) {
			$user_quiz    = $user_course->get_item($item_id);
			$quiz_results = $user_quiz->get_results('');
			$attempts     = $user_quiz->get_attempts();
			// Use for Review Quiz.
			if (get_post_meta($item_id, '_lp_review', true) === 'yes') {
				$question_ids = $quiz_results->getQuestions('ids');
				if ($question_ids) {
					foreach ($question_ids as $id) {
						$question = learn_press_get_question($id);

						$results['questions'][$id] = array(
							'explanation' => $question->get_explanation(),
							'options'     => learn_press_get_question_options_for_js(
								$question,
								array(
									'include_is_true' => get_post_meta($item_id, '_lp_show_correct_review', true) === 'yes',
									'answer'          => isset($answered[$id]) ? $answered[$id] : '',
								)
							),
						);
					}
				}
			}

			$results['answered'] = $quiz_results->getQuestions();
			$results['status']   = $quiz_results->get('status');
			$results['results']  = $quiz_results->get();
			$results['attempts'] = $attempts;
			$response['results'] = $results;
		}
	}
	return rest_ensure_response($response);
}
