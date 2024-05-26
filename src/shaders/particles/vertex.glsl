uniform vec2 uResolution;
uniform float uSize;
uniform float uProgress;

attribute vec3 aPositionTarget;

varying vec3 vColor;

#include ../includes/simplexNoise3d.glsl

void main()
{
    // Mixed position
    float noiseOrigin = simplexNoise3d(position); // remember that position is a vec3
    float noiseTarget = simplexNoise3d(aPositionTarget);
    float noise = mix(noiseOrigin, noiseTarget, uProgress); // this fixed the issue where we were using Suzanne as initial refernce for position, which made simplex noise work only at the beginning, with Suzanne morphing into the Three.js text, but not the other way around, and this fixes the issue
    noise = smoothstep(-1.0, 1.0, noise);

    float duration = 0.4;
    float delay = (1.0 - duration) * noise; // being a value that goes from 0 to 1, to obtain the morphing effect we subtract the 1.0 by the duration so that the morphing effect is "delayed
    float end = delay + duration;
    float progress = smoothstep(delay, end, uProgress);
    vec3 mixedPosition = mix(position, aPositionTarget, progress);

    // Final position
    vec4 modelPosition = modelMatrix * vec4(mixedPosition, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    gl_Position = projectedPosition;

    // Point size
    gl_PointSize = uSize * uResolution.y;
    gl_PointSize *= (1.0 / - viewPosition.z);

    // Varyings
    vColor = vec3(noise);
}