//
//  Shaders.metal
//  metaltest
//
//  Created by David Gavilan on 3/31/16.
//  Copyright © 2016 David Gavilan. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexInOut
{
    float4  position [[position]];
    float4  color;
};

struct LineParticle
{
    float4 start;
    float4 end;
};

vertex VertexInOut passThroughVertex(uint vid [[ vertex_id ]],
                                     constant packed_float4* position  [[ buffer(0) ]],
                                     constant float* alpha    [[ buffer(1) ]])
{
    VertexInOut outVertex;
    
    outVertex.position = position[vid];
    outVertex.color    = float4(vid % 2,1,1, alpha[vid]);
    //outVertex.color    = float4(1,0,0,1);
    return outVertex;
};

// can only write to a buffer if the output is set to void
vertex void updateRaindrops(uint vid [[ vertex_id ]],
                            constant LineParticle* particle  [[ buffer(0) ]],
                            device LineParticle* updatedParticle  [[ buffer(1) ]])
{
    LineParticle outParticle;
    float4 velocity = float4(0, -0.01, 0, 0);
    outParticle.start = particle[vid].start + velocity;
    outParticle.end = particle[vid].end + velocity;
    if (outParticle.start.y < -1) {
        outParticle.end.y = 1;
        outParticle.start.y = outParticle.end.y + 0.1;
    }
    updatedParticle[vid] = outParticle;
};

fragment half4 passThroughFragment(VertexInOut inFrag [[stage_in]])
{
    return half4(inFrag.color);
};
