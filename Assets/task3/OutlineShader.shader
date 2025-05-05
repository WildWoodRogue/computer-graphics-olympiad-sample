Shader "Custom/OutlineShader"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Thickness ("Thickness", Float) = 1
        _MainTex ("MainTex", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            ZTest Always Cull Off ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Подключаем нужные библиотеки Unity
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;
            float4 _OutlineColor;
            float _Thickness;
            float4 _MainTex_TexelSize;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.uv = input.uv;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float3 col = tex2D(_MainTex, input.uv).rgb;
                float edge = 0;

                float2 offset = _MainTex_TexelSize.xy * _Thickness;
                for (int x = -1; x <= 1; x++)
                {
                    for (int y = -1; y <= 1; y++)
                    {
                        float3 sample = tex2D(_MainTex, input.uv + float2(x, y) * offset).rgb;
                        edge += distance(col, sample);
                    }
                }

                if (edge > 0.1)
                    return _OutlineColor;

                return float4(col, 1);
            }

            ENDHLSL
        }
    }
}
