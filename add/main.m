//
//  main.m
//  add
//
//  Created by Yang Zhang on 2023/3/28.
//

#import <Foundation/Foundation.h>
#import "GPUController.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        GPUController *gpuController = [[GPUController alloc] init];
        [gpuController setComputeCommand];
        NSLog(@"Hello, World!");
    }
    return 0;
}
