shader_type canvas_item;
uniform vec4 top_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.5607, 0.6509, 1.0, 1.0);

void fragment() {
    vec4 text_color = texture(TEXTURE, UV);

    vec4 gradient_color = mix(top_color, bottom_color, UV.y);

    // Apply the gradient color while preserving the text's transparency
    COLOR = vec4(gradient_color.rgb, text_color.a);
}