Shader "Custom/PBRShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _RoughnessTex ("Roughness Map", 2D) = "white" {}
        _MetallicTex ("Metallic Map", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _RoughnessTex;
        sampler2D _MetallicTex;
        sampler2D _NormalMap;
        fixed4 _Color;
        half _Glossiness;
        half _Metallic;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_RoughnessTex;
            float2 uv_MetallicTex;
            float2 uv_NormalMap;
            float3 worldDir;
            float3 viewDir;
            float3 worldRefl;
            INTERNAL_DATA
        };


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo (Diffuse Color)
            fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = albedo.rgb;

            // Metallic and Roughness from textures
            half roughness = tex2D(_RoughnessTex, IN.uv_RoughnessTex).r;
            half metallic  = tex2D(_MetallicTex, IN.uv_MetallicTex).r;

            // Apply user defined metallic and roughness
            o.Metallic  = _Metallic * metallic; // Mix user defined value with texture value.
            o.Smoothness = _Glossiness * (1-roughness); // Invert roughness to get smoothness

            // Normal Map
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));


            o.Alpha = albedo.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}