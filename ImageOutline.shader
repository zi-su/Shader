Shader "Unlit/ImageOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Outline("Outline", Float) = 5.0
		_OutlineColor("OutlineColor", Color) = (1.0,1.0,1.0,1.0)
		_OutlineOffsetX("OutlineOffsetX", Float) = 0.0
		_OutlineOffsetY("OutlineOffsetY", Float) = 0.0
		_OutlineBlinkTime("OutlineBlinkTime", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
				float4 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Outline;
			float4 _OutlineColor;
			float _OutlineOffsetX;
			float _OutlineOffsetY;
			float _OutlineBlinkTime;
			v2f vert(appdata v)
			{
				v2f o;
				
				float2 uv2 = v.uv * 2.0 - 1.0;

				v.vertex += float4(uv2.x * _Outline, uv2.y * _Outline, 0.0, 0.0);
				v.vertex += float4(_OutlineOffsetX, _OutlineOffsetY,0.0,0.0);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				float a = col.a;
				col = _OutlineColor;
				col.a = a;
				//col.b = (_SinTime.w + 1.0) * 0.5;
				col.a *= (sin(_OutlineBlinkTime * _Time.w) + 1.0) * 0.5;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
		

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
                float2 uv : TEXCOORD0;
				float4 color : COLOR0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float4 color : COLOR0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				col *= i.color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
