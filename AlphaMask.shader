Shader "Unlit/AlphaMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_AlphaTex("AlphaTexture", 2D) = "white"{}
		_CutOff("CutOff", Range(0.0,1.0)) = 0.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True"}
        LOD 100

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float4 color: COLOR0;
                float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
            };

            struct v2f
            {
				float4 color : COLOR0;
                float2 uv : TEXCOORD0;
				float2 uv1: TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _AlphaTex;
			float4 _AlphaTex_ST;
			float _CutOff;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv1 = TRANSFORM_TEX(v.uv1, _AlphaTex);
				o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				col *= i.color;
				fixed4 acol = tex2D(_AlphaTex, i.uv1);
				float a = saturate(acol.a + (_CutOff * 2 - 1));

                return float4(col.r,col.g,col.b, a);
            }
            ENDCG
        }
    }
}
