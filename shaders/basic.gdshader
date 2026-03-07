shader_type canvas_item;

uniform float red_adder = 0.0;
uniform float green_adder = 0.0;
uniform float blue_adder = 0.0;
uniform float alpha_adder = 0.0;

uniform float flashing_red = 0.0;
uniform float flashing_green = 0.0;
uniform float flashing_blue = 0.0;
uniform float flashing_aplha = 0.0;
uniform float flashing_max_intensity = 1.0;

uniform bool flashing = false;
uniform float flashing_period_sec = 1.0;
uniform float flashing_start_time_sec = 0.0;

void fragment() {
	float time_elapsed_sec = TIME - flashing_start_time_sec;
	COLOR = texture(TEXTURE, UV);
	COLOR.r += red_adder;
	COLOR.g += green_adder;
	COLOR.b += blue_adder;
	COLOR.a += alpha_adder;
	if (flashing) {
		float flashing_intensity = flashing_max_intensity * abs(sin(TAU * (time_elapsed_sec / flashing_period_sec)));
		COLOR.r += flashing_red * flashing_intensity;
		COLOR.b += flashing_blue * flashing_intensity;
		COLOR.g += flashing_green * flashing_intensity;
		COLOR.a += flashing_aplha * flashing_intensity;
	}
}
