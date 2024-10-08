#version 460 core
#extension GL_NV_shadow_samplers_cube : enable

in vec2 coord;
in vec3 WorldPos;
in vec3 Normal;

out vec4 FragColor;

// lights
uniform vec3 lightPositions[4];
uniform vec3 lightColors[4];

// IBL
uniform samplerCube irradianceMap;
uniform samplerCube prefilterMap;
uniform sampler2D brdfLUT;

uniform vec3 camPos;

// material parameters
uniform vec3 albedo;
uniform float metallic;
uniform float roughness;
uniform float ao;

const float PI = 3.14159265359;

float DistributionGGX(vec3 N, vec3 H, float roughness)
{
    float a_pow2 = pow(roughness, 2.0);
    float NdotH_pow2 = pow(max(dot(N, H), 0.0), 2.0);

    float nom = a_pow2;
    float denom = PI * pow((NdotH_pow2 * (a_pow2 - 1) + 1), 2.0);

    return nom/max(denom, 0.001);
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float k = pow((roughness+1), 2.0) / 8.0;

    return NdotV / (NdotV * (1-k) + k);
}

float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);

    float ggx1 = GeometrySchlickGGX(NdotV, roughness);
    float ggx2 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1*ggx2;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow((1.0 - cosTheta), 5.0);
}

vec3 fresnelSchlickRoughness(float cosTheta, vec3 F0, float roughness)
{
    return F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow(1.0 - cosTheta, 5.0);
}

void main()
{
    vec3 N = normalize(Normal);
    vec3 V = normalize(camPos - WorldPos);
    vec3 R = reflect(-V, N);

    vec3 F0 = vec3(0.04);
    F0 = mix(F0, albedo, metallic);

    vec3 Lo = vec3(0.0);
    for (int i=0; i<4; ++i)
    {
        // Step1
        vec3 L = normalize(lightPositions[i] - WorldPos);
        vec3 H = normalize(V + L);
        float distance = length(lightPositions[i] - WorldPos);
        float attenuation = 1.0 / (distance * distance);
        vec3 radiance = lightColors[i] * attenuation;

        // Step2 Cook-Torrance BRDF
        float NDF = DistributionGGX(N, H, roughness);
        float G   = GeometrySmith(N, V, L, roughness);
        vec3 F    = fresnelSchlick(clamp(dot(H, V), 0.0, 1.0), F0);

        // Step3
        vec3 nominator = NDF * G * F;
        float denominator = 4 * max(dot(V, N), 0.0) * max(dot(L, N), 0.0);
        vec3 specular = nominator / (max(denominator, 0.001));

        // Step4
        vec3 kS = F;
        vec3 kD = vec3(1.0) - kS;
        kD *= 1.0 - metallic;

        // Step5
        float NdotL = max(dot(N, L), 0.0);

        // Step6
        Lo += (kD * albedo / PI + specular) * radiance * NdotL;
    }

    // Step7
    vec3 kS = fresnelSchlickRoughness(max(dot(N, V), 0.0), F0, roughness);
    vec3 kD = 1.0 - kS;
    kD *= 1.0 - metallic;
    vec3 irradiance = textureCube(irradianceMap, N).rgb;
    vec3 diffuse    = irradiance * albedo;
    // sample both the pre-filter map and the BRDF lut and combine them together as per the Split-Sum approximation to get the IBL specular part.
    const float MAX_REFLECTION_LOD = 4.0;
    vec3 prefilteredColor = textureLod(prefilterMap, R,  roughness * MAX_REFLECTION_LOD).rgb;
    vec2 brdf  = texture(brdfLUT, vec2(max(dot(N, V), 0.0), roughness)).rg;
    vec3 specular = prefilteredColor * (kS * brdf.x + brdf.y);
    vec3 ambient = (kD * diffuse + specular) * ao;

    vec3 color = ambient + Lo;

    // HDR tonemapping
    color = color / (color + vec3(1.0));
    // gamma correct
    color = pow(color, vec3(1.0/2.2));

    FragColor = vec4(color , 1.0);
}
