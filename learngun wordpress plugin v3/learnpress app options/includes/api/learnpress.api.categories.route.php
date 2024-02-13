<?php
add_action('rest_api_init', 'app_category_color');


function app_category_color()
{
    register_rest_field(
        array('course_category'),
        'color',
        array(
            'get_callback'    => 'get_category_color',
            'update_callback' => null,
            'schema'          => null,
        )
    );
}

function get_category_color($object, $field_name, $request)
{
    return get_term_meta($object["id"], 'app-category-color', true);
}

add_action('rest_api_init', 'app_category_image');

function app_category_image()
{
    register_rest_field(
        array('course_category'),
        'image',
        array(
            'get_callback'    => 'get_category_image',
            'update_callback' => null,
            'schema'          => null,
        )
    );
}

function get_category_image($object, $field_name, $request)
{
    return wp_get_attachment_image_src(get_term_meta($object["id"], 'app-category-image', true), 'full');
}
