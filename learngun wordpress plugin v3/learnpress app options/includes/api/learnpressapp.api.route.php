<?php
use \Firebase\JWT\JWT;


add_action('rest_api_init', function () {
    $namespace = 'learnpressapp/v1';

  register_rest_route( $namespace, 'app-settings/', array(
        'methods'  => WP_REST_Server::ALLMETHODS,
        'callback' => 'get_app_settings',
    ));
    
    register_rest_route( $namespace, 'social-login/', array(
        'methods'  => WP_REST_Server::ALLMETHODS,
        'callback' => 'social_login',
    ));
    
  
    
});





function get_app_settings( $request ) {
    $app_settings = get_option( 'learnpress_app');
    $bearertoken=str_replace("Bearer ", "",$request->get_header('authorization'));
    if($bearertoken!=$app_settings["license_key"]){
        return new WP_Error('license_failed', 'License Verification Failed.', array(
            'status' => 401
        ));
    }
    if(isset($app_settings["license_key"])){
        unset($app_settings["license_key"]);
    }
    $app_settings["secondary-color"]="#02579D";
    return $app_settings;
}

function social_login( $request ){
    $app_settings = get_option( 'learnpress_app');
    $parameters = $request->get_params();
    $bearertoken=str_replace("Bearer ", "",$request->get_header('authorization'));
    if($bearertoken!=$app_settings["license_key"]){
        return new WP_Error('license_failed', 'License Verification Failed.', array(
            'status' => 401
        ));
    }
    if (!class_exists('LP_Jwt_Public')){
        return new WP_Error('learnpress_error', 'Learnpress not installed or misconfigured.', array(
            'status' => 401
        ));
    }
    $email = $parameters['email'];
    $password = $parameters['accessToken'];
    $user = get_user_by('email', $email);
    $request["username"]=$email;
    $request["password"]=$password;
    if (!$user) {
         $user = wp_create_user( $email, $password, $email );
         update_user_meta( $user, 'loginType', $parameters['loginType']);
         return generate_rest_token($request);
    }
    else{
         update_user_meta( $user->ID, 'loginType', $parameters['loginType']);
         return generate_rest_token($request);
    }
}

function generate_rest_token( WP_REST_Request $request ) {
		$secret_key = SECURE_AUTH_KEY;
		$username   = $request->get_param( 'username' );
		$password   = $request->get_param( 'password' );
		

		/** Try to authenticate the user with the passed credentials*/
		$user = get_user_by( 'email', $username );
		/** If the authentication fails return a error*/
		if ( is_wp_error( $user ) ) {
			$error_code = $user->get_error_code();

			return new WP_Error(
				'[lp_jwt_auth] ' . $error_code,
				$user->get_error_message( $error_code ),
				array(
					'status' => 403,
				)
			);
		}

		/** Valid credentials, the user exists create the according Token */
		$issued_at  = time();
		$not_before = apply_filters( 'lp_jwt_auth_not_before', $issued_at, $issued_at );
		$expire     = apply_filters( 'lp_jwt_auth_expire', $issued_at + WEEK_IN_SECONDS, $issued_at );

		$token = array(
			'iss'  => get_bloginfo( 'url' ),
			'iat'  => $issued_at,
			'nbf'  => $not_before,
			'exp'  => $expire,
			'data' => array(
				'user' => array(
					'id' => $user->data->ID,
				),
			),
		);
		/** Let the user modify the token data before the sign. */
		$token = JWT::encode( apply_filters( 'lp_jwt_auth_token_before_sign', $token, $user ), $secret_key );

		/** The token is signed, now create the object with no sensible user data to the client*/
		$data = array(
			'token'             => $token,
			'user_id'           => $user->data->ID,
			'user_login'        => $user->data->user_login,
			'user_email'        => $user->data->user_email,
			'user_display_name' => $user->data->display_name,
		);

		return apply_filters( 'lp_jwt_auth_token_before_dispatch', $data, $user );
	}

require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.categories.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.quiz.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.order.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.profile.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.review.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.courses.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpressapp.api.lessons.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.deleteAccount.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.pmpro.route.php';
require_once LEARNPRESS_APP_DIR_URI . '/includes/api/learnpress.api.h5p.route.php';
