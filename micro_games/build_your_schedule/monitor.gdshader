shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;
const vec2 MONITOR_SIZE = vec2(360.0, 180.0);
const float FISHEYE_AMOUNT = 0.3;
const float SAMPLE_DISTANCE = 0.001;
const float DETAIL = 0.2;
const float SCANLINE_DISTANCE = 2.0;
const float SCANLINE_THICKNESS = 0.6;
const float SCANLINE_SPEED = -1.0;
const float SCANLINE_INTENSITY = 0.5;
const vec3 ABBERATION = vec3(0.009, 0.006, -0.006);

const vec2 CENTER = vec2(0.5);

vec4 textureLodAbberate(sampler2D sampler, vec2 uv, float detail) {
	vec4 color = vec4(1.0);
	vec2 center_direction = uv - CENTER;
	color.r = textureLod(sampler, uv + (center_direction * vec2(ABBERATION.r)), DETAIL).r;
	color.g = textureLod(sampler, uv + (center_direction * vec2(ABBERATION.g)), DETAIL).g;
	color.b = textureLod(sampler, uv + (center_direction * vec2(ABBERATION.b)), DETAIL).b;
	return color;
}

vec4 blur(vec2 screen_uv) {
	vec4 COLOR_UP = textureLodAbberate(screen_texture, screen_uv - vec2(0.0, SAMPLE_DISTANCE), DETAIL);
	vec4 COLOR_DOWN = textureLodAbberate(screen_texture, screen_uv + vec2(0.0, SAMPLE_DISTANCE), DETAIL);
	vec4 COLOR_LEFT = textureLodAbberate(screen_texture, screen_uv - vec2(SAMPLE_DISTANCE, 0.0), DETAIL);
	vec4 COLOR_RIGHT = textureLodAbberate(screen_texture, screen_uv + vec2(SAMPLE_DISTANCE, 0.0), DETAIL);
    vec4 COLOR_CENTER = textureLodAbberate(screen_texture, screen_uv, DETAIL);
	return (COLOR_CENTER + COLOR_UP + COLOR_DOWN + COLOR_LEFT + COLOR_RIGHT) / 5.0;
}

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	float center_distance = distance(screen_uv, CENTER);
	vec2 center_direction = normalize(screen_uv - CENTER);
	float bind = length(CENTER);
	screen_uv = CENTER + center_direction * tan(center_distance * FISHEYE_AMOUNT) * bind / tan(bind * FISHEYE_AMOUNT);
	float y = screen_uv.y * MONITOR_SIZE.y;
	COLOR = blur(screen_uv);
	y += TIME * SCANLINE_SPEED;
	float scanline_intensity = SCANLINE_INTENSITY - abs(mod(y, SCANLINE_DISTANCE) - SCANLINE_DISTANCE / 2.0) / SCANLINE_THICKNESS;
	scanline_intensity = clamp(scanline_intensity, 0.0, 1.0) / 2.0;
	COLOR.rgb -= scanline_intensity;
}