<?php
require_once(ABSPATH . 'wp-admin/includes/user.php');

add_action('rest_api_init', function () {
    $namespace = 'learnpressapp/v1';

    register_rest_route($namespace, 'delete-account/', array(
        'methods'  => WP_REST_Server::ALLMETHODS,
        'callback' => 'learnpress_delete_account',
    ));
});

function learnpress_delete_account($request)
{
    $app_settings = get_option('learnpress_app');
    $bearertoken = str_replace("Bearer ", "", $request->get_header('authorization'));
    if ($bearertoken != $app_settings["license_key"]) {
        return new WP_Error('license_failed', 'License Verification Failed.', array(
            'status' => 401
        ));
    }
    $user_id = $request['user_id'];
    $user = get_user_by('id', $user_id);

    wp_delete_user($user_id);
    return array("message" => "Account deleted successfully.");
}
