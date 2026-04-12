shader_type canvas_item;

uniform float sway_amplitude = 0.0;
uniform float sway_freq = 0.0;
uniform float sway_offset = 0.0;
uniform float big_sway_amplitude = 0.0;
uniform float big_sway_freq = 0.0;
uniform float big_sway_offset = 0.0;

void vertex() {
	VERTEX.x += step(VERTEX.y, 0.5) * sway_amplitude * sin((sway_offset + TIME) * sway_freq / PI) * 
		big_sway_amplitude * sin((big_sway_offset + TIME) * big_sway_freq / PI);
}
