﻿Shader "Custom/HalfLambert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(1.0,256)) = 20
    }
    SubShader
    {
        Pass
        {
            name "halfLambert"

            Tags  
            {  
                "LightMode" = "ForwardBase"  
            } 

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                fixed4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : NORMAL;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = v.uv; 
                return o;
            }

            sampler2D _MainTex;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 worldNormal= normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 lambert =  0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lambert;
                fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                fixed4 col = tex2D(_MainTex, i.uv) * fixed4(diffuse + ambient,1.0) + fixed4(specular,1.0);
                return col;
            }
            ENDCG
        }

        Pass
        {
            name "add"

            Tags 
            {  
                "LightMode" = "ForwardAdd"  
            } 

            Blend One One  

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "Autolight.cginc" 

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                fixed4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : NORMAL; 
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            fixed4 frag (v2f i) : SV_Target
            {                
                fixed3 worldNormal = normalize(i.worldNormal);
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed atten = 1.0;
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    //float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
                    //fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos.xyz)
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                #endif

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                fixed3 lambert =  0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * lambert;
                fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                fixed4 col = tex2D(_MainTex, i.uv) * fixed4(diffuse + ambient,1.0) + fixed4(specular,1.0); 


                return col * atten;    
            }
            ENDCG
        }
    }
}