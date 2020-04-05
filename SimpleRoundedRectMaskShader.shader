Shader "Unlit/SimpleRoundedRectMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_MaskRect("MaskRect",Vector) = (0.0,0.0,0.0,0.0)
		_Radius("Radius", Float) = 10.0
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
			float _Radius;
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

				//角丸四角形マスク
				float r = _Radius;
				//四角形領域
				bool a = ((i.vertex.x > (_MaskRect.x - _MaskRect.z + r)) && (i.vertex.x < (_MaskRect.x + _MaskRect.z - r))
					&& (i.vertex.y > (_MaskRect.y - _MaskRect.w)) && (i.vertex.y < (_MaskRect.y + _MaskRect.w)));
				bool b = ((i.vertex.x > (_MaskRect.x - _MaskRect.z)) && (i.vertex.x < (_MaskRect.x + _MaskRect.z))
					&& (i.vertex.y > (_MaskRect.y - _MaskRect.w + r)) && (i.vertex.y < (_MaskRect.y + _MaskRect.w - r)));

				//四隅円領域
				bool c = pow(i.vertex.x - (_MaskRect.x - _MaskRect.z + r), 2) + pow(i.vertex.y - (_MaskRect.y - _MaskRect.w + r),2) < pow(r,2);
				bool d = pow(i.vertex.x - (_MaskRect.x + _MaskRect.z - r), 2) + pow(i.vertex.y - (_MaskRect.y - _MaskRect.w + r), 2) < pow(r, 2);
				bool e = pow(i.vertex.x - (_MaskRect.x + _MaskRect.z - r), 2) + pow(i.vertex.y - (_MaskRect.y + _MaskRect.w - r), 2) < pow(r, 2);
				bool f = pow(i.vertex.x - (_MaskRect.x - _MaskRect.z + r), 2) + pow(i.vertex.y - (_MaskRect.y + _MaskRect.w - r), 2) < pow(r, 2);

				
				if (a || b || c || d || e || f) {
					col.a = 0.0;
				}

                return col;
            }
            ENDCG
        }
    }
}
