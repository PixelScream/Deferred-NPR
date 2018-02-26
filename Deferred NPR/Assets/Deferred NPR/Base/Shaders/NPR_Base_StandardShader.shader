Shader "xoio/Deferred NPR/Base/Standard"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
	}
	SubShader
	{
		Name "DEFERRED"  // name and 'LightMode' identify this as deferred shader to Unity
		Tags { 
			"RenderType"="Opaque" 
			"LightMode" = "Deferred"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;	// including 1 texture and
				float4 color : COLOR; 	// vertex colors 
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.color = pow(v.color, 2.2); // Gamma correcting because of Blender, ideally wouldn't do this
				o.normal = UnityObjectToWorldNormal(v.normal) * 0.5 + 0.5;

				return o;
			}

			sampler2D _MainTex;
			void frag (v2f i, 
			    out half4 outGBuffer0 : SV_Target0, // SV_TargetN is a reference to the respective GBuffer targets
				out half4 outGBuffer1 : SV_Target1, // i.e. Target1 being for what would normal be Spec/Gloss
				out half4 outGBuffer2 : SV_Target2, // Normals
				out half4 outGBuffer3 : SV_Target3  // where lighting is stored/self illumination, for us we just want black
			)
			{
				outGBuffer0 = half4(tex2D(_MainTex, i.uv).rgb * i.color.rgb, 1);
				outGBuffer1 = half4( 0,0,0,0); 
				outGBuffer2 = half4(i.normal, 0); // have to store the object's normals for lighting later on
				outGBuffer3 = half4(0,0,0, 1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
