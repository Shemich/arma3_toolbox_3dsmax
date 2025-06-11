// sa_bmd1_03_fixed.hlsl — Modernized for 3ds Max HLSL compiler

// Parameters (without annotations)
float3 color_ambient = {1.0f, 1.0f, 1.0f};
float3 color_diffuse = {1.0f, 1.0f, 1.0f};
float3 color_spec = {1.0f, 1.0f, 1.0f};

float FresnelPower = 0.07;
float FresnelScale = 1.0;
float FresnelBias = 0.88;

float spec = 60.0;

// Textures
texture UICubeMap_7142; // Cube Map
texture TextureMap_7634; // Diffuse (CO)
texture TextureMap_5485; // Ambient Shadow (AS)
texture TextureMap_4534; // Specular (SMDI)
texture TextureMap_8047; // Detail (DT)
texture NormalMap_5786; // Normal (NOHQ)

// Samplers
samplerCUBE UICubeMap_7142Sampler = sampler_state {
    Texture = <UICubeMap_7142>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

sampler2D TextureMap_7634Sampler = sampler_state {
    Texture = <TextureMap_7634>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler2D TextureMap_5485Sampler = sampler_state {
    Texture = <TextureMap_5485>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler2D TextureMap_4534Sampler = sampler_state {
    Texture = <TextureMap_4534>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler2D TextureMap_8047Sampler = sampler_state {
    Texture = <TextureMap_8047>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

sampler2D NormalMap_5786Sampler = sampler_state {
    Texture = <NormalMap_5786>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

// Matrices
float4x4 wvp : WorldViewProjection;
float4x4 world : World;
float4x4 viewInv : ViewInverse;

// Input from vertex buffer
struct VS_INPUT {
    float4 position : POSITION;
    float3 normal   : NORMAL;
    float2 texCoord : TEXCOORD0;
    float3 tangent  : TANGENT;
    float3 binormal : BINORMAL;
};

// Output to pixel shader
struct PS_INPUT {
    float4 position : SV_POSITION;
    float2 texCoord : TEXCOORD0;
    float3 viewDir  : TEXCOORD1;
};

PS_INPUT VS_Main(VS_INPUT input) {
    PS_INPUT output = (PS_INPUT)0;
    output.position = mul(input.position, wvp);
    output.texCoord = input.texCoord;

    float3 worldPos = mul(input.position, world).xyz;
    float3 eyePos = viewInv[3].xyz;
    output.viewDir = normalize(eyePos - worldPos);

    return output;
}

float4 PS_Main(PS_INPUT input) : SV_Target {
    float3 V = normalize(input.viewDir);

    // Load textures
    float4 diffuseTex = tex2D(TextureMap_7634Sampler, input.texCoord);
    float ao = tex2D(TextureMap_5485Sampler, input.texCoord).g;
    float3 N = tex2D(NormalMap_5786Sampler, input.texCoord).rgb * 2 - 1;
    N = normalize(N);

    // Fresnel
    float fresnel = pow(1 - dot(V, N), FresnelPower) * FresnelScale + FresnelBias;

    // Reflection
    float3 reflection = texCUBE(UICubeMap_7142Sampler, reflect(-V, N)).rgb;

    // Final color
    float3 finalColor = lerp(reflection, diffuseTex.rgb * color_diffuse, fresnel);

    return float4(finalColor, 1.0);
}

technique Default_Technique {
    pass P0 {
        VertexShader = compile vs_3_0 VS_Main();
        PixelShader  = compile ps_3_0 PS_Main();
    }
}