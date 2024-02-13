<?php


$scriptPath = dirname(__FILE__);
$path = realpath($scriptPath . '/./');
$filepath = explode("wp-content", $path);
// print_r($filepath);
define('WP_USE_THEMES', false);
require('' . $filepath[0] . '/wp-blog-header.php');
$app_settings = get_option('learnpress_app');
if ($app_settings["license_key"] != $_GET['license']) {
	die;
}

?>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head>
	<script>
		document.addEventListener('DOMContentLoaded', function() {
			setTimeout(function() {
				console.log(document.querySelector('.certificate > img').src);

			}, 1500);

		}, false);
	</script>
	<link rel="stylesheet" id="open-sans-css" href="//fonts.googleapis.com/css?family=Open+Sans%3A300italic%2C400italic%2C600italic%2C300%2C400%2C600&amp;subset=latin%2Clatin-ext&amp;" type="text/css" media="all">
	<?php do_action('wp_enqueue_scripts'); ?>
	<?php wp_print_styles('certificates-css'); ?>
	<?php wp_print_scripts('pdfjs'); ?>
	<?php wp_print_scripts('fabric'); ?>
	<?php wp_print_scripts('downloadjs'); ?>
	<?php wp_print_scripts('certificates-js'); ?>
	<?php wp_print_scripts('learn-press-global'); ?>
	<?php LP_Addon_Certificates::instance()->header_google_fonts(); ?>

<body>
	<div class="single-certificate-content">

		<div class="certificate">

			<div id="certificate-0533a888904bd4867929dffd884d60b8" class="certificate-preview">
				<div class="certificate-preview-inner">
					<canvas></canvas>
				</div>
				<input class="lp-data-config-cer" type="hidden" value="<?php
																		$user_id = $_GET["user"];
																		$course_id = $_GET["course"];
																		$cert_id = LP_Certificate::get_course_certificate($course_id);
																		$data["user_id"] = $user_id;
																		$data["cert_id"] = $cert_id;
																		$data['course_id'] = $course_id;
																		$certificate = new LP_User_Certificate($data);
																		echo htmlspecialchars($certificate);
																		?>">


			</div>



		</div>

	</div>
	<p id="p1"></p>

</body>

</html>