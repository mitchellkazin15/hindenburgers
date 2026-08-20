shader_type canvas_item;
render_mode unshaded;

#include "res://shaders/screen_effects/screen_shader_utilities.gdshaderinc"

// Canvas items draw AFTER the 3D post-processing stack (glow, tonemap, sRGB
// encode), so SCREEN_TEXTURE here is display-referred -- the same space as the
// history buffer, which is a copy of the finished viewport texture. Keeping both
// sides of the trail blend in one space is what makes the feedback loop stable.
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform sampler2D history_tex : filter_linear, repeat_disable;
uniform float trail_amount = 0.0;

uniform sampler2D fractal_noise_texture : repeat_enable, filter_linear;
uniform float fractal_noise_distortion = 0.0;
uniform float fractal_noise_iterations = 1.0;
uniform float fractal_noise_overlay_strength = 0.0;
uniform float fractal_chromatic_shift_strength = 0.0;

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

void fragment() {
	// Wiggle the sample position.
	float x_pos = SCREEN_UV.x + x_wiggle_amp * sin(PI * SCREEN_UV.x) * sin(x_wiggle_screen_freq * SCREEN_UV.x + x_wiggle_time_freq * TIME);
	float y_pos = SCREEN_UV.y + y_wiggle_amp * sin(PI * SCREEN_UV.y) * sin(y_wiggle_screen_freq * SCREEN_UV.y + y_wiggle_time_freq * TIME);
	vec2 blur_uv = vec2(x_pos, y_pos);
	vec2 blur = (vec2(0.5) - blur_uv) * blur_power;// * 0.01;

	// Gradient of the noise field, used to push the distorted sample offsets around.
	vec2 texel_size = SCREEN_PIXEL_SIZE;
	float fractal_x_grad = texture(fractal_noise_texture, blur_uv + vec2(texel_size.x, 0.0)).r -
		texture(fractal_noise_texture, blur_uv - vec2(texel_size.x, 0.0)).r;
	float fractal_y_grad = texture(fractal_noise_texture, blur_uv + vec2(0.0, texel_size.y)).r -
		texture(fractal_noise_texture, blur_uv - vec2(0.0, texel_size.y)).r;
	vec2 fractal_grad = vec2(fractal_x_grad, fractal_y_grad);

	// Radial blur toward screen center.
	vec4 blur_color = vec4(0.0);
	for (float i = 0.0; i < blur_iterations; i++) {
		blur_color += texture(SCREEN_TEXTURE, blur_uv);
		blur_uv += blur;
	}
	blur_color /= blur_iterations;

	//vec4 noise_color = vec4(0.0);
	for (float i = 0.0; i < fractal_noise_iterations; i++) {
		blur_color += texture(SCREEN_TEXTURE, blur_uv + (i * fractal_noise_distortion * fractal_grad));
	}
	blur_color /= max(fractal_noise_iterations, 1.0);

	vec4 final_color = brightnessMatrix(brightness) * contrastMatrix(contrast) * saturationMatrix(saturation_color, saturation) * blur_color;

	// Tint based on where this pixel lands in the noise field.
	vec3 noise_sample = texture(fractal_noise_texture, blur_uv).rgb;
	float luminance = dot(noise_sample, vec3(0.299, 0.587, 0.114));

	vec3 shift_color;
	shift_color.r = fractal_chromatic_shift_strength * clamp(1.0 - 2.0 * luminance, 0.0, 1.0);
	shift_color.g = fractal_chromatic_shift_strength * clamp(1.0 - abs(2.0 * luminance - 1.0), 0.0, 1.0);
	shift_color.b = fractal_chromatic_shift_strength * clamp(2.0 * luminance - 1.0, 0.0, 1.0);

	vec3 current = final_color.rgb + fractal_noise_overlay_strength * shift_color;
	vec3 history = texture(history_tex, SCREEN_UV).rgb;
	COLOR = vec4(mix(current, history, clamp(trail_amount, 0.0, 0.975)), 1.0);
}
