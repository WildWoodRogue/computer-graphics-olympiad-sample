Shader "Custom/PBRShader"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _RoughnessMap ("Roughness Map", 2D) = "white" {}
        _MetallicMap ("Metallic Map", 2D) = "white" {}
        _Roughness ("Roughness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float3 tangent : TEXCOORD4;
                float3 bitangent : TEXCOORD5;
            };
            
            sampler2D _MainTex, _NormalMap, _RoughnessMap, _MetallicMap;
            float _Roughness, _Metallic;
            
            v2f vert(appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 tangent = UnityObjectToWorldDir(v.tangent);
                float3 bitangent = cross(normal, tangent) * v.tangent.w;
                o.normal = normal;
                o.tangent = tangent;
                o.bitangent = bitangent;
                o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
                
                return o;
            }
            
            float3 FresnelSchlick(float cosTheta, float3 F0)
            {
                return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
            }
            
            float Distribution(float3 N, float3 H, float roughness)
            {
                float NdotH = max(dot(N, H), 0.0);
                float num = roughness;
                float denom = (NdotH * NdotH* (roughness - 1.0) + 1.0);
                denom = UNITY_PI * denom * denom;
                
                return num / denom;
            }
            
            float GeometrySchlick(float NdotV, float roughness)
            {
                float r = (roughness + 1.0);
                float k = (r * r) / 8.0;
                return NdotV / (NdotV * (1.0 - k) + k);
            }
            
            float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
            {
                float NdotV = max(dot(N, V), 0.0);
                float NdotL = max(dot(N, L), 0.0);
                return GeometrySchlick(NdotV, roughness) * GeometrySchlick(NdotL, roughness);
            }
            
            float4 frag(v2f i) : SV_Target
            {
                float3 albedo = tex2D(_MainTex, i.uv).rgb;
                float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                normal = normalize(i.tangent * normal.x + i.bitangent * normal.y + i.normal * normal.z);
                
                float roughness = tex2D(_RoughnessMap, i.uv).r * _Roughness;
                float metallic = tex2D(_MetallicMap, i.uv).r * _Metallic;
                
                float3 V = normalize(i.viewDir);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 H = normalize(V + L);
                
                float3 F0 = lerp(0.04, albedo, metallic);
                float3 F = FresnelSchlick(max(dot(H, V), 0.0), F0);
                
                float NDF = Distribution(normal, H, roughness);
                float G = GeometrySmith(normal, V, L, roughness);
                
                float3 specular = (NDF * G * F) / (4.0 * max(dot(normal, V), 0.0) * max(dot(normal, L), 0.0) + 0.001);
                float3 kS = F;
                float3 kD = 1.0 - kS;
                kD *= 1.0 - metallic;
                
                float3 radiance = _LightColor0.rgb *2* max(dot(normal, L), 0.0);
                float3 color = (kD * albedo / UNITY_PI + specular) * radiance;
                
                return float4(color, 1.0);
            }
            
            ENDCG
        }
    }
}
