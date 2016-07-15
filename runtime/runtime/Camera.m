//
//  camera.m
//  runtime
//
//  Created by David on 16/7/12.
//  Copyright © 2016年 detu. All rights reserved.
//

#import "Camera.h"

@implementation Camera

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (int)age {
    
    if (!_age) {
        _age = 15;
    }
    return _age;
    
}


//- (void)setAge:(int)age {
//    if (age < 10) {
//        _age = 5;
//    }
//}
@end
