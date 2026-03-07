shader_type canvas_item;

uniform vec2 fixed_pos;


void fragment() {
	COLOR = vec4(UV - fixed_pos, 0.0, 1.0);
	COLOR = texture(TEXTURE, UV - fixed_pos);
}

