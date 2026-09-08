// Dims the whole screen except one rounded-rect hole, and rings that hole.
//
// Everything is worked out in the 1280x720 design space rather than in UV,
// because a UV-space radius is squashed on one axis and the "circle" comes out
// an ellipse. `rect_size` converts back, so the caller passes plain pixels.
//
// No hole = push `hole_center` off-screen and set `ring_alpha` to 0; the
// distance is then huge everywhere and the screen dims flat.
shader_type canvas_item;

uniform vec2 rect_size = vec2(1280.0, 720.0);
uniform vec2 hole_center = vec2(640.0, 360.0);
uniform vec2 hole_half = vec2(80.0, 80.0);
uniform float hole_radius = 40.0;
// soft edge on the dim, so the cutout doesn't look like a sticker
uniform float feather = 14.0;
uniform float ring_width = 3.0;
uniform vec4 dim_color : source_color = vec4(0.02, 0.05, 0.12, 0.82);
uniform vec4 ring_color : source_color = vec4(1.0, 0.87, 0.45, 1.0);
uniform float ring_alpha = 1.0;

void fragment() {
	vec2 p = UV * rect_size;
	// signed distance to a rounded box, negative inside
	vec2 q = abs(p - hole_center) - hole_half;
	float d = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - hole_radius;

	float dim = smoothstep(0.0, feather, d);
	vec4 col = vec4(dim_color.rgb, dim_color.a * dim);

	float ring = (1.0 - smoothstep(ring_width, ring_width + 2.0, abs(d))) * ring_alpha;
	col.rgb = mix(col.rgb, ring_color.rgb, ring);
	col.a = max(col.a, ring * ring_color.a);

	COLOR = col;
}
