Shader "xoio/Deferred NPR/Profiled/Standard"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_DetailTex ("Detail Texture", 2D) = "white" {}
		_DetailExp("Detail Exponent", range(0,1)) = 1

		_FresCutoff("Fresnel Cutoff", range(0,1)) = 0.5
		_FresFalloff("Fresnel Falloff", Range(0,1)) = 0.1
		_FresPower("Fresnel Power", range(0,1)) = 0.3
	}
	SubShader
	{
		Name "DEFERRED"
		Tags { 
			"RenderType"="Opaque" 
			"LightMode" = "Deferred"
		}
		LOD 200


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 color : COLOR;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 color : COLOR;
				float3 normal : NORMAL;
				//float fres : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			float _FresCutoff; float _FresFalloff; float _FresPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv1 = v.uv1;
				o.color = pow(v.color, 2.2 );
				o.normal = UnityObjectToWorldNormal(v.normal);

/*
				float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 I = normalize(posWorld - _WorldSpaceCameraPos.xyz);
				
				if(_FresFalloff == 0)
					o.fres = 0;
				else
					o.fres = -1 * dot(I, o.normal);
*/
				o.normal = o.normal * 0.5 + 0.5;

				return o;
			}

			sampler2D _DetailTex; float _DetailExp;
			sampler2D _MainTex;
			

			void frag (v2f i, 
			    out half4 outGBuffer0 : SV_Target0,
				out half4 outGBuffer1 : SV_Target1,
				out half4 outGBuffer2 : SV_Target2,
				out half4 outGBuffer3 : SV_Target3
			)
			{

				//i.fres = smoothstep(_FresCutoff + _FresFalloff, _FresCutoff , i.fres); // * _FresPower;
				outGBuffer0 = half4(tex2D(_MainTex, i.uv).rgb * i.color.rgb, 1);
				outGBuffer1 = half4(
								lerp(0, tex2D(_DetailTex, i.uv1 * 2).r, _DetailExp), 
								0,0,0);
				outGBuffer2 = half4(i.normal, 0);
				outGBuffer3 = half4(0,0,0, 1);
			}
			ENDCG
		}

		
	}
	FallBack "Diffuse"
}
