Shader "Unity Shaders Book/Chapter 10/GlassRefraction"{
    Properties{
        _RefractAmount("Refraction Amount",Range(0.0,1.0))=1.0
        _MainTex("Main Texture",2D)="white"{}
        _Distortion("Distortion",Range(0,100))=10
        _Cubemap("CubeMap",Cube)="_Skybox"{}
        _BumpMap("Bump Map",2D)="bump"{}
    }
    SubShader{
        Tags{"Queue"="Transparent" "RenderType"="Opaque"}
        GrabPass{"_RefractionTex"}
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed _RefractAmount;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _Cubemap;
            float _Distortion;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

 			struct a2v {
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 tangent: TANGENT; 
				float2 texcoord: TEXCOORD0;
			};        

			struct v2f {
				float4 pos: SV_POSITION;
				float4 scrPos: TEXCOORD0;
				float4 uv: TEXCOORD1;
				float4 TtoW0: TEXCOORD2;  
			    float4 TtoW1: TEXCOORD3;  
			    float4 TtoW2: TEXCOORD4; 
			};

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.scrPos=ComputeGrabScreenPos(o.pos);
                o.uv.xy=TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv.zw=TRANSFORM_TEX(v.texcoord,_BumpMap);
                float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;

                o.TtoW0=float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1=float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2=float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                float3 worldPos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                fixed3 worldViewDir=normalize((UnityWorldSpaceViewDir(worldPos)));
                fixed3 bump=UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                float2 offset=bump.xy*_Distortion*_RefractionTex_TexelSize;
                i.scrPos.xy+=offset;
                fixed3 RefrCol=tex2D(_RefractionTex,i.scrPos.xy/i.scrPos.w).rgb;
                bump=normalize(fixed3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
                fixed3 ReflDir=reflect(-worldViewDir,bump);
                fixed3 ReflCol=texCUBE(_Cubemap,ReflDir).rgb*tex2D(_MainTex,i.uv.xy).rgb;
                fixed3 finalColor=_RefractAmount*RefrCol+(1-_RefractAmount)*ReflCol;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}