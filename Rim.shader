Shader "Unlit/Rim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_RimColor("RimColor", Color)=(1,1,1,1)
		_RimPower("RimPower", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
		{
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 view :TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _RimColor;
			float _RimPower;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.view = WorldSpaceViewDir(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				//col *= _LightColor0 * dot(lightDir, i.normal);
				
				float3 viewDir = normalize(i.view);
				float NdotL = 1.0 - saturate(dot(viewDir, i.normal));
				NdotL = pow(NdotL, _RimPower);
				col += _RimColor * NdotL;
				
                return col;
            }
            ENDCG
        }
    }
}
