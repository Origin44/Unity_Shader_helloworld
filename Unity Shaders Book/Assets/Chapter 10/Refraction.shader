Shader "Unity Shaders Book/Chapter 10/Refraction"{
    Properties{
        _Color("Color Tint",Color)=(1,1,1,1)
        _RefractColor("Refraction Color",Color)=(1,1,1,1)
        _RefractAmount("Refraction Amount",Range(0,1))=1
        _RefractRatio("Refraction Ratio",Range(0.1,1))=0.5
        _Cubemap("Refraction Ratio",Cube)="_Skybox"{}
    }
    Subshader{
        Tags {"RenderType"="Opaque" "Queue"="Geometry"}
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            float4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;
            samplerCUBE _Cubemap;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float3 worldViewDir:TEXCOORD2;
                float3 worldRefr:TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldViewDir=UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefr=refract(-normalize(o.worldViewDir),normalize(o.worldNormal),_RefractRatio);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir=normalize(i.worldViewDir);
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse=_LightColor0.xyz*_Color.xyz*saturate(dot(worldNormal,worldLightDir));
                fixed3 refraction=texCUBE(_Cubemap,i.worldRefr).xyz*_RefractColor.xyz;
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 color=ambient+lerp(diffuse,refraction,_RefractAmount)*atten;
                return fixed4(color,1.0);
            }
            ENDCG
        }
    }
}