Shader "xoio/Deferred NPR/Gun"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_DetailTex ("Detail Texture", 2D) = "white" {}
		_DetailScale("Detail Scale", float) = 1
		_DetailExp("Detail Exponent", range(0,1)) = 1

		_Gloss("Gloss", range(0,1)) = 0
		_Spec("Spec", range(0,1)) = 0
		
		_NormalTex ("Normal", 2D) = "bump" {}
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
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 color : COLOR;
				float3 normal : NORMAL;

				float4 tSpace0 : TEXCOORD4;
                float4 tSpace1 : TEXCOORD2;
                float4 tSpace2 : TEXCOORD3;

				//float fres : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			float _FresCutoff; float _FresFalloff; float _FresPower;
			float _DetailExp; float _DetailScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv1 = v.uv1 * _DetailScale;
				o.color = pow(v.color, 2.2);
				o.normal = UnityObjectToWorldNormal(v.normal);

                // copied all below out of a compiled standard surface shader
                // had tried just transforming to world space on my own
                // but I figured the unity devs probably know better
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
                o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				

				return o;
			}
			sampler2D _MainTex;
			sampler2D _DetailTex; 
			sampler2D _NormalTex;


			float _Spec; float _Gloss;
			

			void frag (v2f i, 
			    out half4 outGBuffer0 : SV_Target0,
				out half4 outGBuffer1 : SV_Target1,
				out half4 outGBuffer2 : SV_Target2,
				out half4 outGBuffer3 : SV_Target3
			)
			{

				fixed detail = tex2D (_DetailTex, i.uv1).r ;

				outGBuffer0 = half4(i.color.rgb * tex2D(_MainTex, i.uv).rgb, 1);

				//outGBuffer0 = mul(unity_ObjectToWorld, float4(0,0,0,1) ) ;
				outGBuffer1 = half4(
								_Spec,
								lerp(0, detail, _DetailExp), 
								0, 
								_Gloss
				);

				half3 norm = UnpackNormal(tex2D(_NormalTex, i.uv));
 
                // again from surface shader output
                // but converts from tanget space to world
                fixed3 worldN;
                worldN.x = dot(i.tSpace0.xyz, norm);
                worldN.y = dot(i.tSpace1.xyz, norm);
                worldN.z = dot(i.tSpace2.xyz, norm);
                worldN = worldN * 0.5f + 0.5f;

				outGBuffer2 = half4(worldN, 0);
				outGBuffer3 = half4(0,0,0, 1);
			}
			ENDCG
		}

		
	}
	FallBack "Diffuse"
}
