shader_type spatial;
render_mode blend_mix; // or use `blend_mix` if you want lighting

uniform sampler2D albedo_texture;
uniform vec3 albedo_multiplier = vec3(1.0);
uniform float scroll_speed = 0.1;
uniform vec2 scale = vec2(.25, 50.0);

void fragment() {
    vec3 world_pos = NODE_POSITION_WORLD;
    vec2 uv = UV * scale;

    // Scroll along the Y axis of the texture (which maps to Z in world space)
    uv.x -= TIME * scroll_speed;

    vec4 tex = texture(albedo_texture, uv);
    ALBEDO = tex.rgb * albedo_multiplier;
    ALPHA = tex.a;
}
