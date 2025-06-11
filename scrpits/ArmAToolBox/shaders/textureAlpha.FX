
/*** Generated through Lumonix shaderFX  by: Alex & Ramune in 3dsmax at: 21-10-2009 5:44:33 PM  ***/ 

// This FX shader was built to support 3ds Max's standard shader compiler. 


texture diffuse2
<
	string Name = "gvard.tga";
	string UIName = "Texture";
	string ResourceType = "2D";
>;
 
sampler2D diffuse2Sampler = sampler_state
{
	Texture = <diffuse2>;
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

#define light1Type 1
#define light1attenType 0
#define light1coneType 0
#define light1CastShadows false

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

	float2 texCoord			: TEXCOORD1; 

}; 

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
	Out.position = mul(In.position, wvp);				//transform vert position to homogeneous clip space 

	In.texCoord.y += 1.0f;		//this fixes Max's V texcoord which is off by one 
	Out.texCoord = In.texCoord;						//pass through texture coordinates from channel 1 

	return Out; 
} 

//Diffuse and Specular Pass Pixel Shader
float4 f(v2f In, uniform float3 lightDir, uniform float4 lightColor, uniform float4 lightAttenuation, uniform float lightHotspot, uniform float lightFalloff, uniform int lightType, uniform int lightattenType, uniform int lightconeType, uniform bool lightCastShadows, uniform int shadowPassCount) : COLOR 
{ 
	float3 ret = float3(0,0,0); 
	float3 L = normalize(In.lightVec);		//creating the light vector  

	float4 diffuse2 = tex2D(diffuse2Sampler, In.texCoord.xy);
	float3 input2 = diffuse2.rgb; 
	float input7 = diffuse2.a; 

	float3 N = float3(0.0, 0.0, 1.0);		//the Normal socket was empty - using default value 
	float3 diffuseColor = input2;			//using the Diffuse Color socket  
	float NdotL = dot(N, L);				//calculate the diffuse  
	float diffuse = saturate(NdotL);		//clamp to zero  
	diffuseColor *= diffuse;				//the resulting diffuse color  
	float3 specularColor = float3(0, 0, 0);	//Specular Color socket is empty so using black
	ret += specularColor + diffuseColor;	//add specular and diffuse color together
	ret *= lightColor;						//multiply by the color of the light 
	float attenuation = attenuation_func(lightattenType, lightAttenuation, In.lightVec); 					//calculate the light attenuation  
	float coneangle = coneangle_func(lightconeType, lightHotspot, lightFalloff, In.lightVec, lightDir); 	//calculate the light's cone angle 
	ret *= attenuation * coneangle;			//multiply by the light decay  
	float Opacity = input7;					//bring in the value from the opacity socket 
	float4 done = float4(ret, Opacity);		//create the final ouput value  
	return done; 
} 

technique Complete  
{  
	pass light1  
    {		 
		VertexShader = compile vs_2_0 v(light1Pos,  light1Type, light1Dir); 
		ZEnable = true; 
		CullMode = cw; 
		ShadeMode = Gouraud;
		AlphaBlendEnable = true; 
		ZWriteEnable = true; 
		SrcBlend = SrcAlpha; 
		DestBlend = InvSrcAlpha; 
		AlphaTestEnable = FALSE; 
		PixelShader = compile ps_2_0 f(light1Dir, light1Color, light1Attenuation, light1Hotspot, light1Falloff, light1Type, light1attenType, light1coneType, light1CastShadows, 1); 
	}  
}    