//
//  Camera+wz.m
//  runtime
//
//  Created by David on 16/7/12.
//  Copyright © 2016年 detu. All rights reserved.
//

#import "Camera+wz.h"
#import <objc/runtime.h>


@implementation Camera (wz)

static int weightKey;

//- (void)setWeight:(int)weight {
//    
//    //动态添加成员对象
//    objc_setAssociatedObject(self, &weightKey, @(weight), OBJC_ASSOCIATION_ASSIGN);
//    
//    
//    
//    
//}



- (int)weight {
    

    
    return [objc_getAssociatedObject(self, &weightKey) intValue];
}

@end
