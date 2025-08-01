shader_type spatial;
render_mode blend_mix;

uniform sampler2D albedo_texture;
uniform vec3 albedo_multiplier = vec3(.96, .135, .115);
uniform float scroll_speed = 0.1;
uniform vec2 scale = vec2(.25, 50.0);

void fragment() {
    vec2 uv = UV * scale;

    // Scroll along the Y axis of the texture (which maps to Z in world space)
    uv.x -= TIME * scroll_speed;

    vec4 tex = texture(albedo_texture, uv);
    ALBEDO = tex.rgb * albedo_multiplier;
    ALPHA = .99;
}
