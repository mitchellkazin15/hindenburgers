shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float effect_radius : hint_range(0.0, 0.5, 0.01) = 0.5;
uniform float effect_strength = 0.5;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest, source_color;

void fragment() {
	float dist_to_center = distance(UV.xy, vec2(0.5, 0.5));
	COLOR.rgb = textureLod(screen_texture, SCREEN_UV, 1.0).rgb;
	COLOR.g += effect_strength * smoothstep(effect_radius, 0.0, dist_to_center);
}

