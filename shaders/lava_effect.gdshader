shader_type canvas_item;

uniform vec3 color  : source_color = vec3(.2, .07, .01);

uniform float timeScaleFactor = .04;
uniform float contrast_exponent = 1.4;
uniform float p_scale = 50.0;
uniform bool pos_invariant = false;

// Make sure to use a seamless noise texture
uniform sampler2D noise_texture: repeat_enable, filter_linear;

float localTime() {
	return TIME * timeScaleFactor;
}

mat2 makem2(float theta) {
	float c = cos(theta);
	float s = sin(theta);
	return mat2(vec2(c, -s), vec2(s, c));
}

float noise(vec2 x) {
	return texture(noise_texture, x * .01).x;
}

vec2 gradn(vec2 p) {
	float ep = .09;
	float gradx = noise(vec2(p.x + ep, p.y)) - noise(vec2(p.x - ep, p.y));
	float grady = noise(vec2(p.x, p.y + ep)) - noise(vec2(p.x, p.y - ep));
	return vec2(gradx, grady);
}

float flow(vec2 p) {
	float z = 2.;
	float rz = 0.;
	vec2 bp = p;

	for(float i = 1.; i < 7.; ++i) {
		p += localTime() * .6;
		bp += localTime() * 1.9;
		vec2 gr = gradn(i * p * .34 + localTime() * 1.);
		gr *= makem2(localTime() * 6. - (.05 * p.x + 0.03 * p.y) * 40.);
		p += gr * .5;
		rz += (sin(noise(p) * 7.) *.5 + .5) / z;
		p = mix(bp, p, .77);
		z *= 1.4;
		p *= 2.;
		bp *= 1.9;
	}
	return rz;
}

void fragment() {
	vec2 resolution = 0.5 / SCREEN_PIXEL_SIZE;
	vec2 fragCoord;
	vec2 p;
	if (pos_invariant) {
		fragCoord = FRAGCOORD.xy;
		fragCoord = vec2(fragCoord.x, resolution.y - fragCoord.y);
		p = fragCoord / resolution - 0.5;
		p.x *= resolution.x / resolution.y;
		p *= p_scale;
	}
	else {
		fragCoord = UV.xy;
		fragCoord.y *= -1.;
		p = fragCoord;
		p *= p_scale;
	}


	float rz = flow(p);
	vec3 col = color / rz;
	col = pow(col, vec3(contrast_exponent));

	COLOR = vec4(col, 1.0);
}