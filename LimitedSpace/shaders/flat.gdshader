shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_nearest;

void fragment() {
    vec3 col = texture(tex, UV).rgb;
	ALBEDO = col;
}
