#version 460 core

in vec3 color;
in vec2 coord;
out vec4 FragColor;

uniform sampler2D map;

void main() {
    FragColor = vec4(mix(texture(map, coord).rgb, color, 0.1f), 1.0f);
}
