shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_nearest;

void fragment() {
    vec4 col = texture(tex, UV);
	ALBEDO = col.rgb;
    ALPHA = col.a;
}
