<?php

add_filter(
    'rest_request_after_callbacks',
    function ($response, array $handler, \WP_REST_Request $request) {
        if (
            str_contains($request->get_route(), 'learnpress/v1/courses')
            && 'GET' === $request->get_method()
        ) {

            if (
                '/learnpress/v1/courses' === $request->get_route()
                && 'GET' === $request->get_method()
            ) {
                $data = array_map(
                    'prefix_post_response',
                    $response->get_data()
                );
                $data = array_map(
                    'edit_courses_metaData',
                    $data
                );
                $data = array_map(
                    'add_course_membership_api',
                    $data
                );

                $response->set_data($data);
                return $response;
            }

            $data = array_map(
                'prefix_post_response',
                [$response->get_data()]
            );
            $data = array_map(
                'edit_courses_metaData',
                $data
            );
            $data = array_map(
                'add_course_membership_api',
                $data
            );
            $response->set_data($data);
            return ((array) $response)["data"][0];
        }
        return $response;
    },
    10,
    3
);

function prefix_post_response(array $post)
{
    $post['certificate'] = get_post_meta($post['id'], '_lp_cert', true);
    return $post;
}

function add_course_membership_api(array $post)
{
    if (class_exists('PMPro_Membership_Level')) {
        $course_membership = [];
        $memberships = pmpro_getAllLevels(false, true);
        foreach ($memberships as $membership) {
            $categories = get_option('LP_app_pmpro_categories_' . $membership->id, 0);
            if (in_array('All Categories', $categories)) {
                array_push($course_membership, array('name' => $membership->name, 'cost' => $membership->initial_payment));
            } else {
                $course_categories = [];
                foreach ($post['categories'] as $category) {
                    array_push($course_categories, $category['name']);
                }
                if (count(array_intersect($course_categories, $categories)) > 0) {
                    array_push($course_membership, array('name' => $membership->name, 'cost' => $membership->initial_payment));
                }
            }
        }
        $post['membership'] = $course_membership;
    } else {
        $post['membership'] = '';
    }
    return $post;
}

function edit_courses_metaData(array $post)
{
    $post['meta_data'] = get_course_meta($post['id']);
    return $post;
}

function get_course_meta($id)
{


    if (!class_exists('LP_Meta_Box')) {
        include_once LP_PLUGIN_PATH . 'inc/admin/views/meta-boxes/class-lp-meta-box.php';
    }

    if (!class_exists('LP_Meta_Box_Course')) {
        include_once LP_PLUGIN_PATH . 'inc/admin/views/meta-boxes/course/settings.php';
    }

    $metabox = new LP_Meta_Box_Course();

    $output = array();

    foreach ($metabox->metabox($id) as $key => $tab) {
        if (isset($tab['content'])) {
            foreach ($tab['content'] as $meta_key => $object) {
                if (is_a($object, 'LP_Meta_Box_Field')) {
                    $object->id          = $meta_key;
                    $output[$meta_key] = $object->meta_value($id);
                }
            }
        }
    }

    return $output;
}
