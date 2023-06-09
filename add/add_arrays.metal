//
//  add_arrays.metal
//  add
//
//  Created by Yang Zhang on 2023/3/29.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_arrays(constant vector_int2 *inA,
                       constant vector_int2 *inB,
                       device vector_int2 *result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result[index] = inA[index] + inB[index];
}
