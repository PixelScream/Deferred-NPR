Shader "xoio/Deferred NPR/Triplannar"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_DetailTex ("Detail Texture", 2D) = "white" {}
		_DetailScale("Detail Scale", float) = 1
		_DetailExp("Detail Exponent", range(0,1)) = 1

		_Gloss("Gloss", range(0,1)) = 0
		_Spec("Spec", range(0,1)) =0
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
				float3 posWorld : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			float _FresCutoff; float _FresFalloff; float _FresPower;
			float _DetailExp; float _DetailScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv1 = v.uv1;
				o.color = pow(v.color, 2.2);
				o.normal = UnityObjectToWorldNormal(v.normal);

				o.posWorld = (mul(unity_ObjectToWorld, v.vertex).xyz  -  mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz ) * _DetailScale;

/*
				float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 I = normalize(posWorld - _WorldSpaceCameraPos.xyz);
				
				if(_FresFalloff == 0)
					o.fres = 0;
				else
					o.fres = -1 * dot(I, o.normal);
*/
				

				return o;
			}
			sampler2D _MainTex;
			sampler2D _DetailTex; 

			float _Spec; float _Gloss;
			

			void frag (v2f i, 
			    out half4 outGBuffer0 : SV_Target0,
				out half4 outGBuffer1 : SV_Target1,
				out half4 outGBuffer2 : SV_Target2,
				out half4 outGBuffer3 : SV_Target3
			)
			{
				float3 clampedNormals =  saturate(pow(i.normal * 1.5, 10) );
				fixed detail = tex2D (_DetailTex, i.posWorld.xy).r ;
				detail = lerp(detail, tex2D (_DetailTex, i.posWorld.zy).r, clampedNormals.x ) ;
				//detail = lerp(detail, tex2D (_DetailTex, i.posWorld.xz).r, saturate(clampedNormals.y * 2 - (detail) ) ) ;
				detail = lerp(detail, tex2D (_DetailTex, i.posWorld.xz).r, clampedNormals.y  );

				//outGBuffer0 = half4(clampedNormals, 1);

				//i.fres = smoothstep(_FresCutoff + _FresFalloff, _FresCutoff , i.fres); // * _FresPower;
				outGBuffer0 = half4(i.color.rgb * tex2D(_MainTex, i.uv).rgb, 1);

				//outGBuffer0 = mul(unity_ObjectToWorld, float4(0,0,0,1) ) ;
				outGBuffer1 = half4(
								_Spec,
								lerp(0, detail, _DetailExp), 
								0, 
								_Gloss
				);

				outGBuffer2 = half4(i.normal * 0.5 + 0.5, 0);
				outGBuffer3 = half4(0,0,0, 1);
			}
			ENDCG
		}

		
	}
	FallBack "Diffuse"
}
