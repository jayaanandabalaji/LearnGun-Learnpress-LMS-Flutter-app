
<?php
$pagePath = explode('/wp-content/', dirname(__FILE__));
include_once(str_replace('wp-content/', '', $pagePath[0] . '/wp-load.php'));

add_action('wp_ajax_h5p_embed_app', 'h5p_embed_app');
add_action('wp_ajax_nopriv_h5p_embed_app', 'h5p_embed_app');

function h5p_embed_app()
{
  $app_settings = get_option('learnpress_app');
  if ($app_settings["license_key"] != $_GET['license']) {
    print('license verification failed');
  } else {
    // Allow other sites to embed
    header_remove('X-Frame-Options');

    // Find content
    $id = filter_input(INPUT_GET, 'id', FILTER_SANITIZE_NUMBER_INT);
    if ($id !== NULL) {
      $plugin = H5P_Plugin::get_instance();
      $content = $plugin->get_content($id);
      if (!is_string($content)) {

        // Everyone is allowed to embed, set through settings
        $embed_allowed = true;
        /**
         * Allows other plugins to change the access permission for the
         * embedded iframe's content.
         *
         * @since 1.5.3
         *
         * @param bool $access
         * @param int $content_id
         * @return bool New access permission
         */

        if (!$embed_allowed) {
          // Check to see if embed URL always should be available
          $embed_allowed = (defined('H5P_EMBED_URL_ALWAYS_AVAILABLE') && H5P_EMBED_URL_ALWAYS_AVAILABLE);
        }

        if ($embed_allowed) {
          $lang = isset($content['metadata']['defaultLanguage'])
            ? $content['metadata']['defaultLanguage']
            : $plugin->get_language();
          $cache_buster = '?ver=' . H5P_Plugin::VERSION;

          // Get core settings
          $integration = $plugin->get_core_settings();
          // TODO: The non-content specific settings could be apart of a combined h5p-core.js file.

          // Get core scripts
          $scripts = array();
          foreach (H5PCore::$scripts as $script) {
            $scripts[] = plugins_url('h5p/h5p-php-library/' . $script) . $cache_buster;
          }

          // Get core styles
          $styles = array();
          foreach (H5PCore::$styles as $style) {
            $styles[] = plugins_url('h5p/h5p-php-library/' . $style) . $cache_buster;
          }

          // Get content settings
          $integration['contents']['cid-' . $content['id']] = $plugin->get_content_settings($content);
          $core = $plugin->get_h5p_instance('core');

          // Get content assets
          $preloaded_dependencies = $core->loadContentDependencies($content['id'], 'preloaded');
          $files = $core->getDependenciesFiles($preloaded_dependencies);
          $plugin->alter_assets($files, $preloaded_dependencies, 'external');

          $scripts = array_merge($scripts, $core->getAssetsUrls($files['scripts']));
          $styles = array_merge($styles, $core->getAssetsUrls($files['styles']));

          $additional_embed_head_tags = array();

          /**
           * Add support for additional head tags for embedded content.
           * Very useful when adding xAPI events tracking code.
           *
           * @since 1.9.5
           *
           * @param array &$additional_embed_head_tags
           */
          do_action_ref_array('h5p_additional_embed_head_tags', array(&$additional_embed_head_tags));

          $my_plugin = WP_PLUGIN_DIR . '/my-plugin';

          include_once(WP_PLUGIN_DIR . '/h5p/h5p-php-library/embed.php');

          // Log embed view
          new H5P_Event(
            'content',
            'embed',
            $content['id'],
            $content['title'],
            $content['library']['name'],
            $content['library']['majorVersion'] . '.' . $content['library']['minorVersion']
          );
          exit;
        }
      }
    }

    // Simple unavailble page
    print '<body style="margin:0"><div style="background: #fafafa url(' . plugins_url('h5p/h5p-php-library/images/h5p.svg') . ') no-repeat center;background-size: 50% 50%;width: 100%;height: 100%;"></div><div style="width:100%;position:absolute;top:75%;text-align:center;color:#434343;font-family: Consolas,monaco,monospace">' . __('Content unavailable.', $this->plugin_slug) . '</div></body>';
    exit;
  }
}
?>