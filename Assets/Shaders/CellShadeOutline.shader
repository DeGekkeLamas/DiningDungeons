
Shader "Custom/CellShadeOutline"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_Reflectiveness("Reflectiveness", Float) = 16
		_CellShadeLoops("Cell shade loops", Integer) = 3
		_Emissiveness("Emissiveness", Float) = 0
		_NormalMap("Normal Map", 2D) = "bump" {}
	}
	SubShader
	{
		LOD 100

		Pass
		{
			Name "CellShadeOutline"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "Assets\Shaders\Lighting.hlsl"

			struct input
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct output
			{
				float4 vertex : SV_POSITION;
				float4 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 worldPos : TEXCOORD1;

				float3 worldNormal : TEXCOORD2;
				float3 worldTangent : TEXCOORD3;
				float3 worldBitangent : TEXCOORD4;
			};

			float4 _MainTex_ST;
			sampler2D _MainTex;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;

			float4 _Color;
			float _Reflectiveness;
			int _CellShadeLoops;
			float _Emissiveness;

			output vert(input v)
			{
				output o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				float4 noTranslate = v.normal;
				noTranslate.w = 0;
				float4 mat = mul(UNITY_MATRIX_M, noTranslate);
				o.normal = normalize(mat);
				o.worldPos = mul(UNITY_MATRIX_M, v.vertex);

				// normal
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);

				o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;

				return o;
			}

			fixed4 frag(output i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv) * _Color;
				// Normal map
				float3 tangentNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
				float3x3 TBN = float3x3(
					normalize(i.worldTangent),
					normalize(i.worldBitangent),
					normalize(i.worldNormal));
				float4 worldNormal = float4(normalize(mul(TBN, tangentNormal)),0);

				col = GetLightingCellshade(col, worldNormal, i.worldPos, _Reflectiveness, _CellShadeLoops);
				col *= 1 + _Emissiveness;

				return col;
			}
			ENDCG
		}
		// cast shadows:
		Pass
		{
			Tags{ "LightMode" = "ShadowCaster" }
			CGPROGRAM
			#pragma vertex VSMain
			#pragma fragment PSMain

			float4 VSMain(float4 vertex:POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertex);
			}

			float4 PSMain(float4 vertex:SV_POSITION) : SV_TARGET
			{
				return 0;
			}

			ENDCG
		}
	}
}
