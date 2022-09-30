Shader "Shipment/SeeThrough"
{
    Properties
    {
        [NoScaleOffset]_Main_Texture("Main Texture", 2D) = "white" {}
        _Tint("Tint", Color) = (0, 0, 0, 0)
        _Position("Player Position", Vector) = (0, 0, 0, 0)
        _Size("Size", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Opacity("Opacity", Range(0, 1)) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0 = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float4 _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.tex, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.samplerstate, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_R_4 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.r;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_G_5 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.g;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_B_6 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.b;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_A_7 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.a;
            float4 _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0 = _Tint;
            float4 _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0, _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0, _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2);
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.BaseColor = (_Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0 = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float4 _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.tex, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.samplerstate, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_R_4 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.r;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_G_5 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.g;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_B_6 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.b;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_A_7 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.a;
            float4 _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0 = _Tint;
            float4 _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0, _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0, _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2);
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.BaseColor = (_Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            output.interp1.xyzw =  input.texCoord1;
            output.interp2.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            output.texCoord1 = input.interp1.xyzw;
            output.texCoord2 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0 = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float4 _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.tex, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.samplerstate, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_R_4 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.r;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_G_5 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.g;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_B_6 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.b;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_A_7 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.a;
            float4 _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0 = _Tint;
            float4 _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0, _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0, _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2);
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.BaseColor = (_Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0 = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float4 _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.tex, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.samplerstate, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_R_4 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.r;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_G_5 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.g;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_B_6 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.b;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_A_7 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.a;
            float4 _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0 = _Tint;
            float4 _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0, _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0, _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2);
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.BaseColor = (_Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2.xyz);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHAPREMULTIPLY_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0 = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float4 _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.tex, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.samplerstate, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_R_4 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.r;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_G_5 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.g;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_B_6 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.b;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_A_7 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.a;
            float4 _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0 = _Tint;
            float4 _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0, _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0, _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2);
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.BaseColor = (_Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            output.interp1.xyzw =  input.texCoord1;
            output.interp2.xyzw =  input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            output.texCoord1 = input.interp1.xyzw;
            output.texCoord2 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0 = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float4 _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.tex, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.samplerstate, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_R_4 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.r;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_G_5 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.g;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_B_6 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.b;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_A_7 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.a;
            float4 _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0 = _Tint;
            float4 _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0, _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0, _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2);
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.BaseColor = (_Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0 = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float4 _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0 = SAMPLE_TEXTURE2D(_Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.tex, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.samplerstate, _Property_60ff3be2f1104d70bf59475167c5ef2b_Out_0.GetTransformedUV(IN.uv0.xy));
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_R_4 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.r;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_G_5 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.g;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_B_6 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.b;
            float _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_A_7 = _SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0.a;
            float4 _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0 = _Tint;
            float4 _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2;
            Unity_Multiply_float4_float4(_SampleTexture2D_cc9bf0d27b8d485bb9f74a7ab5253fbc_RGBA_0, _Property_4f5e477fafb34bbfb201ce10ae183b49_Out_0, _Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2);
            float _Property_be12a20627094cd68816e07f8c8935ba_Out_0 = _Smoothness;
            float4 _ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0 = _Position;
            float2 _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3;
            Unity_Remap_float2(_Property_5e9dd7f18ca84a1bbbd328156a4b91a0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3);
            float2 _Add_dde4fdbbbd124af796761dc0d7682263_Out_2;
            Unity_Add_float2((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), _Remap_ca22257c940b4f26b1ceb34880a7c69f_Out_3, _Add_dde4fdbbbd124af796761dc0d7682263_Out_2);
            float2 _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_ee89d02e1e524c7f80eee607e1d2a61a_Out_0.xy), float2 (1, 1), _Add_dde4fdbbbd124af796761dc0d7682263_Out_2, _TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3);
            float2 _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2;
            Unity_Multiply_float2_float2(_TilingAndOffset_af5e2b325c1e49678baf9fdfa1307c0f_Out_3, float2(2, 2), _Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2);
            float2 _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2;
            Unity_Subtract_float2(_Multiply_f1936d37eb6d4daaba0d2a56e114d5bd_Out_2, float2(1, 1), _Subtract_667152008c804b3d990a0e3c53effbb4_Out_2);
            float _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2;
            Unity_Divide_float(_ScreenParams.y, _ScreenParams.x, _Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2);
            float _Property_d7e92d875e054664ae6127f907f74b8b_Out_0 = _Size;
            float _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2;
            Unity_Multiply_float_float(_Divide_023e5c4dd8d44b0180367f9264ac9f7f_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0, _Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2);
            float2 _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0 = float2(_Multiply_cdd2bd5041c24875ac20c3767329ab7e_Out_2, _Property_d7e92d875e054664ae6127f907f74b8b_Out_0);
            float2 _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2;
            Unity_Divide_float2(_Subtract_667152008c804b3d990a0e3c53effbb4_Out_2, _Vector2_0e0aef8a784e4d03a165f76aba2964f5_Out_0, _Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2);
            float _Length_54028c051c5d4aa487a1d29082639ed7_Out_1;
            Unity_Length_float2(_Divide_f418b8e7c5be434dbfcb4653c6b4f0be_Out_2, _Length_54028c051c5d4aa487a1d29082639ed7_Out_1);
            float _OneMinus_dd38785d4de24741935de73c502276f1_Out_1;
            Unity_OneMinus_float(_Length_54028c051c5d4aa487a1d29082639ed7_Out_1, _OneMinus_dd38785d4de24741935de73c502276f1_Out_1);
            float _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1;
            Unity_Saturate_float(_OneMinus_dd38785d4de24741935de73c502276f1_Out_1, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1);
            float _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3;
            Unity_Smoothstep_float(0, _Property_be12a20627094cd68816e07f8c8935ba_Out_0, _Saturate_afe33f9163b24f9d9c24f69174db71fb_Out_1, _Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3);
            float _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2;
            Unity_GradientNoise_Deterministic_float(IN.uv0.xy, 10, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2);
            float _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2;
            Unity_Multiply_float_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _GradientNoise_56c9d486b41b40de9c886b6081433b0d_Out_2, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2);
            float _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2;
            Unity_Add_float(_Smoothstep_98c4eb1f104340ffaa89d44079e78e2e_Out_3, _Multiply_dee47da4c83845b4989cde4ee5f0bd8e_Out_2, _Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2);
            float _Property_666f70954dac42c2b1c17031add4e2ee_Out_0 = _Opacity;
            float _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2;
            Unity_Multiply_float_float(_Add_a67fc1485fe949ed91c62e5fd901bf9d_Out_2, _Property_666f70954dac42c2b1c17031add4e2ee_Out_0, _Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2);
            float _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3;
            Unity_Clamp_float(_Multiply_6701f02fe7c94da980e45faf7b9c6e3a_Out_2, 0, 1, _Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3);
            float _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            Unity_OneMinus_float(_Clamp_9943d94dfcd3463d8e39c78edef3cdfe_Out_3, _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1);
            surface.BaseColor = (_Multiply_4de3dac1147549aaaca7782bcd2c3fe0_Out_2.xyz);
            surface.Alpha = _OneMinus_988c9c6c152e40e9aca7bb76f81d23be_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}