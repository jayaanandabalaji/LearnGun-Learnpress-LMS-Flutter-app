<?php
defined('ABSPATH') || exit;
$level_id = $_GET['edit'];

$checked = get_option('LP_app_pmpro_categories_' . $level_id, 0);
$terms = array(array('name' => 'All Categories'));
foreach (get_terms([
	'taxonomy' => 'course_category',
	'hide_empty' => false,
]) as $term) {
	array_push($terms, $term);
}
?>

<h3 class="topborder">Membership app course categories</h3>
<table class="form-table">
	<tbody>
		<tr class="membership_categories">
			<th scope="row" valign="top"><label>Categories:</label></th>
			<td>
				<?php
				if (!empty($terms)) {
					foreach ($terms as $term) {
						if (in_array(((array)$term)['name'], $checked)) {
							echo '<input checked type="checkbox" name="category[]" value="' . ((array)$term)['name'] . '">' . ((array)$term)['name'] . '<br>';
						} else {
							echo '<input type="checkbox" name="category[]" value="' . ((array)$term)['name'] . '">' . ((array)$term)['name'] . '<br>';
						}
					}
				}
				?>


			</td>
		</tr>
	</tbody>
</table>