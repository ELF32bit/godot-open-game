shader_type spatial;
render_mode diffuse_lambert, specular_disabled, cull_disabled;

uniform sampler2D albedo_texture: source_color;
uniform float flow_intensity = 0.15;
uniform float flow_speed = 2.0;


void fragment() {
	vec2 flow_uv;
	flow_uv.x = UV.x + flow_intensity * sin(TIME * flow_speed + UV.y);
	flow_uv.y = UV.y + flow_intensity * sin(TIME * flow_speed + UV.x);
	ALBEDO = texture(albedo_texture, flow_uv).rgb;
	METALLIC = 0.0; SPECULAR = 0.0;
}
