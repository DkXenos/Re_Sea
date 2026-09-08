shader_type canvas_item;

// A piece of trash on the seabed is painted in the same muted palette as the
// seabed behind it, so the silhouette dissolves into the sand and you cannot
// tell what you are lining the claw up with. Two cheap passes fix it:
//
//   ring  - picked up from the neighbouring alpha, dark and soft. gives the
//           shape a contact edge against whatever is behind it.
//   rim   - the topmost opaque pixels only, lit from above the way the water
//           surface lights everything else in the tank.
//
// Both are meant to be felt, not seen. If you can point at the outline it is
// too strong - turn ring_alpha down before you touch anything else.
//
// The ring draws into the png's transparent margin. The item art carries
// ~17px of it; the crate touches its own bottom edge and loses the ring
// there, which is the one place this is visibly imperfect.

uniform vec4 ring_color : source_color = vec4(0.03, 0.09, 0.14, 1.0);
uniform float ring_alpha : hint_range(0.0, 1.0) = 0.55;
uniform float ring_width : hint_range(0.0, 6.0) = 2.0;
uniform vec4 rim_color : source_color = vec4(0.78, 0.94, 1.0, 1.0);
uniform float rim_strength : hint_range(0.0, 1.0) = 0.3;

// the node's modulate. there is no MODULATE built-in to read in fragment on
// this engine version, and COLOR has already been multiplied by it by then,
// so it is carried across from the vertex stage where it is still separate.
varying vec4 v_modulate;


void vertex() {
	v_modulate = COLOR;
}


void fragment() {
	vec4 src = texture(TEXTURE, UV) * v_modulate;

	// widest neighbouring alpha in eight directions. eight is enough at this
	// width - four leaves visible corners on a diagonal edge. this is spelled
	// out here rather than in a helper because Godot will not let a built-in
	// sampler like TEXTURE cross into a user function.
	vec2 step_px = TEXTURE_PIXEL_SIZE * ring_width;
	float near = 0.0;
	for (int i = 0; i < 8; i++) {
		float ang = float(i) * PI * 0.25;
		near = max(near, texture(TEXTURE, UV + vec2(cos(ang), sin(ang)) * step_px).a);
	}

	// ring lives only where the sprite itself does not
	float ring = clamp(near - src.a, 0.0, 1.0) * ring_alpha * v_modulate.a;

	// an opaque pixel with nothing above it is the lit edge
	float above = texture(TEXTURE, UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y * 1.5)).a;
	float rim = clamp(src.a - above, 0.0, 1.0) * rim_strength;
	src.rgb = mix(src.rgb, rim_color.rgb, rim);

	// sprite over ring, straight alpha - premultiplying here and letting the
	// default blend undo it came out with dark fringes on the soft edges
	float out_a = src.a + ring * (1.0 - src.a);
	vec3 out_rgb = src.rgb;
	if (out_a > 0.0001) {
		out_rgb = (src.rgb * src.a + ring_color.rgb * ring * (1.0 - src.a)) / out_a;
	}
	COLOR = vec4(out_rgb, out_a);
}
