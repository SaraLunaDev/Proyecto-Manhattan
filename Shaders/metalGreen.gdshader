shader_type spatial;
render_mode specular_schlick_ggx;

uniform sampler2D env_texture;
uniform vec3 metal_color = vec3(0.588,  0.984, 0.780);
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    ALBEDO = metal_color;
    METALLIC = metallic;
    ROUGHNESS = roughness;

    vec3 view_dir = normalize(-NORMAL);
    vec2 env_uv = vec2(0.5 + 0.5 * view_dir.x, 0.5 - 0.5 * view_dir.y);
    vec3 env_reflection = texture(env_texture, env_uv).rgb;

    EMISSION = env_reflection * 0.5;
}