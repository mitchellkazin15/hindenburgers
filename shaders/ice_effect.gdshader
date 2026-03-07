shader_type canvas_item;

uniform vec4 ice_color : source_color;
uniform sampler2D ice_noise_texture : repeat_enable, filter_linear;
uniform sampler2D twinkle_texture : repeat_enable, filter_linear;
uniform float twinkle_strength = 1.0;
uniform float twinkle_threshold = 1.0;
uniform float twinkle_x_speed = 1.0;
uniform float twinkle_y_speed = 1.0;


void fragment() {
	COLOR = texture(ice_noise_texture, UV).r * ice_color;
	vec2 twinkle_sample_pos = UV + TIME * vec2(twinkle_x_speed, twinkle_y_speed);//vec2(UV.x + twinkle_x_amplitude * sin(twinkle_x_frequency * TIME / PI), UV.y + twinkle_y_amplitude * sin(twinkle_y_frequency * TIME / PI));
	vec4 twinkle_sample = texture(twinkle_texture, twinkle_sample_pos)*ice_color;
	float avg_color = (COLOR.r + COLOR.b + COLOR.g) / 3.0;
	float avg_twinkle = (twinkle_sample.r + twinkle_sample.b + twinkle_sample.g) / 3.0;
	COLOR += twinkle_strength * step(twinkle_threshold, avg_color + avg_twinkle) * twinkle_sample;
}
