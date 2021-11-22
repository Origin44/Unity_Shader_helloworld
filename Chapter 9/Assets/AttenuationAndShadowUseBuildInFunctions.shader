Shader "Unity Shaders Book/Chapter 9/AttenuationAndShadowUseBuildInFunctions"{
    Properties{
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",range(8.0,256))=20
    }
    Subshader{
        Tags{"RenderType"="Opaque"}
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldPos=i.worldPos;
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));
                fixed3 halfDir=normalize(viewDir+worldLightDir);
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldLightDir,worldNormal));
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(halfDir,worldNormal)),_Gloss);
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                return fixed4(ambient+(diffuse+specular)*atten,1.0);
            }
            ENDCG
        }
        Pass{
            Tags{"LightMode"="ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir=normalize(viewDir+worldLightDir);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(halfDir,worldNormal)),_Gloss);
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldLightDir,worldNormal));
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                return fixed4((diffuse+specular)*atten,1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
