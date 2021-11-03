// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level" {
    Properties {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",range(8.0,256))=20
    }
    Subshader{
        Pass{
            Tags { "LightMode"="ForwardBase"}
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                fixed3 color:COLOR;
            };

            v2f vert(a2v v){
                v2f o;
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                o.pos=UnityObjectToClipPos(v.vertex);
                fixed3 worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                fixed3 WorldLightDir=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 reflectdir=normalize(reflect(-WorldLightDir,worldNormal));
                fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectdir,viewDir)),_Gloss);
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,WorldLightDir));
                o.color=diffuse+ambient+specular;
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                return fixed4(i.color,1.0);
            }

            ENDCG
        }
    }
    
    FallBack "Specular"


}
