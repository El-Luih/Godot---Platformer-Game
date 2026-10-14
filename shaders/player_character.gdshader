/*
Canvas item shader that turns a sprite into a monochrome version of itself, 
tinted with a single color. Brightness can be adjusted from the Inspector.
*/

shader_type canvas_item;

/*
Color used to tint the sprite. "source_color" shows a color picker in the editor.
Its alpha is not used.
*/
uniform vec4 tint_color : source_color = vec4(0.5, 0.5, 0.9, 1.0); 
/*
Scales each pixel's brightness. 1.0 keeps it as is.
"hint_range" shows it as a slider limited to 1.0 - 3.0.
*/
uniform float brightness_multiplier : hint_range(1.0, 3.0) = 1.2;

/*
Built-in function. Called by the engine once for every pixel the node draws.
Converts the image to a monochrome version using "tint_color" as the hue.
*/
void fragment() {
    //Gets the texture color at this pixel ("UV" goes from 0.0 to 1.0 on each axis).
    vec4 current_color = texture(TEXTURE, UV);
    /*
    Calculates the pixel's perceived brightness (luminance) as a weighted sum of its channels.
    Green weighs the most because the eye is most sensitive to it.
    */
    float brightness = dot(current_color.rgb, vec3(0.299, 0.587, 0.114));
    //Applies the multiplier and caps the result at 1.0.
    brightness = min(brightness * brightness_multiplier, 1.0);
    //Scales the tint color by the brightness: dark pixels go black, bright ones approach the tint.
    vec3 monochrome = tint_color.rgb * brightness;
    //Sets the final color, keeping the original alpha so transparent areas stay transparent.
    COLOR = vec4(monochrome, current_color.a);
}