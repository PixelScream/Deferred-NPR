Shader "Hidden/NPR_Base_Composite"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _CameraGBufferTexture0;
			sampler2D _CameraGBufferTexture1;
			sampler2D _CameraGBufferTexture2;
			sampler2D _CameraGBufferTexture3;

			fixed4 _ColorLight; fixed4 _ColorDark;
			sampler2D _NPRLUT; sampler2D _NPRLUTSpec;

			fixed4 frag (v2f_img i) : SV_Target
			{ 
				fixed4 col = tex2D(_CameraGBufferTexture0, i.uv);


				half4 lightingTex =  tex2D(_MainTex, i.uv);
				//return lightingTex.g;

				half lightingMask = tex2D(_NPRLUT, float2( lightingTex.r, 0) ).a;

				fixed4 lighting = lerp(_ColorDark, _ColorLight, lightingMask);

				fixed4 spec = tex2D(_NPRLUTSpec, float2(lightingTex.g, 0) ).a * _ColorLight;
				col += spec * 0.25;
				//return spec;

				fixed4 result = col;
				result.rgb *= lighting.rgb;
				result.rgb += col * 0.2;
				return lerp(lightingTex, result, lightingTex.a);
				//return lighting;
				return col;
			}
			ENDCG
		}
	}
}
