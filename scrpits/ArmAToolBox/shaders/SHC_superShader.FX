/*** Modernized ShaderFX Shader for 3ds Max ***/
float3 color_ambient <
    string UIName = "Ambient Color";
    string UIType = "ColorSwatch";
> = {1.0f, 1.0f, 1.0f};

float3 color_diffuse <
    string UIName = "Diffuse Color";
    string UIType = "ColorSwatch";
> = {1.0f, 1.0f, 1.0f};

float3 color_spec <
    string UIName = "Specular Color";
    string UIType = "ColorSwatch";
> = {1.0f, 1.0f, 1.0f};

bool UIBool_6933 <
    string UIName = "Use Fresnel in preview?";
> = true;

float FresnelPower <
    string UIName = "Fresnel Power";
    float UIMin = 0.0;
    float UIMax = 10.0;
    float UIStep = 0.01;
> = 0.07;

float FresnelScale <
    string UIName = "Fresnel Scale";
    float UIMin = 0.0;
    float UIMax = 5.0;
    float UIStep = 0.01;
> = 1.0;

float FresnelBias <
    string UIName = "Fresnel Bias";
    float UIMin = -1.0;
    float UIMax = 1.0;
    float UIStep = 0.01;
> = 0.88;

float spec <
    string UIName = "Specular Power";
    float UIMin = 1.0;
    float UIMax = 256.0;
    float UIStep = 0.1;
> = 60.0;

// Textures
texture TextureMap_7634 <
    string Name = "sa_bmd1_03_co.tga";
    string UIName = "Diffuse (CO)";
    string ResourceType = "2D";
>;
sampler2D TextureMap_7634Sampler = sampler_state {
    Texture = <TextureMap_7634>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

texture TextureMap_5485 <
    string Name = "turret_ao_as.tga";
    string UIName = "Ambient Shadow (AS)";
    string ResourceType = "2D";
>;
sampler2D TextureMap_5485Sampler = sampler_state {
    Texture = <TextureMap_5485>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

texture TextureMap_4534 <
    string Name = "sa_bmd1_03_smdi.tga";
    string UIName = "Specular (SMDI)";
    string ResourceType = "2D";
>;
sampler2D TextureMap_4534Sampler = sampler_state {
    Texture = <TextureMap_4534>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

texture TextureMap_8047 <
    string Name = "detailtex_dt.tga";
    string UIName = "Detail (DT)";
    string ResourceType = "2D";
>;
sampler2D TextureMap_8047Sampler = sampler_state {
    Texture = <TextureMap_8047>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

texture NormalMap_5786 <
    string Name = "sa_bmd1_03_nohq.tga";
    string UIName = "Normal (NOHQ)";
    string ResourceType = "2D";
>;
sampler2D NormalMap_5786Sampler = sampler_state {
    Texture = <NormalMap_5786>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Wrap;
};

texture UICubeMap_7142 <
    string Name = "OutputCube.dds";
    string UIName = "Cube Map";
    string type = "Cube";
>;
samplerCUBE UICubeMap_7142Sampler = sampler_state {
    Texture = <UICubeMap_7142>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

// Matrices
float4x4 wvp : WorldViewProjection;
float4x4 world : World;
float4x4 viewInv : ViewInverse;

// Tangent Space Matrix
float3x3 CreateTangentSpace(float3 normal, float3 tangent, float3 binormal) {
    #ifdef YUP
        return float3x3(tangent, -binormal, normal);
    #else
        return float3x3(binormal, -tangent, normal);
    #endif
}

// Vertex Input
struct VS_INPUT {
    float4 position : POSITION;
    float3 normal   : NORMAL;
    float2 texCoord : TEXCOORD0;
    float3 tangent  : TANGENT;
    float3 binormal : BINORMAL;
};

// Vertex Output
struct PS_INPUT {
    float4 position : SV_POSITION;
    float2 texCoord : TEXCOORD0;
    float3 viewDir  : TEXCOORD1;
    float3 lightDir : TEXCOORD2;
    float3 worldNormal : TEXCOORD3;
};

// Vertex Shader
PS_INPUT VS_Main(VS_INPUT input) {
    PS_INPUT output = (PS_INPUT)0;
    output.position = mul(input.position, wvp);
    output.texCoord = input.texCoord;

    // Tangent space matrix
    float3 N = normalize(mul((float3x3)world, input.normal));
    float3 T = normalize(mul((float3x3)world, input.tangent));
    float3 B = cross(N, T);
    float3x3 TBN = float3x3(T, B, N);

    // View direction in tangent space
    float3 worldPos = mul(input.position, world).xyz;
    float3 eyePos = viewInv[3].xyz;
    output.viewDir = mul(TBN, eyePos - worldPos);

    // Light direction (example: directional light)
    float3 lightDirWorld = normalize(float3(1, 1, 1));
    output.lightDir = mul(TBN, lightDirWorld);

    output.worldNormal = N;
    return output;
}

// Pixel Shader
float4 PS_Main(PS_INPUT input) : SV_Target {
    float3 V = normalize(input.viewDir);
    float3 L = normalize(input.lightDir);
    
    // Load normal map and convert to [-1, 1]
    float3 N = tex2D(NormalMap_5786Sampler, input.texCoord).rgb * 2 - 1;
    N.xy *= 1.0; // Adjust normal intensity if needed
    N = normalize(N);
    
    // Diffuse
    float3 diffuseTex = tex2D(TextureMap_7634Sampler, input.texCoord).rgb;
    float ao = tex2D(TextureMap_5485Sampler, input.texCoord).g;
    float3 ambient = color_ambient * diffuseTex * 0.3;
    float3 diffuse = saturate(dot(N, L)) * diffuseTex * color_diffuse * ao;

    // Specular
    float3 H = normalize(L + V);
    float glossiness = spec;
    float3 specular = pow(saturate(dot(N, H)), glossiness) * 
                     tex2D(TextureMap_4534Sampler, input.texCoord).g * 
                     color_spec;

    // Fresnel
    float fresnel = pow(1 - dot(V, N), FresnelPower) * FresnelScale + FresnelBias;
    
    // Environment Reflection
    float3 reflection = texCUBE(UICubeMap_7142Sampler, reflect(-V, N)).rgb;
    
    // Final blend
    float3 finalColor = lerp(reflection, diffuse, fresnel) + specular;

    return float4(finalColor, 1);
}

technique ShaderFX_Technique {
    pass P0 {
        VertexShader = compile vs_3_0 VS_Main();
        PixelShader = compile ps_3_0 PS_Main();
    }
}