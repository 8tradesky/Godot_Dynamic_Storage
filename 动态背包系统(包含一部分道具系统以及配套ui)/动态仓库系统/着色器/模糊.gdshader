shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0, 10) = 3.0;
uniform float node_blur_amount : hint_range(0, 10) = 1.0;

void fragment() {
    vec2 pixel_size = blur_amount * SCREEN_PIXEL_SIZE;
    vec4 screen_blur_color = vec4(0.0);
    vec4 node_blur_color = vec4(0.0);
    float weight_total = 0.0;
    
    // 高斯核权重（5x5）
    float weights[25] = float[](
        0.003765, 0.015019, 0.023792, 0.015019, 0.003765,
        0.015019, 0.059912, 0.094907, 0.059912, 0.015019,
        0.023792, 0.094907, 0.150342, 0.094907, 0.023792,
        0.015019, 0.059912, 0.094907, 0.059912, 0.015019,
        0.003765, 0.015019, 0.023792, 0.015019, 0.003765
    );
    
    // 模糊屏幕纹理
    int index = 0;
    for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
            vec2 offset = vec2(float(i), float(j)) * pixel_size;
            screen_blur_color += textureLod(SCREEN_TEXTURE, SCREEN_UV + offset, 0.0) * weights[index];
            weight_total += weights[index];
            index++;
        }
    }
    screen_blur_color /= weight_total;
    
    // 模糊节点颜色（使用较小的模糊半径）
    vec2 node_pixel_size = node_blur_amount * SCREEN_PIXEL_SIZE;
    vec4 node_color_blur = vec4(0.0);
    weight_total = 0.0;
    index = 0;
    
    for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
            vec2 offset = vec2(float(i), float(j)) * node_pixel_size;
            // 使用节点的颜色作为基础
            node_color_blur += COLOR * weights[index];
            weight_total += weights[index];
            index++;
        }
    }
    node_color_blur /= weight_total;
    
    // 混合结果
    COLOR = mix(screen_blur_color, node_color_blur, 0.5);
}