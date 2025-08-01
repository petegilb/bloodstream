shader_type spatial;
//render_mode blend_mix;

uniform sampler2D albedo_texture;
uniform vec3 albedo_multiplier = vec3(.96, .135, .115);
uniform vec2 scroll_speed_1 = vec2(0.05, 0.0);
uniform vec2 scroll_speed_2 = vec2(-0.03, 0.0);
uniform vec2 scale = vec2(10.0);
uniform vec2 scale2 = vec2(10.0);
uniform float blend_factor = 0.5;

void fragment() {
    vec2 uv = UV * scale;
	vec2 uv2 = UV * scale2;

    // Scroll along the Y axis of the texture (which maps to Z in world space)
    uv += TIME * scroll_speed_1;
	uv2 += TIME * scroll_speed_2;

    vec4 color_1 = texture(albedo_texture, uv);
	vec4 color_2 = texture(albedo_texture, uv2);
	vec4 blended_colors = mix(color_1, color_2, blend_factor);
    ALBEDO = blended_colors.rgb * albedo_multiplier;
    ALPHA = .9;
	METALLIC = 0.0;
    ROUGHNESS = 1.0;
}
