shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float event_horizon_radius : hint_range(0.0, 0.5, 0.01) = 0.0;
uniform float effect_radius : hint_range(0.0, 0.5, 0.01) = 0.5;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest, source_color;
uniform sampler2D curve_texture;
uniform float red_shift_amount = 0.001;

void fragment() {
	vec2 vec_to_center = UV.xy - vec2(0.5, 0.5);
	float dist_to_center = length(vec_to_center);
	float dist_to_event_horizon = dist_to_center - event_horizon_radius;
	float curve_val = texture(curve_texture, UV).r;
	vec2 diff = vec_to_center * smoothstep(effect_radius, event_horizon_radius, dist_to_center) / pow(dist_to_center, 3.0);
    COLOR.rgb = textureLod(screen_texture, SCREEN_UV + diff * SCREEN_PIXEL_SIZE, 1.0).rgb * step(event_horizon_radius, dist_to_center);
	float red_shift = red_shift_amount * step(dist_to_center, effect_radius) * step(event_horizon_radius, dist_to_center) / pow(dist_to_center, 3.0);
	COLOR.b -= red_shift;
	COLOR.g -= 0.6 * red_shift;
}
