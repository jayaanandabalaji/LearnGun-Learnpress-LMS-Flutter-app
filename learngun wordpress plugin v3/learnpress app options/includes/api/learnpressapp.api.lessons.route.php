<?php

add_filter(
    'rest_request_after_callbacks',
    function ($response, array $handler, \WP_REST_Request $request) {
        if (
            str_contains($request->get_route(), 'learnpress/v1/lessons')
            && 'GET' === $request->get_method()
        ) {
            if (!($response instanceof \WP_REST_Response)) {
                return;
            }
            $data = array_map(
                'edit_lessons',
                [($response->get_data())]
            );
            $response->set_data($data);
            return ((array) $response)["data"][0];
        }
        return $response;
    },
    10,
    3
);

function edit_lessons(array $post)
{
    $postid = $post['id'];
    global $wpdb;
    $post_cont = $wpdb->get_var("SELECT post_content FROM $wpdb->posts WHERE ID = $postid");
    $post['content'] = $post_cont;
    if (str_contains($post_cont, 'zoom_meeting_post')) {
        $post['content'] = $post_cont;
    }
    return $post;
}
