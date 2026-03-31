shader_type spatial;
render_mode unshaded;

#include "res://shaders/screen_effects/screen_shader_utilities.gdshaderinc"

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D surface_noise_texture : repeat_enable, filter_linear;

uniform float brightness : hint_range(-1, 1) = 0;
uniform float contrast : hint_range(0, 3) = 1.0;
uniform float saturation : hint_range(0, 3) = 1.0;

uniform vec4 saturation_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float x_wiggle_amp : hint_range(0.0, 1.0) = 0.0;
uniform float x_wiggle_screen_freq = 1.0;
uniform float x_wiggle_time_freq = 1.0;

uniform float y_wiggle_amp : hint_range(0.0, 1.0) = 0.0;
uniform float y_wiggle_screen_freq = 1.0;
uniform float y_wiggle_time_freq = 1.0;

uniform float blur_iterations = 1.0;
uniform float blur_power = 1.0;

void vertex(){
	POSITION = vec4(VERTEX, 1.0);
}

mat4 saturation_matrix(vec4 color, float s) {
	return mat4(
		vec4(s * color.r + s, s * color.r, s * color.r, 0.0),
		vec4(s * color.g, s * color.g + s, s * color.r, 0.0),
		vec4(s * color.b, s * color.b, s * color.b + s, 0.0),
		vec4(0.0, 0.0, 0.0, 1.0)
	);
}

void fragment() {
	float x_pos = SCREEN_UV.x + x_wiggle_amp * sin(PI * SCREEN_UV.x) * sin(x_wiggle_screen_freq * SCREEN_UV.x + x_wiggle_time_freq * TIME);
	float y_pos = SCREEN_UV.y + y_wiggle_amp * sin(PI * SCREEN_UV.y) * sin(y_wiggle_screen_freq * SCREEN_UV.y + y_wiggle_time_freq * TIME);
	vec2 uv = vec2(x_pos, y_pos);
	vec2 blur_uv = uv;
	vec2 blur_dir = vec2(0.5, 0.5) - blur_uv;
	vec2 blur = blur_dir * blur_power * 0.01;
	vec4 blur_color = vec4(0.0);
	for (float i = 0.0; i < blur_iterations; i++) {
		blur_color += texture(SCREEN_TEXTURE, blur_uv);
		blur_uv += blur;
	}
	blur_color /= blur_iterations;
	vec4 screen_color = blur_color;
	vec3 normal = texture(NORMAL_TEXTURE, uv).rgb;
	normal = normal * 2.0 - 1.0;
	vec2 offset = 1.0 / VIEWPORT_SIZE;

	vec4 final_color = brightnessMatrix(brightness) * contrastMatrix(contrast) * saturationMatrix(saturation_color, saturation) * screen_color;
	ALBEDO = final_color.rgb;
	//ALPHA = final_color.a;
}