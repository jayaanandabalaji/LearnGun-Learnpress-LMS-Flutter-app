<?php


add_action('rest_api_init', function () {
    $namespace = 'learnpressapp/v1';

    register_rest_route($namespace, 'user/edit-profile/', array(
        'methods'             => WP_REST_Server::CREATABLE,
        'callback'            => 'edit_user_profile',
        'permission_callback' => 'validate_token',
    ));
    register_rest_route($namespace, 'user/change-password/', array(
        'methods'             => WP_REST_Server::CREATABLE,
        'callback'            => 'change_user_password',
        'permission_callback' => 'validate_token',
    ));
});




function edit_user_profile($request)
{
    $user_id = (int)validate_token()["data"]["exp"];
    if ($request["description"] != "") {
        update_user_meta($user_id,  'description',  $request["description"]);
    }
    if ($request["first_name"] != "") {
        update_user_meta($user_id,  'first_name',  $request["first_name"]);
    }
    if ($request["last_name"] != "") {
        update_user_meta($user_id,  'last_name',  $request["last_name"]);
    }
    if ($request["description"] != "") {
        update_user_meta($user_id,  'description',  $request["description"]);
    }
    if ($request["display_name"] != "") {
        $userdata = array(
            'ID' => $user_id,
            'display_name' => $request["display_name"],
        );

        wp_update_user($userdata);
    }


    $social = (get_user_meta($user_id, '_lp_extra_info'))[0];
    $social_arr = array('facebook' => $social['facebook'] ?? "", 'twitter' => $social['twitter'] ?? "", 'youtube' => $social['youtube'] ?? "", 'linkedin' => $social['linkedin'] ?? "");
    if ($request["facebook"] != "") {
        $social_arr["facebook"] = $request["facebook"];
        update_user_meta($user_id,  '_lp_extra_info', ($social_arr));
    }
    if ($request["twitter"] != "") {
        $social_arr['twitter'] = $request["twitter"];
        update_user_meta($user_id,  '_lp_extra_info',  $social_arr);
    }
    if ($request["youtube"] != "") {
        $social_arr['youtube'] = $request["youtube"];
        update_user_meta($user_id,  '_lp_extra_info',  $social_arr);
    }
    if ($request["linkedin"] != "") {
        $social_arr['linkedin'] = $request["linkedin"];
        update_user_meta($user_id,  '_lp_extra_info',  $social_arr);
    }

    require_once(ABSPATH . 'wp-admin/includes/image.php');
    require_once(ABSPATH . 'wp-admin/includes/file.php');
    require_once(ABSPATH . 'wp-admin/includes/media.php');
    $files = $request->get_file_params();
    if ($files["avatar"] != "") {
        $dir = wp_upload_dir();
        $base_dir = $dir['basedir'] . '/learn-press-profile';
        if (!is_dir($base_dir)) wp_mkdir_p($base_dir);
        $file_upload = $files['avatar']['tmp_name'];
        $file_extension = pathinfo($files['avatar']['name'], PATHINFO_EXTENSION);
        $file_name = "learn-press-profile" . $user_id . '.' . $file_extension;
        $file = "{$base_dir}/{$file_name}";
        if (file_exists($file)) unlink($file);
        move_uploaded_file($file_upload, $file);
        $image = wp_get_image_editor($file);
        $image->save($file);
        update_user_meta($user_id,  '_lp_profile_picture',  'learn-press-profile/' . $file_name);
    }

    return array('success' => true);
}

function change_user_password($request)
{
    $user_id = (int)validate_token()["data"]["exp"];
    $user = get_user_by('id', $user_id);
    $x = wp_check_password($request['old_password'], $user->user_pass, $user_id);
    if (!$x) {
        return array("success" => false, "message" => "old password is wrong");
    } else {
        wp_set_password($request["new_password"], $user_id);
        return array("success" => true, "message" => "changed password successfully");
    }
}
