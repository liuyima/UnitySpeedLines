Shader "liuyima/SpeedLines"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FBM ("FBM Texture", 2D) = "white" {}
        _Color ("_Color",COLOR) = (1,1,1,1)
        _Width("_Width",Range(0,1)) = 0.5
        _Length("Length",Range(0,1)) = 0.5
        _LengthSpeed("Length speed",Range(0,100)) = 50
        _Density("Density",Range(0,1)) = 0.5
    }
    SubShader
    {

        CGINCLUDE
        #define PI 3.1415926
        float SignedAngle(float3 from, float3 to)
        {
            float angle = acos(dot(normalize(from), normalize(to)));
            if (cross(to, from).y < 0)
            {
                return PI * 2 - angle;
            }
            return angle;
        }
        //将uv映射到圆环上
        float2 circleUV(float2 uv)
        {
            float2 nuv;
            float3 h = float3(uv.x-0.5, 0, uv.y-0.5);
            float3 f = float3(0, 0, 1);
            nuv.x = SignedAngle(f, h) / 2 / PI;
            nuv.y = length(uv - float2(0.5, 0.5))/0.5;
            return nuv;
        }

		float random1(float x)
		{
			return frac(sin(x)*10007.024);
		}
		float random(float2 st) {
			return frac(sin(dot(st.xy,
				float2(12.9898, 78.233)))*
				43758.5453123);
		}
        ENDCG

         //No culling or depth
        Cull Off 
        ZWrite Off 
        ZTest Always

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _FBM;
            float4 _Color;
            float _Length;
            float _Width;
            float _LengthSpeed;
            float _Density;

           //采样FBM贴图
            fixed samFBM(float2 st)
            {
                float2x2 rot = float2x2(cos(0.5), sin(0.5),
                                -sin(0.5), cos(0.50));
                return tex2D(_FBM,mul(rot, st)).r;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 cuv = circleUV(i.uv);

                cuv.x *= 80;
                
                fixed index = ceil(cuv.x);
                float lineDensity = 1-_Density;
                fixed show = smoothstep(lineDensity-0.01,lineDensity+0.01,samFBM(index+ _Time.x*-10));
                //x映射到0-1-0
                fixed x = abs(cuv.x%1-0.5)*2;
                //宽度收缩比例
                float shrink =(_Width)* random1(index)+_Width;
                //长度减小
                float add = -samFBM(cuv.x+_Time.x*_LengthSpeed)-1+_Length;

                float a = show*(1- smoothstep(0.01,0.01,x-(cuv.y+add)*shrink));

                fixed4 col = _Color;

                x = abs(i.uv.x-0.5)*2;
                col.a *= a*abs(cuv.y-0.2);
                return col;
            }
            ENDCG
        }
    }
}
