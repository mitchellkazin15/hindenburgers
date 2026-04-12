shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform sampler2D noise_texture2 : repeat_enable, filter_linear;
uniform vec4 first_color : source_color;
uniform vec4 second_color : source_color;
uniform float first_rotation_freq;
uniform float first_growth_freq;
uniform float first_growth_amp;
uniform vec2 second_velocity;

void fragment() {
	float first_angle = TIME * first_rotation_freq / PI;
	mat2 first_rotation_mat = mat2(vec2(cos(first_angle), -sin(first_angle)), vec2(sin(first_angle), cos(first_angle)));
	vec2 first_sample_position = first_rotation_mat * (SCREEN_UV - vec2(0.5));
	first_sample_position *= first_growth_amp * cos(first_growth_freq * TIME) + 1.0;
	first_sample_position += vec2(0.5);
	vec2 second_sample_position = SCREEN_UV + second_velocity * TIME;
	COLOR = mix(texture(noise_texture, first_sample_position) * first_color, texture(noise_texture2, second_sample_position) * second_color, 0.5);
}
