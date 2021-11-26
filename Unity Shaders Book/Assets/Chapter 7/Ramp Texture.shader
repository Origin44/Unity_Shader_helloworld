Shader "Unity Shaders Book/Chapter 7/Ramp Texture"{
    Properties{
        _Color("Color Tint",Color)=(1,1,1,1)
        _Ramptex("Ramp Tex",2D)="white"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",range(8.0,256))=20
        }
    Subshader{
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _Ramptex;
            float4  _Ramptex_ST;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float2 texcoord:TEXCOORD0;
            };

            struct v2f{
                float2 uv:TEXCOORD0;
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv=TRANSFORM_TEX(v.texcoord,_Ramptex);
                o.worldNormal=UnityObjectToWorldNormal(v.vertex);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed halflambert=0.5*dot(worldLightDir,worldNormal)+0.5;
                fixed3 diffusecolor=tex2D(_Ramptex,fixed2(halflambert,halflambert)).rgb*_Color.rgb;
                fixed3 diffuse=diffusecolor*_LightColor0;
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir=normalize(viewDir+worldLightDir);
                fixed3 specular=_LightColor0*_Specular*pow(saturate(dot(worldNormal,halfDir)),_Gloss);
                return fixed4(diffuse+specular+ambient,1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}