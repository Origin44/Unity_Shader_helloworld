// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Unity Shaders Book/Chapter 9/ForwardRendering"{
    Properties{
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",range(8.0,256))=20
    }
    Subshader{
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
            };

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
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
                fixed atten=1.0;
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
            };

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldPos=i.worldPos;
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz-i.worldPos.xyz);
                #endif
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));
                fixed3 halfDir=normalize(viewDir+worldLightDir);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(halfDir,worldNormal)),_Gloss);
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed atten=1.0;
                #else
                    float3 lightCoord=mul(unity_WorldToLight,float4(i.worldPos,1.0)).xyz;
                    fixed atten=tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #endif
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldLightDir,worldNormal));
                return fixed4((diffuse+specular)*atten,1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}