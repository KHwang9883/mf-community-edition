shader_type canvas_item;

// Bevel gradient for runtime-drawn menu text, matching the pre-rendered menu
// label textures (bright top, darker bottom). It only touches the vertex stage
// so the default fragment keeps reading the glyph texture, which is what keeps
// the letter shapes intact.
// The defaults match smb.ttf at 28px: uppercase ink spans y = 3 .. 27 measured
// from the top of the label, so the gradient covers exactly the glyph band.
uniform vec4 gradient_top : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 gradient_bottom : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float gradient_top_y = 3.0;
uniform float gradient_height = 24.0;

void vertex() {
	float t = clamp((VERTEX.y - gradient_top_y) / gradient_height, 0.0, 1.0);
	COLOR.rgb *= mix(gradient_top.rgb, gradient_bottom.rgb, t);
}