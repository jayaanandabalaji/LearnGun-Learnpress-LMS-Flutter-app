<?php
if (!class_exists('Redux')) {
    return;
}

$opt_name = 'learnpress_app';

$theme = wp_get_theme(); // For use with some settings. Not necessary.

$args = array(
    'display_name'         => "Learnpress App",
    'display_version'      => "1.0",
    'menu_type'            => 'menu',
    'allow_sub_menu'       => false,
    'dev_mode'             => false,

);

Redux::setArgs($opt_name, $args);
Redux::setSection($opt_name, array(
    'title'  => esc_html__('Configurations', 'learnpress_app_options'),
    'id'     => 'Configurations',
    'fields' => array(
        array(
            'id' => 'license_key',
            'type' => 'text',
            'title' => __('License Key', 'learnpress_app_options')
        ),
    )
));

$category_array = array();
foreach (get_terms(['lp_course', 'hide_empty' => true,]) as $single_category) {
    $category_array[$single_category->term_id . '|' . $single_category->name] = $single_category->name;
}
Redux::setSection($opt_name, array(
    'title'  => esc_html__('Basic', 'learnpress_app_options'),
    'id'     => 'basic',
    'fields' => array(
        array(
            'id'       => 'primary-color',
            'type'     => 'color',
            'title'    => esc_html__('Primary Color', 'learnpress_app_options'),
            'transparent' => false
        ),



        array(
            'id'       => 'home_category_courses',
            'type'     => 'select',
            'multi'    => true,
            'title'    => esc_html__("Home featured category", 'learnpress_app_options'),
            'options'  => $category_array,
        ),


        array(
            'id'          => 'opt-typography',
            'type'        => 'typography',
            'title'       => esc_html__('Typography', 'your-textdomain-here'),
            'google'      => true,
            'text-align' => false,
            'font-weight' => false,
            'subsets' => false,
            'font-backup' => false,
            'font-style	' => false,
            'font-size' => false,
            'line-height' => false,
            'color' => false
        ),
        array(
            'id'          => 'home-banner',
            'type'        => 'repeater',
            'title'       => esc_html__('Home Banner', 'learnpress_app_options'),
            'full_width'  => false,
            'item_name'   => 'home-banner',
            'sortable'    => true,
            'active'      => false,
            'collapsible' => true,
            'limit' => 10,
            'fields'      => array(
                array(
                    'id' => 'banner_title',
                    'type' => 'text',
                    'title' => esc_html__('Title', 'learnpress_app_options'),
                ),

                array(
                    'id'          => 'banner_image',
                    'type'        => 'media',
                    'title' => esc_html__('Banner Image', 'learnpress_app_options'),
                ),

                array(
                    'id'       => 'banner-type',
                    'type'     => 'select',
                    'title'    => esc_html__('On banner tap, open ', 'learnpress_app_options'),
                    'options'  => array(
                        'Category' => 'Category',
                        'Tag' => 'Tag',
                        'Course' => 'Course',
                        'url' => 'url'
                    ),
                ),
                array(
                    'id' => 'type_value',
                    'type' => 'text',
                    'title' => esc_html__('Type value', 'learnpress_app_options'),
                ),

            ),
        ),
    )
));
