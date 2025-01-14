﻿Shader "ProceduralFX/SpeciesCompetition"
{
	Properties
	{
		[HideInInspector]
		_MainTex ("Texture", 2D) = "white" {}
		_BreedRates ("Breeding", Vector) = (0,0,0,0)
		_MaxPop ("Maximum Population", Vector) = (0,0,0,0)
		_Diffusion ("Diffusion Map", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#define FRAGMENT_P highp
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _Diffusion;
			float4 _BreedRates;
			float4 _MaxPop;
			float4x4 _CompetitionMatrix;
			half4 _MainTex_TexelSize;

			float4 frag (v2f i) : SV_Target
			{
				float4 val = tex2D(_MainTex, i.uv);
				float2 e = float2(1,0) * _MainTex_TexelSize.xy,
					n = float2(0,1) * _MainTex_TexelSize.xy,
					w = float2(-1,0) * _MainTex_TexelSize.xy,
					s = float2(0,-1) * _MainTex_TexelSize.xy;
				float4 r = _BreedRates;
				float4 k = _MaxPop;
				
				float diffusionRate = 0.1f * tex2D(_Diffusion,i.uv).r * 0.5f;
				if(diffusionRate == 0 ){
					return float4(0,0,0,0);
				}
				float4 diffusion = tex2D(_MainTex,i.uv+n)+tex2D(_MainTex,i.uv+e)+tex2D(_MainTex,i.uv+s)+tex2D(_MainTex,i.uv+w)-4.0*val;
				float4 pop = saturate( val + diffusionRate*diffusion );
				float4 competition = mul( pop, _CompetitionMatrix );
				float4 output = float4(
					pop.x + ( pop.x * r.x * ( 1 - competition.x / k.x ) ),
					pop.y + ( pop.y * r.y * ( 1 - competition.y / k.y ) ),
					pop.z + ( pop.z * r.z * ( 1 - competition.z / k.z ) ),
					1	
				);
				
				return output;

			}
			ENDCG
		}
	}
}
