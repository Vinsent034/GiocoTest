shader_type canvas_item;

uniform float flash_intensita : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 colore = texture(TEXTURE, UV);
	colore.rgb = mix(colore.rgb, vec3(1.0), flash_intensita);
	COLOR = colore;
}
