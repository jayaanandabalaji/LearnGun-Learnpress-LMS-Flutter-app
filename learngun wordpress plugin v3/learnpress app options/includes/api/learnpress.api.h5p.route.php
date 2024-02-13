<?php
add_action('rest_api_init', function () {
  register_rest_route('learnpressapp/v1', 'h5p_lesson', array(
    'methods'  => 'GET',
    'callback' => 'get_lp_h5p_idd',

  ));
});

function get_lp_h5p_idd($request)
{
  return get_post_meta($request['id'], '_edit_last');
}
