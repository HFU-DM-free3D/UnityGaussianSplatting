Shader "Unlit/RenderPointsSimple"
{
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {
            ZWrite Off
            Blend OneMinusDstAlpha One
            Cull Front
            
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma require compute

#include "UnityCG.cginc"

float3 QuatRotateVector(float3 v, float4 r)
{
    float3 t = 2 * cross(r.xyz, v);
    return v + r.w * t + cross(r.xyz, t);
}

float Sigmoid(float v)
{
	return rcp(1.0 + exp(-v));
}

struct InputSplat
{
    float3 pos;
    float3 nor;
    float3 dc0;
    float3 sh0, sh1, sh2, sh3, sh4, sh5, sh6, sh7, sh8, sh9, sh10, sh11, sh12, sh13, sh14;
    float opacity;
    float3 scale;
    float4 rot;
};
StructuredBuffer<InputSplat> _DataBuffer;
StructuredBuffer<uint> _OrderBuffer;

struct v2f
{
    half4 col : COLOR0;
    float4 vertex : SV_POSITION;
    float psize : PSIZE;
};

static const int kCubeIndices[36] =
{
    //@TODO: cube face flip opts from https://twitter.com/SebAaltonen/status/1315985267258519553?lang=en
    0, 1, 2, 1, 3, 2,
    4, 6, 5, 5, 6, 7,
    0, 2, 4, 4, 2, 6,
    1, 5, 3, 5, 7, 3,
    0, 4, 1, 4, 5, 1,
    2, 3, 6, 3, 7, 6
};

static const float SH_C0 = 0.28209479177387814f;
static const float SH_C1 = 0.4886025119029199f;
static const float SH_C2[] = {
	1.0925484305920792f,
	-1.0925484305920792f,
	0.31539156525252005f,
	-1.0925484305920792f,
	0.5462742152960396f
};
static const float SH_C3[] = {
	-0.5900435899266435f,
	2.890611442640554f,
	-0.4570457994644658f,
	0.3731763325901154f,
	-0.4570457994644658f,
	1.445305721320277f,
	-0.5900435899266435f
};

half3 ShadeSH(InputSplat splat, float3 dir)
{
    // ambient band
    half3 res = SH_C0 * splat.dc0;
    // 1st degree
    res = res - splat.sh0 * (dir.y * SH_C1) + splat.sh1 * (dir.z * SH_C1) - splat.sh2 * (dir.x * SH_C1);
    // 2nd degree
    res = res +
        (SH_C2[0] * dir.x * dir.y) * splat.sh4 +
		(SH_C2[1] * dir.y * dir.z) * splat.sh5 +
		(SH_C2[2] * (2.0f * dir.z * dir.z - dir.x * dir.x - dir.y * dir.y)) * splat.sh6 +
		(SH_C2[3] * dir.x * dir.z) * splat.sh7 +
		(SH_C2[4] * (dir.x * dir.x - dir.y * dir.y)) * splat.sh8;    
    //@TODO others
    return saturate(res + 0.5);
}

v2f vert (uint vtxID : SV_VertexID, uint instID : SV_InstanceID)
{
    v2f o;
    instID = _OrderBuffer[instID];
    InputSplat splat = _DataBuffer[instID];

    int boxIdx = kCubeIndices[vtxID];
    float3 boxPos = float3(boxIdx&1, (boxIdx>>1)&1, (boxIdx>>2)&1) * 2.0 - 1.0;
    float4 boxRot = normalize(splat.rot.yzwx); //@TODO: move normalize and swizzle offline
    float3 boxSize = exp(splat.scale) * 2.0; //@TODO: move exp offline

    boxPos = QuatRotateVector(boxPos * boxSize, boxRot);
    float3 worldPos = splat.pos + boxPos;

    float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
    
    o.vertex = UnityObjectToClipPos(worldPos);
    o.col.rgb = ShadeSH(splat, viewDir);
    o.col.a = Sigmoid(splat.opacity); //@TODO: move offline
    o.psize = 10;
    return o;
}

half4 frag (v2f i) : SV_Target
{
    return half4(i.col.rgb * i.col.a, i.col.a);
}
ENDCG
        }
    }
}