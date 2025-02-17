#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

uniform vec2 offset; // Offset of the scale.
uniform float zoom; // Zoom of the scale.

const int maxIterations = 1200; // Max iterations to do.
const float colorCycles = 2.0; // Number of times the color palette repeats. Can show higher detail for higher iteration numbers.

// Square a complex number
vec2 ComplexSquare(vec2 z)
{
    return vec2(z.x * z.x - z.y * z.y, z.x * z.y * 2.0);
}

// Convert Hue Saturation Value (HSV) color into RGB
vec3 Hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    // The pixel coordinates are scaled so they are on the mandelbrot scale
    // NOTE: fragTexCoord already comes as normalized screen coordinates but
    // offset must be normalized before scaling and zoom
    vec2 uv = vec2((fragTexCoord.x - 0.5), (fragTexCoord.y - 0.5)) / (zoom);
    uv.x += offset.x;
    uv.y += offset.y;

    vec2 z = vec2(0.0, 0.0);

    int iterations = 0;
    for (iterations = 0; iterations < maxIterations; iterations++)
    {
        z = ComplexSquare(z) + uv; // Iterate function

        if (dot(z, z) > 4.0) break;
    }

    // Another few iterations decreases errors in the smoothing calculation.
    // See http://linas.org/art-gallery/escape/escape.html for more information.
    z = ComplexSquare(z) + z;
    z = ComplexSquare(z) + z;

    // This last part smooths the color (again see link above).
    float smoothVal = float(iterations) + 1.0 - (log(log(length(z))) / log(2.0));

    // Normalize the value so it is between 0 and 1.
    float norm = smoothVal / float(maxIterations);

    // If in set, color black. 0.999 allows for some float accuracy error.
    if (norm > 0.999) finalColor = vec4(0.0, 0.0, 0.0, 1.0);
    else finalColor = vec4(Hsv2rgb(vec3(0.0, 0.0, sqrt(norm * colorCycles))), 1.0);
}
