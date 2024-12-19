//
//  Shader.metal
//  SwiftUIMetalQuadRenderer
//
//  Created by Yasuo Hasegawa on 2024/12/19.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position;
    float2 uv;
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_main(uint vid [[vertex_id]],
                             constant Vertex* vertices [[buffer(0)]]) {
    VertexOut out;
    float2 pos = vertices[vid].position;
    out.position = float4(pos, 0.0, 1.0);
    out.uv = vertices[vid].uv;
    
    return out;
}


float float_getPi_0()
{
    return 3.14159274101257324;
}

float radians_0(float x_0)
{
    return x_0 * (float_getPi_0() / 180.0);
}

float radians_1(float x_1)
{
    return x_1 * (float_getPi_0() / 180.0);
}

float Hash_0(float2 p_0)
{
    float2 _S1 = fract(sin(p_0 * 123.45600128173828125) * 567.8900146484375);
    float2 randP_0 = _S1 + dot(_S1, _S1 * 34.56000137329101562);
    return fract(randP_0.x * randP_0.y);
}

float bg_0(float2 p_1, float time)
{
    thread float2 _S2 = p_1;
    float4 _S3 = float4(0.0, 11.0, 33.0, 0.0);
    float4 _S4 = cos(radians_0(10.0 * time) - _S3);
    thread matrix<float,int(2),int(2)>  _S5;
    _S5[int(0)] = _S4.xy;
    _S5[int(1)] = _S4.zw;
    float2 _S6 = (((_S5) * (p_1)));
    _S2 = float2(log(length(_S6)), atan(_S6.y / _S6.x));
    _S2.x = _S2.x - time * 0.25;
    float2 _S7 = _S2 * 12.69999980926513672;
    float2 id_0 = floor(_S7);
    _S2 = fract(_S7) - 0.5;
    float n_0 = Hash_0(id_0) * 0.5;
    float n_1 = n_0 + n_0;
    bool _S8;
    if(n_1 < 0.5)
    {
        _S8 = true;
    }
    else
    {
        _S8 = n_1 >= 0.80000001192092896;
    }
    if(_S8)
    {
        float dir_0;
        if(n_1 >= 0.80000001192092896)
        {
            dir_0 = 1.0;
        }
        else
        {
            dir_0 = -1.0;
        }
        float4 _S9 = cos(radians_0(dir_0 * 45.0) - _S3);
        thread matrix<float,int(2),int(2)>  _S10;
        _S10[int(0)] = _S9.xy;
        _S10[int(1)] = _S9.zw;
        float2 _S11 = (((_S10) * (_S2)));
        _S2 = _S11;
        _S2.x = abs(_S11.x) - 0.35499998927116394;
    }
    return max(- (_S2.x + 0.02500000037252903), _S2.x - 0.02500000037252903);
}

float sdBox_0(float2 p_2, float2 b_0)
{
    float2 d_0 = abs(p_2) - b_0;
    return length(max(d_0, float2(0.0) )) + min(max(d_0.x, d_0.y), 0.0);
}

float sdRoundedBox_0(float2 p_3, float2 b_1, float4 r_0)
{
    thread float4 _S12 = r_0;
    float2 _S13;
    if(p_3.x > 0.0)
    {
        _S13 = _S12.xy;
    }
    else
    {
        _S13 = _S12.zw;
    }
    _S12.xy = _S13;
    float _S14;
    if(p_3.y > 0.0)
    {
        _S14 = _S12.x;
    }
    else
    {
        _S14 = _S12.y;
    }
    _S12.x = _S14;
    float2 q_0 = abs(p_3) - b_1 + _S12.x;
    return min(max(q_0.x, q_0.y), 0.0) + length(max(q_0, float2(0.0) )) - _S12.x;
}

float charP_0(float2 p_4)
{
    float2 _S15 = p_4 - float2(0.0, 0.02999999932944775);
    return min(sdBox_0(p_4, float2(0.01499999966472387, 0.07999999821186066)), max(- _S15.x, abs(sdRoundedBox_0(_S15, float2(0.07999999821186066, 0.03500000014901161), float4(0.03500000014901161, 0.03500000014901161, 0.0, 0.0))) - 0.01499999966472387)) - 0.00300000002607703;
}

float opSmoothSubtraction_0(float d1_0, float d2_0, float k_0)
{
    float h_0 = clamp(0.5 - 0.5 * (d2_0 + d1_0) / k_0, 0.0, 1.0);
    return mix(d2_0, - d1_0, h_0) + k_0 * h_0 * (1.0 - h_0);
}

float charY_0(float2 p_5)
{
    float2 _S16 = p_5 - float2(0.0, 0.02999999932944775);
    float a_0 = radians_1(-30.0);
    float2 _S17 = float2(cos(a_0), sin(a_0));
    return min(sdBox_0(p_5 + float2(0.0, 0.05000000074505806), float2(0.01499999966472387, 0.02999999932944775)), opSmoothSubtraction_0(- dot(p_5 - float2(0.02700000070035458, 0.0), _S17), opSmoothSubtraction_0(dot(_S16 - float2(0.01400000043213367, 0.0), _S17), sdBox_0(_S16, float2(0.07999999821186066, 0.05000000074505806)), 0.00300000002607703), 0.00300000002607703)) - 0.00300000002607703;
}

float py_0(float2 p_6)
{
    float2 _S18 = p_6 * 0.2800000011920929;
    float4 _S19 = cos(radians_0(-90.0) - float4(0.0, 11.0, 33.0, 0.0));
    thread matrix<float,int(2),int(2)>  _S20;
    _S20[int(0)] = _S19.xy;
    _S20[int(1)] = _S19.zw;
    float2 _S21 = (((_S20) * (_S18)));
    return min(charP_0(_S21 - float2(-0.05999999865889549, 0.0)), charY_0(_S21 - float2(0.05999999865889549, 0.0)));
}

float largeP_0(float2 p_7)
{
    float2 _S22 = p_7 * 0.25;
    float4 _S23 = cos(radians_0(-90.0) - float4(0.0, 11.0, 33.0, 0.0));
    thread matrix<float,int(2),int(2)>  _S24;
    _S24[int(0)] = _S23.xy;
    _S24[int(1)] = _S23.zw;
    return charP_0((((_S24) * (_S22))));
}

float mod2_0(float a_1, float b_2)
{
    return a_1 - b_2 * floor(a_1 / b_2);
}

float dots_0(float2 p_8, float time)
{
    thread float2 _S25 = p_8;
    float2 _S26 = p_8 - time * 0.10000000149011612;
    _S25 = _S26;
    _S25.x = mod2_0(_S26.x, 0.10000000149011612) - 0.05000000074505806;
    _S25.y = mod2_0(_S25.y, 0.10000000149011612) - 0.05000000074505806;
    return length(_S25) - 0.02999999932944775;
}

float largeY_0(float2 p_9)
{
    float2 _S27 = p_9 * 0.25;
    float4 _S28 = cos(radians_0(-90.0) - float4(0.0, 11.0, 33.0, 0.0));
    thread matrix<float,int(2),int(2)>  _S29;
    _S29[int(0)] = _S28.xy;
    _S29[int(1)] = _S28.zw;
    return charY_0((((_S29) * (_S27))));
}

float stripes_0(float2 p_10, float dir_1, float space_0, float s_0, float time)
{
    float4 _S30 = cos(radians_0(30.0) - float4(0.0, 11.0, 33.0, 0.0));
    thread matrix<float,int(2),int(2)>  _S31;
    _S31[int(0)] = _S30.xy;
    _S31[int(1)] = _S30.zw;
    thread float2 _S32 = (((_S31) * (p_10)));
    _S32.x = _S32.x + time * 0.10000000149011612 * dir_1;
    _S32.x = mod2_0(_S32.x, space_0) - space_0 * 0.5;
    return max(abs(_S32).x - s_0, abs(_S32).y - 20.0);
}

float pys_0(float2 p_11, float n_2, float time)
{
    thread float2 _S33 = p_11;
    _S33.y = _S33.y + time * n_2 * 0.30000001192092896 + 0.5;
    float _S34 = _S33.y;
    _S33.y = ((((_S34) < 0.0) ? -fmod(-(_S34),abs((1.0))) : fmod((_S34),abs((1.0))))) - 0.5;
    float2 _S35 = _S33 * 2.0;
    float2 _S36 = (abs(_S35) - 0.5) * float2(float((int(sign((_S35.x))))), float((int(sign((_S35.y))))));
    _S33 = _S36;
    return py_0(_S36);
}

float draw_0(float2 p_12, float time)
{
    thread float2 _S37 = p_12;
    float time_0 = time;
    float4 _S38 = cos(radians_0(10.0 * time_0) - float4(0.0, 11.0, 33.0, 0.0));
    thread matrix<float,int(2),int(2)>  _S39;
    _S39[int(0)] = _S38.xy;
    _S39[int(1)] = _S38.zw;
    float2 _S40 = (((_S39) * (p_12)));
    _S37 = float2(log(length(_S40)), atan(_S40.y / _S40.x));
    _S37.x = _S37.x - time_0 * 0.20000000298023224;
    float2 _S41 = _S37 * 2.53999996185302734;
    float n_3 = clamp(Hash_0(floor(_S41)), 0.20000000298023224, 1.0);
    float2 _S42 = fract(_S41) - 0.5;
    _S37 = _S42;
    float d_1 = py_0(_S42);
    float d_2;
    if(n_3 <= 0.60000002384185791)
    {
        float d_3 = mix(d_1, largeP_0(_S37), clamp(sin(3.0 * time_0 * n_3), 0.0, 1.0));
        if(n_3 >= 0.5)
        {
            float _S43 = dots_0(_S37, time_0);
            d_2 = min(max(_S43, d_3), abs(d_3) - 0.0020000000949949);
        }
        else
        {
            d_2 = d_3;
        }
    }
    else
    {
        bool _S44;
        if(n_3 >= 0.60000002384185791)
        {
            _S44 = n_3 < 0.89999997615814209;
        }
        else
        {
            _S44 = false;
        }
        if(_S44)
        {
            float d_4 = mix(d_1, largeY_0(_S37), clamp(sin(3.0 * time_0 * n_3), 0.0, 1.0));
            float _S45 = stripes_0(_S37, -1.0, 0.05000000074505806, 0.00499999988824129, time_0);
            d_2 = max(_S45, d_4);
        }
        else
        {
            if(n_3 >= 0.89999997615814209)
            {
                float _S46 = pys_0(_S37, n_3 * 0.5, time_0);
                d_2 = _S46;
            }
            else
            {
                d_2 = d_1;
            }
        }
    }
    return d_2;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant float2 &resolution [[buffer(1)]],
                              constant float &time [[buffer(2)]]) {
    float _S48 = float(resolution.y);
    float2 p_13 = (in.position.xy - 0.5 * resolution.xy) / _S48;
    p_13.y*=-1.0; // Adjust the y coordinate of the UV to align with GLSL
    float3 col_0 = float3(0.0, 0.0, 0.0);
    float _S49 = bg_0(p_13, time);
    float3 col_1 = mix(col_0, float3(0.30000001192092896, 0.30000001192092896, 0.30000001192092896), float3((1.0 - smoothstep(-1.20000004768371582, 1.20000004768371582, _S49 * _S48))) );
    float _S50 = draw_0(p_13, time);
    float3 col_2 = mix(mix(col_1, float3(1.0, 1.0, 1.0), float3((1.0 - smoothstep(-1.20000004768371582, 1.20000004768371582, _S50 * _S48))) ), col_0, float3((1.0 - smoothstep(0.0, 0.30000001192092896, length(p_13) - 0.05000000074505806))) );
    return float4(col_2.x, col_2.y, col_2.z, 1.0);
}


//// for test purpose to use
//fragment float4 fragment_main(VertexOut in [[stage_in]],
//                              constant float2 &resolution [[buffer(1)]],
//                              constant float &time [[buffer(2)]]) {
//    float2 uv = (in.position.xy-0.5*resolution.xy)/resolution.y;
//    uv.y*=-1.0; // Adjust the y coordinate of the UV to align with GLSL
//    float d = length(uv-float2(-0.2,-0.2))-0.1+sin(time)*0.1-0.1;
//    float3 baseColor = float3(0.0, 1.0, 0.0);
//    float3 col = mix(baseColor, float3(1.0, 0.0, 0.0), 1.0-smoothstep(0.0, 0.001, d));
//    
//    return float4(col, 1.0);
//}

