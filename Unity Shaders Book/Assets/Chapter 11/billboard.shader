Shader "Unity Shaders Book/Chapter 11/Billboard"{
    Properties{
        _MainTex("Main Tex",2D)="white"{}
        _Color("Color Tint",Color)=(0,0,0,0)
        _VerticalBillboarding("Vertical Restraints",Range(0,1))=1
    }
    Subshader{
        Tags{"DisableBatching"="True" "IgnoreProjector"="True" "RenderType"="Transparent" "Queue"="Transparent"}
        Pass{
            Tags{"LightMode"="ForwardPass"}
            ZWrite Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
 			#pragma vertex vert
			#pragma fragment frag

 			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _VerticalBillboarding;
			          
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};


            ENDCG
        }
    }
    Fallback ""
}
