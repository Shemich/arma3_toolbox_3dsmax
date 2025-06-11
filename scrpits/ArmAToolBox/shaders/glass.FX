
/*** Generated through Lumonix shaderFX  by: Alex & Ramune in 3dsmax at: 21-10-2009 6:36:55 PM  ***/ 

// This FX shader was built to support 3ds Max's standard shader compiler. 


texture cubeMap : environment
<
	string Name = "OutputCube.dds";
	string UIName = "Preview Reflection Map";
	string type = "Cube";
>;
 
samplerCUBE cubeMapSampler = sampler_state
{
	Texture = <cubeMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
};
 
float3 diffuseColor
<
	string UIName = "Diffuse";
	string UIType = "ColorSwatch";
> = {0.0f, 0.0f, 0.0f};
 
float FresnelPower
<
	string UIType = "FloatSpinner";
	float UIMin = 0.0;
	float UIMax = 100.0;
	float UIStep = 0.01;
	string UIName = "Fresnel Power";
> = 1.71;
 
float FresnelScale
<
	string UIType = "FloatSpinner";
	float UIMin = 0.0;
	float UIMax = 100.0;
	float UIStep = 0.01;
	string UIName = "Fresnel Scale";
> = 1.34;
 
float FresnelBias
<
	string UIType = "FloatSpinner";
	float UIMin = -100.0;
	float UIMax = 100.0;
	float UIStep = 0.01;
	string UIName = "Fresnel Bias";
> = 0.13;
 
float opacity
<
	string UIType = "FloatSpinner";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.1;
	string UIName = "Opacity";
> = 0.12;
 

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


}; 

// output to fragment program 
struct v2f { 
        float4 position    		: POSITION; 
        float3 lightVec    		: TEXCOORD0; 

        float3 worldTangent  	: TEXCOORD1; 
        float3 worldBinormal 	: TEXCOORD2; 
        float3 worldNormal   	: TEXCOORD3; 
        float3 viewDir	    	: TEXCOORD4; 
        float3 eyeVec	    	: TEXCOORD5; 

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

	//this code was added by the World Space Transform Node 
	Out.worldNormal = mul(In.normal, worldIT).xyz;		//compute world space normal 
	Out.worldBinormal = mul(In.binormal, worldIT).xyz;	//compute world space binormal 
	Out.worldTangent = mul(In.tangent, worldIT).xyz;		//compute world space tangent 
	Out.viewDir = mul(In.position, world) - viewInv[3]; 
	//these three lines were added by the Eye Vector Node 
	float4 osIPos = mul(viewInv[3], worldI);			//put world space eye position in object space 
	float3 osIVec = osIPos.xyz - In.position.xyz;		//object space eye vector 
	Out.eyeVec = mul(objTangentXf, osIVec);				//tangent space eye vector passed out 

	return Out; 
} 

//Diffuse and Specular Pass Pixel Shader
float4 f(v2f In, uniform float3 lightDir, uniform float4 lightColor, uniform float4 lightAttenuation, uniform float lightHotspot, uniform float lightFalloff, uniform int lightType, uniform int lightattenType, uniform int lightconeType, uniform bool lightCastShadows, uniform int shadowPassCount) : COLOR 
{ 
	float3 ret = float3(0,0,0); 
	float3 L = normalize(In.lightVec);		//creating the light vector  

	float3 Normal = float3(0,0,1);	//tangent space normal vector 
	//this code was added by the World Space Transform Node 
	float3 Nn = normalize(In.worldNormal); 		//input the vectors required for tangent to world space transform 
	float3 Tn = normalize(In.worldTangent); 
	float3 Bn = normalize(In.worldBinormal); 
	#ifdef YUP 
		float3 MathWorldXform_2206 = ( Nn * Normal.z ) + (Normal.x * Tn ) + ( Normal.y * -Bn); 
	#else 
		float3 MathWorldXform_2206 = ( Nn * Normal.z ) + (Normal.x * Bn ) + ( Normal.y * -Tn); 
	#endif 
	float3 MathReflect_4298 = reflect(In.viewDir, MathWorldXform_2206);		//Compute the reflection vector 
	float3 cubeMapInputVector = MathReflect_4298.xyz;
	#ifdef YUP 
	#else 
	cubeMapInputVector.xyz = cubeMapInputVector.xzy;  //swizzle required for Max 
	#endif 
	float4 cubeMap = texCUBE(cubeMapSampler, cubeMapInputVector);
	float3 V = normalize(In.eyeVec.xyz);		//normalized eye vector 
	float NdotV_fresnel = saturate(dot(V,Normal)); 		//clamped dot product 
	float Pow_NdotV = pow(NdotV_fresnel,FresnelPower);		//x to the power of y 
	float timesFresnelScale = Pow_NdotV * FresnelScale;
	float plusFresnelBias = timesFresnelScale + FresnelBias;
	float3 MathLerp_2481 = lerp(cubeMap.rgb, diffuseColor.rgb, plusFresnelBias); 
	float3 input2 = MathLerp_2481; 
	float input7 = opacity; 

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