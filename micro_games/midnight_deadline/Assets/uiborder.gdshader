shader_type canvas_item;

uniform vec4 top_left_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);        // #FFFFFF
uniform vec4 bottom_right_color : source_color = vec4(0.192, 0.192, 0.192, 1.0); // #313131
uniform float border_width : hint_range(0.0, 100.0) = 10.0;

// TEXTURE_PIXEL_SIZE describes the bound TEXTURE's resolution, not this
// node's on-screen rect - on a ColorRect (no texture) it's 1.0, which is
// why border_width was swallowing the whole node. Rect size has to be
// supplied explicitly; see ui_border_sync.gd, which keeps this in sync
// with the node's actual size automatically.
uniform vec2 rect_size = vec2(100.0, 100.0);

void fragment() {
    vec2 size = rect_size;
    vec2 pos = UV * size;

    float dist_top = pos.y;
    float dist_left = pos.x;
    float dist_bottom = size.y - pos.y;
    float dist_right = size.x - pos.x;

    bool is_border = (dist_top < border_width) || (dist_left < border_width) || 
                     (dist_bottom < border_width) || (dist_right < border_width);

    if (is_border) {
        float min_dist = min(min(dist_top, dist_left), min(dist_bottom, dist_right));
        if (min_dist == dist_top || min_dist == dist_left) {
            COLOR = top_left_color;
        } else {
            COLOR = bottom_right_color;
        }
    }
}