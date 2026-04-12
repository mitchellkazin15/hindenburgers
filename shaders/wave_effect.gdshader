shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest, source_color;
uniform sampler2D distortion_texture;
uniform vec4 wave_color : source_color;
uniform float distortion_strength = 1.0;


void fragment() {
	//vec2 sample_pos = vec2(SCREEN_UV.x + (UV.x - 0.5) * smoothstep(0.0, 0.5, abs(UV.x - 0.5)), SCREEN_UV.y);
	vec2 vec_to_x_center = vec2(abs(0.5 - SCREEN_UV.x), 0.0);
	float x_offset = distortion_strength * texture(distortion_texture, UV).r * SCREEN_PIXEL_SIZE.x;
	vec2 sample_pos = SCREEN_UV + vec_to_x_center * x_offset;//vec2(SCREEN_UV.x + x_offset, SCREEN_UV.y);
	vec4 screen_color = textureLod(screen_texture, sample_pos, 1.0);
	COLOR.rgb = mix(screen_color, wave_color, 0.5).rgb;
}
