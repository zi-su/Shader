Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_MaskRect("MaskRect",Vector) = (0.0,0.0,0.0,0.0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				float4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			Vector _MaskRect;
			bool _Flag;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				col *= i.color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
				//四角形マスク
				/*if ((i.vertex.x > (_MaskRect.x - _MaskRect.z) && i.vertex.x < (_MaskRect.x + _MaskRect.z))
					&&(i.vertex.y > (_MaskRect.y - _MaskRect.w) && i.vertex.y < (_MaskRect.y + _MaskRect.w))) {
					col.rgb = 1.0;
					col.a = 0.0;
				}*/

				//楕円マスク
				float x = pow(i.vertex.x - _MaskRect.x, 2) / pow(_MaskRect.z, 2);
				float y = pow(i.vertex.y - _MaskRect.y, 2) / pow(_MaskRect.w, 2);
				if (x + y < 1) {
					col.a = 0.0;
				}
				
                return col;
            }
            ENDCG
        }
    }
}
