#version 100
#extension GL_EXT_draw_buffers: enable
precision highp float;

uniform sampler2D u_colmap;
uniform sampler2D u_normap;
uniform mat4 u_viewMatrix;
uniform mat4 u_viewProjectionMatrix;

varying vec3 v_position;
varying vec3 v_normal;
varying vec2 v_uv;

vec3 applyNormalMap(vec3 geomnor, vec3 normap) {
    normap = normap * 2.0 - 1.0;
    vec3 up = normalize(vec3(0.001, 1, 0.001));
    vec3 surftan = normalize(cross(geomnor, up));
    vec3 surfbinor = cross(geomnor, surftan);
    return normap.y * surftan + normap.x * surfbinor + normap.z * geomnor;
}

void main() {
    vec3 norm  = applyNormalMap(v_normal, vec3(texture2D(u_normap, v_uv)));
    vec3 normV = normalize(vec3(u_viewMatrix * vec4(norm, 0.0)));
    vec3 col   = vec3(texture2D(u_colmap, v_uv));
    vec4 ndcV  = u_viewProjectionMatrix * vec4(v_position, 1.0);
    ndcV /= ndcV.w;


    // Two Compact G-Buffer
    // gl_FragData[0] = vec4(ndcV.z, 0.0, 0.0,normV.x);
    // gl_FragData[1] = vec4(col, normV.y);

    // Two G-Buffer
    // gl_FragData[0] = vec4(v_position, normV.x);
    // gl_FragData[1] = vec4(col, normV.y);

    // Three G-Buffer
    gl_FragData[0] = vec4(v_position, normV.x);
    gl_FragData[1] = vec4(col, normV.y);
    gl_FragData[2] = vec4(norm, ndcV.z);
}