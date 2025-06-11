
/*** Generated through Lumonix shaderFX  by: Alex & Ramune in 3dsmax at: 20-10-2009 1:00:06 AM  ***/ 

// This FX shader was built to support 3ds Max's standard shader compiler. 


float3 color_ambient
<
	string UIName = "Ambient Color";
	string UIType = "ColorSwatch";
> = {1.0f, 1.0f, 1.0f};
 
bool UIBool_6933
<
	string UIName = "Use Fresnel in preview?";
> = true;
 
texture UICubeMap_7142 : environment
<
	string Name = "OutputCube.dds";
	string UIName = "Cube Map";
	string type = "Cube";
>;
 
samplerCUBE UICubeMap_7142Sampler = sampler_state
{
	Texture = <UICubeMap_7142>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};
 
texture TextureMap_7634
<
	string Name = "sa_bmd1_03_co.tga";
	string UIName = "Diffuse (CO)";
	string ResourceType = "2D";
>;
 
sampler2D TextureMap_7634Sampler = sampler_state
{
	Texture = <TextureMap_7634>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
texture TextureMap_5485
<
	string Name = "turret_ao_as.tga";
	string UIName = "Ambient Shadow (AS)";
	string ResourceType = "2D";
>;
 
sampler2D TextureMap_5485Sampler = sampler_state
{
	Texture = <TextureMap_5485>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
float3 color_diffuse
<
	string UIName = "Diffuse Color";
	string UIType = "ColorSwatch";
> = {1.0f, 1.0f, 1.0f};
 
float FresnelPower
<
	string UIType = "FloatSpinner";
	float UIMin = 0.0;
	float UIMax = 100.0;
	float UIStep = 0.01;
	string UIName = "Fresnel Power";
> = 0.07;
 
float FresnelScale
<
	string UIType = "FloatSpinner";
	float UIMin = 0.0;
	float UIMax = 100.0;
	float UIStep = 0.01;
	string UIName = "Fresnel Scale";
> = 1.0;
 
float FresnelBias
<
	string UIType = "FloatSpinner";
	float UIMin = -100.0;
	float UIMax = 100.0;
	float UIStep = 0.01;
	string UIName = "Fresnel Bias";
> = 0.88;
 
float3 color_spec
<
	string UIName = "Specular Color";
	string UIType = "ColorSwatch";
> = {1.0f, 1.0f, 1.0f};
 
texture TextureMap_4534 : SpecularMap
<
	string Name = "sa_bmd1_03_smdi.tga";
	string UIName = "Specular (SMDI)";
	string ResourceType = "2D";
>;
 
sampler2D TextureMap_4534Sampler = sampler_state
{
	Texture = <TextureMap_4534>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
float spec
<
	string UIType = "FloatSpinner";
	float UIMin = -999.0;
	float UIMax = 999.0;
	float UIStep = 0.1;
	string UIName = "Specular Power";
> = 60.0;
 
texture TextureMap_8047
<
	string Name = "detailtex_dt.tga";
	string UIName = "Detail (DT)";
	string ResourceType = "2D";
>;
 
sampler2D TextureMap_8047Sampler = sampler_state
{
	Texture = <TextureMap_8047>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
texture NormalMap_5786 : NormalMap
<
	string Name = "sa_bmd1_03_nohq.tga";
	string UIName = "Normal (NOHQ)";
	string ResourceType = "2D";
>;
 
sampler2D NormalMap_5786Sampler = sampler_state
{
	Texture = <NormalMap_5786>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};
 
// this function does the different types of light attenuation 
float attenuation_func(int lightattenType, float4 lightAttenuation, float3 lightVec) 
{ 
	float att = 1.0; 
	return att; 
} 
	 
// this function does the different types of cone angle 
float coneangle_func(int lightconeType, float lightHotspot, float lightFalloff, float3 lightVec, float3 lightDir) 
{ 
	float cone = 1.0; 
	float LdotDir = dot(normalize(lightVec), lightDir); 
	if (lightconeType == 2) // quality spot cone angle - ~18 instructions  
		cone = smoothstep(cos(lightFalloff),cos(lightHotspot), LdotDir); //using the hotspot and falloff params  
	return cone; 
} 

/************** light info **************/ 

float3 light1Dir : Direction 
< 
	string UIName = "Light 1 Direction"; 
	string Object = "TargetLight"; 
	string Space = "World"; 
		int refID = 1; 
> = {100.0f, 100.0f, 100.0f}; 

float3 light1Pos : POSITION 
< 
	string UIName = "Light 1 Position"; 
	string Object = "PointLight"; 
	string Space = "World"; 
		int refID = 1; 
> = {100.0f, 100.0f, 100.0f}; 

float4 light1Color : LIGHTCOLOR <int LightRef = 1; string UIWidget = "None"; > = { 1.0f, 1.0f, 1.0f, 1.0f}; 
float4 light1Attenuation : LightAttenuation <int LightRef = 1; string UIWidget = "None"; > = { 20.0f, 30.0f, 0.0f, 100.0f}; 
float light1Hotspot : LightHotSpot <int LightRef = 1; string UIWidget = "None"; > = { 43.0f }; 
float light1Falloff : LightFallOff <int LightRef = 1; string UIWidget = "None"; > = { 45.0f }; 

#define light1Type 3
#define light1attenType 0
#define light1coneType 2
#define light1CastShadows false

//---------------------------------- 

float3 light2Dir : Direction 
< 
	string UIName = "Light 2 Direction"; 
	string Object = "TargetLight"; 
	string Space = "World"; 
		int refID = 2; 
> = {100.0f, 100.0f, 100.0f}; 

float3 light2Pos : POSITION 
< 
	string UIName = "Light 2 Position"; 
	string Object = "PointLight"; 
	string Space = "World"; 
		int refID = 2; 
> = {100.0f, 100.0f, 100.0f}; 

float4 light2Color : LIGHTCOLOR <int LightRef = 2; string UIWidget = "None"; > = { 1.0f, 1.0f, 1.0f, 1.0f}; 
float4 light2Attenuation : LightAttenuation <int LightRef = 2; string UIWidget = "None"; > = { 20.0f, 30.0f, 0.0f, 100.0f}; 
float light2Hotspot : LightHotSpot <int LightRef = 2; string UIWidget = "None"; > = { 43.0f }; 
float light2Falloff : LightFallOff <int LightRef = 2; string UIWidget = "None"; > = { 45.0f }; 

#define light2Type 3
#define light2attenType 0
#define light2coneType 2
#define light2CastShadows false

//---------------------------------- 

float3 light3Dir : Direction 
< 
	string UIName = "Light 3 Direction"; 
	string Object = "TargetLight"; 
	string Space = "World"; 
		int refID = 3; 
> = {100.0f, 100.0f, 100.0f}; 

float3 light3Pos : POSITION 
< 
	string UIName = "Light 3 Position"; 
	string Object = "PointLight"; 
	string Space = "World"; 
		int refID = 3; 
> = {100.0f, 100.0f, 100.0f}; 

float4 light3Color : LIGHTCOLOR <int LightRef = 3; string UIWidget = "None"; > = { 1.0f, 1.0f, 1.0f, 1.0f}; 
float4 light3Attenuation : LightAttenuation <int LightRef = 3; string UIWidget = "None"; > = { 20.0f, 30.0f, 0.0f, 100.0f}; 
float light3Hotspot : LightHotSpot <int LightRef = 3; string UIWidget = "None"; > = { 43.0f }; 
float light3Falloff : LightFallOff <int LightRef = 3; string UIWidget = "None"; > = { 45.0f }; 

#define light3Type 3
#define light3attenType 0
#define light3coneType 2
#define light3CastShadows false

//---------------------------------- 


float4x4 wvp : WorldViewProjection < string UIType = "None"; >;  
float4x4 worldI : WorldInverse < string UIType = "None"; >;  
float4x4 worldIT : WorldInverseTranspose < string UIType = "None"; >;  
float4x4 viewInv : ViewInverse < string UIType = "None"; >;  
float4x4 world : World < string UIType = "None"; >;  
// create the light vector 
float3 lightVec_func(float3 worldSpacePos, float3 lightVector, float3x3 objTangentXf, int lightType) 
{ 
	float3 lightVec = mul(objTangentXf, (mul((lightVector - worldSpacePos), worldI).xyz)); 
	return lightVec; 
} 


// input from application 
	struct a2v { 
	float4 position		: POSITION; 
	float4 tangent		: TANGENT; 
	float4 binormal		: BINORMAL; 
	float4 normal		: NORMAL; 

	float2 texCoord		: TEXCOORD0; 

}; 

// output to fragment program 
struct v2f { 
        float4 position    		: POSITION; 
        float3 lightVec    		: TEXCOORD0; 
        float3 eyeVec	    	: TEXCOORD1; 
        float3 lightDir		    : TEXCOORD2; 

        float3 worldTangent  	: TEXCOORD3; 
        float3 worldBinormal 	: TEXCOORD4; 
        float3 worldNormal   	: TEXCOORD5; 
        float3 viewDir	    	: TEXCOORD6; 
	float2 texCoord			: TEXCOORD7; 

}; 

//Ambient and Self-Illum Pass Vertex Shader
v2f av(a2v In, uniform float3 lightPos, uniform int lightType, uniform float3 lightDir) 
{ 
    v2f Out = (v2f)0; 
	Out.position = mul(In.position, wvp);				//transform vert position to homogeneous clip space 

	In.texCoord.y += 1.0f;		//this fixes Max's V texcoord which is off by one 
	Out.texCoord = In.texCoord;						//pass through texture coordinates from channel 1 

	return Out; 
} 

//Ambient and Self-Illum Pass Pixel Shader
float4 af(v2f In, uniform float3 lightDir, uniform float4 lightColor, uniform float4 lightAttenuation, uniform float lightHotspot, uniform float lightFalloff, uniform int lightType, uniform int lightattenType, uniform int lightconeType, uniform bool lightCastShadows, uniform int shadowPassCount) : COLOR 
{ 

	float3 MathOperator_6728 = color_ambient.rgb * 0.0;
	float3 input1 = MathOperator_6728; 


	float4 TextureMap_8047 = tex2D(TextureMap_8047Sampler, In.texCoord.xy);
	float3 MathOperator_3351 = TextureMap_8047.rgb * 0.0;
	float3 input6 = MathOperator_3351; 

	float4 ret =  float4(0,0,0,1); 
	ret =  float4(input1, 1) + float4(input6, 1); 
	return ret; 
} 

//Diffuse and Specular Pass Vertex Shader
v2f v(a2v In, uniform float3 lightPos, uniform int lightType, uniform float3 lightDir) 
{ 
    v2f Out = (v2f)0; 
	float3x3 objTangentXf;								//build object to tangent space transform matrix 
	#ifdef YUP 
	objTangentXf[0] = In.tangent.xyz; 
	objTangentXf[1] = -In.binormal.xyz; 
	#else 
	objTangentXf[0] = In.binormal.xyz; 
	objTangentXf[1] = -In.tangent.xyz; 
	#endif 
	objTangentXf[2] = In.normal.xyz; 
	float3 worldSpacePos = mul(In.position, world).xyz;	//world space position 
	Out.lightVec = lightVec_func(worldSpacePos, lightPos, objTangentXf, lightType); 
	float4 osIPos = mul(viewInv[3], worldI);			//put world space eye position in object space 
	float3 osIVec = osIPos.xyz - In.position.xyz;		//object space eye vector 
	Out.eyeVec = mul(objTangentXf, osIVec);				//tangent space eye vector passed out 
	Out.lightDir = mul(objTangentXf, mul(lightDir, worldI).xyz ); 
	Out.position = mul(In.position, wvp);				//transform vert position to homogeneous clip space 

	//this code was added by the World Space Transform Node 
	Out.worldNormal = mul(In.normal, worldIT).xyz;		//compute world space normal 
	Out.worldBinormal = mul(In.binormal, worldIT).xyz;	//compute world space binormal 
	Out.worldTangent = mul(In.tangent, worldIT).xyz;		//compute world space tangent 
	Out.viewDir = mul(In.position, world) - viewInv[3]; 
	In.texCoord.y += 1.0f;		//this fixes Max's V texcoord which is off by one 
	Out.texCoord = In.texCoord;						//pass through texture coordinates from channel 1 

	return Out; 
} 

//Diffuse and Specular Pass Pixel Shader
float4 f(v2f In, uniform float3 lightDir, uniform float4 lightColor, uniform float4 lightAttenuation, uniform float lightHotspot, uniform float lightFalloff, uniform int lightType, uniform int lightattenType, uniform int lightconeType, uniform bool lightCastShadows, uniform int shadowPassCount) : COLOR 
{ 
	float3 ret = float3(0,0,0); 
	float3 V = normalize(In.eyeVec);		//creating the eye vector  
	float3 L = normalize(In.lightVec);		//creating the light vector  

	float UIConst_5972 = 1.0; 
	float3 Normal = float3(0,0,1);	//tangent space normal vector 
	//this code was added by the World Space Transform Node 
	float3 Nn = normalize(In.worldNormal); 		//input the vectors required for tangent to world space transform 
	float3 Tn = normalize(In.worldTangent); 
	float3 Bn = normalize(In.worldBinormal); 
	#ifdef YUP 
		float3 MathWorldXform_6350 = ( Nn * Normal.z ) + (Normal.x * Tn ) + ( Normal.y * -Bn); 
	#else 
		float3 MathWorldXform_6350 = ( Nn * Normal.z ) + (Normal.x * Bn ) + ( Normal.y * -Tn); 
	#endif 
	float3 MathReflect_9471 = reflect(In.viewDir, MathWorldXform_6350);		//Compute the reflection vector 
	float3 UICubeMap_7142InputVector = MathReflect_9471.xyz;
	#ifdef YUP 
	#else 
	UICubeMap_7142InputVector.xyz = UICubeMap_7142InputVector.xzy;  //swizzle required for Max 
	#endif 
	float4 UICubeMap_7142 = texCUBE(UICubeMap_7142Sampler, UICubeMap_7142InputVector);
	float4 TextureMap_7634 = tex2D(TextureMap_7634Sampler, In.texCoord.xy);
	float4 TextureMap_5485 = tex2D(TextureMap_5485Sampler, In.texCoord.xy);
	float3 MathOperator_1177 = TextureMap_7634.rgb * TextureMap_5485.g;
	float3 MathOperator_7579 = MathOperator_1177 * color_diffuse.rgb;
	float NdotV_fresnel = saturate(dot(V,Normal)); 		//clamped dot product 
	float Pow_NdotV = pow(NdotV_fresnel,FresnelPower);		//x to the power of y 
	float timesFresnelScale = Pow_NdotV * FresnelScale;
	float plusFresnelBias = timesFresnelScale + FresnelBias;
	float3 MathLerp_8806 = lerp(UICubeMap_7142.rgb, MathOperator_7579, plusFresnelBias); 
	float3 MathIf_1459;
	if (UIBool_6933 == UIConst_5972) MathIf_1459 = MathLerp_8806; else MathIf_1459 = MathOperator_7579; 
	float3 input2 = MathIf_1459; 


	float3 input3 = color_spec.rgb; 


	float4 TextureMap_4534 = tex2D(TextureMap_4534Sampler, In.texCoord.xy);
	float input4 = TextureMap_4534.g; 


	float input5 = spec; 


	float4 NormalMap_5786 = tex2D(NormalMap_5786Sampler, In.texCoord.xy);
	NormalMap_5786.xyz = NormalMap_5786.xyz * 2 - 1;		//expand to -1 to 1 range 
	NormalMap_5786.rgb = normalize(NormalMap_5786.rgb); 		//normalized the normal vector 
	float3 input8 = NormalMap_5786.rgb; 

	float3 N = input8;						//using the Normal socket  
	float3 diffuseColor = input2;			//using the Diffuse Color socket  
	float NdotL = dot(N, L);				//calculate the diffuse  
	float diffuse = saturate(NdotL);		//clamp to zero  
	diffuseColor *= diffuse;				//the resulting diffuse color  
	float3 specularColor = input3;			//using the Specular Color socket 
	specularColor *= input4;				//Multiplying Specular Color by the Specular Level  
	float glossiness = input5;				//using the Glossiness socket  
	float3 H = normalize(L + V);			//Compute the half angle  
	float NdotH = saturate(dot(N,H));		//Compute NdotH  
	specularColor *= pow(NdotH, glossiness);//Raise to glossiness power and compute final specular color  
	ret += specularColor + diffuseColor;	//add specular and diffuse color together
	ret *= lightColor;						//multiply by the color of the light 
	lightDir = normalize(In.lightDir);	//bring in the tangent space light direction - for our spot light  
	float attenuation = attenuation_func(lightattenType, lightAttenuation, In.lightVec); 					//calculate the light attenuation  
	float coneangle = coneangle_func(lightconeType, lightHotspot, lightFalloff, In.lightVec, lightDir); 	//calculate the light's cone angle 
	ret *= attenuation * coneangle;			//multiply by the light decay  
	float4 done = float4(ret, 1);			//create the final ouput value 
	return done; 
} 

technique Complete  
{  
	pass ambient  
    {		 
		VertexShader = compile vs_3_0 av(light1Pos,  light1Type, light1Dir); 
		ZEnable = true; 
		ZWriteEnable = true; 
		CullMode = cw; 
		ShadeMode = Gouraud;
		AlphaBlendEnable = false; 
		AlphaTestEnable = FALSE; 
	PixelShader = compile ps_3_0 af(light1Dir, light1Color, light1Attenuation, light1Hotspot, light1Falloff, light1Type, light1attenType, light1coneType, light1CastShadows, 1); 
	}  

	pass light1  
    {		 
		VertexShader = compile vs_3_0 v(light1Pos,  light1Type, light1Dir); 
		ZEnable = true; 
		CullMode = cw; 
		ShadeMode = Gouraud;
		ZWriteEnable = true; 
		ZFunc = LessEqual; 
		AlphaBlendEnable = true; 
		SrcBlend = One; 
		DestBlend = One; 
		AlphaTestEnable = FALSE; 
		PixelShader = compile ps_3_0 f(light1Dir, light1Color, light1Attenuation, light1Hotspot, light1Falloff, light1Type, light1attenType, light1coneType, light1CastShadows, 1); 
	}  
	pass light2  
	{		 
		VertexShader = compile vs_3_0 v(light2Pos,  light2Type, light2Dir); 
		ZEnable = true; 
		ZWriteEnable = false; 
		ZFunc = LessEqual; 
		CullMode = cw; 
		ShadeMode = Gouraud;
		AlphaBlendEnable = true; 
		AlphaTestEnable = FALSE; 
		SrcBlend = One; 
		DestBlend = One; 
		PixelShader = compile ps_3_0 f(light2Dir, light2Color, light2Attenuation, light2Hotspot, light2Falloff, light2Type, light2attenType, light2coneType, light2CastShadows, 2); 
	}  
	pass light3  
	{		 
		VertexShader = compile vs_3_0 v(light3Pos,  light3Type, light3Dir); 
		ZEnable = true; 
		ZWriteEnable = false; 
		ZFunc = LessEqual; 
		CullMode = cw; 
		ShadeMode = Gouraud;
		AlphaBlendEnable = true; 
		AlphaTestEnable = FALSE; 
		SrcBlend = One; 
		DestBlend = One; 
		PixelShader = compile ps_3_0 f(light3Dir, light3Color, light3Attenuation, light3Hotspot, light3Falloff, light3Type, light3attenType, light3coneType, light3CastShadows, 3); 
	}  
}    