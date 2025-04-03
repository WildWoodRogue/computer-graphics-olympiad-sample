Shader "Custom/AdvancedPBR"
{
    Properties
    {
        [Header(Base Maps)]
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color ("Base Color", Color) = (1,1,1,1)
        
        [Header(Metallic and Roughness)]
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _MetallicMap ("Metallic Map (R)", 2D) = "white" {}
        
        _Roughness ("Roughness", Range(0,1)) = 0.5
        _RoughnessMap ("Roughness Map (R)", 2D) = "white" {}
        
        [Header(Normal Map)]
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Strength", Float) = 1.0
        
        [Header(Light Settings)]
        _LightColor ("Light Color", Color) = (1,1,1,1)
        _LightDir ("Light Direction", Vector) = (0, -1, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM
        #pragma surface surf CustomPBR fullforwardshadows
        #pragma target 4.0

        #include "UnityPBSLighting.cginc"
        #include "UnityStandardUtils.cginc"

       
        sampler2D _MainTex, _MetallicMap, _RoughnessMap, _BumpMap;
        float4 _Color, _LightColor, _LightDir;
        float _Metallic, _Roughness, _BumpScale;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MetallicMap;
            float2 uv_RoughnessMap;
            float2 uv_BumpMap;
        };

        
        inline half4 LightingCustomPBR(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
        {
            
            half4 pbr = LightingStandard(s, viewDir, gi);

            
            pbr.rgb *= _LightColor.rgb;
            return pbr;
        }

        void LightingCustomPBR_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
        
            float4 albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = albedo.rgb;
            o.Alpha = albedo.a;

           
            o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap), _BumpScale);

           
            float metallic = tex2D(_MetallicMap, IN.uv_MetallicMap).r * _Metallic;
            o.Metallic = saturate(metallic);

        
            float roughness = tex2D(_RoughnessMap, IN.uv_RoughnessMap).r * _Roughness;
            o.Smoothness = 1.0 - saturate(roughness);

        
            #ifdef DIRECTIONAL
                o.Emission = _LightColor.rgb * saturate(dot(o.Normal, normalize(-_LightDir.xyz)));
            #endif
        }
        ENDCG
    }
    FallBack "Standard"
}