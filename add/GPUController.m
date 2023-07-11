//
//  GPUController.m
//  add
//
//  Created by Yang Zhang on 2023/3/28.
//

#import "GPUController.h"
#import <Metal/Metal.h>
#import <simd/simd.h>

const unsigned int arrayLength = 1<<23;
const unsigned int bufferSize  = arrayLength * sizeof(vector_int2);

@interface GPUController() {
    id<MTLDevice> _device;
    id<MTLLibrary> _library;
    id<MTLFunction> _func;
    id<MTLComputePipelineState> _pipe;
    id<MTLCommandQueue> _queue;

    id<MTLBuffer> _bufferA;
    id<MTLBuffer> _bufferB;
    id<MTLBuffer> _bufferR;
}

@end

@implementation GPUController

- (instancetype) init {
    self = [super init];
    
    NSError *error = nil;
    
    _device = MTLCreateSystemDefaultDevice();
    NSAssert(_device, @"Create GPU device fail");

    /* if no metal file, here assert will exit*/
    _library = [_device newDefaultLibrary];
    NSAssert(_library, @"Create default library fail");
    
    _func = [_library newFunctionWithName:@"add_arrays"];
    NSAssert(_func, @"Create function fail");
    
    _pipe = [_device newComputePipelineStateWithFunction:_func error:&error];
    NSAssert(_pipe, @"Create PIPE fail");
    
    _queue = [_device newCommandQueue];
    NSAssert(_queue, @"Create queue fail");
    
    _bufferA = [_device newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    NSAssert(_bufferA, @"Create bufferA fail");
    
    _bufferB = [_device newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    NSAssert(_bufferB, @"Create bufferB fail");
    
    _bufferR = [_device newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    NSAssert(_bufferR, @"Create bufferR fail");
    
    return self;
}

- (void) prepareData: (id<MTLBuffer>)bufferA and:(id<MTLBuffer>)bufferB {
    vector_int2 *pBufferA = bufferA.contents;
    vector_int2 *pBufferB = bufferB.contents;
    
    NSAssert(pBufferA, @"Null pBufferA");
    NSAssert(pBufferB, @"Null pBufferB");
    
    for (int i=0; i<arrayLength; i++) {
        pBufferA[i] = vector2(i+1, i+1);
        pBufferB[i] = vector2(2, 2);
    }
}

- (void)setComputeCommand {
    id<MTLCommandBuffer> buffer = [_queue commandBuffer];
    NSAssert(buffer, @"Create buffer fail");
    
    id<MTLComputeCommandEncoder> encoder = [buffer computeCommandEncoder];
    NSAssert(encoder, @"Buffer encoder fail");
    
    [encoder setComputePipelineState:_pipe];
    
    [self prepareData:_bufferA and:_bufferB];
    
    [encoder setBuffer:_bufferA offset:0 atIndex:0];
    [encoder setBuffer:_bufferB offset:0 atIndex:1];
    [encoder setBuffer:_bufferR offset:0 atIndex:2];
    
    NSUInteger threadGroupSize = _pipe.maxTotalThreadsPerThreadgroup;
    threadGroupSize = MIN(threadGroupSize, arrayLength);
    
    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);
    MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
    
    [encoder dispatchThreads:gridSize threadsPerThreadgroup:threadgroupSize];
    [encoder endEncoding];
    [buffer commit];
    [buffer waitUntilCompleted];
    
    vector_int2 *ret = _bufferR.contents;
}

@end
