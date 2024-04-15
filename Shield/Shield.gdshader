shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D distortionTexture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    // Get the UV coordinates
    vec2 uv = SCREEN_UV;

    // Sample from the distortion texture
    vec4 distortion = texture(distortionTexture, uv);

    // Apply distortion effect to UV coordinates for both textures, shifting it to the right
    vec2 distortedUV = uv + vec2(distortion.r * 0.04 - 0.02, 0);

    // Sample from the screen texture using the distorted UV coordinates
    vec4 screenColor = texture(SCREEN_TEXTURE, distortedUV);

    // Sample from the texture to draw on top using the original UV coordinates
    vec4 textureColor = texture(TEXTURE, UV) * 0.3;

    // Output the combined color
    // Multiply the alpha of the texture to draw on top to control its opacity
    COLOR = (screenColor + textureColor) * texture(TEXTURE, UV).a;
}
