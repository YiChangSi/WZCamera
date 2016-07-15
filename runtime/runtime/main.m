//
//  main.m
//  runtime
//
//  Created by David on 16/7/12.
//  Copyright © 2016年 detu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <objc/message.h>
#import "Camera.h"
#import <objc/runtime.h>
#import "Camera+wz.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
        Camera *cam = [[Camera alloc] init];
        
        cam.age = 10;
        
        //发送消息 
        objc_msgSend(cam, @selector(setAge:), 0);
        
        cam.weight = 20;
        
        
        NSLog(@"%d--%d", cam.age, cam.weight);
        
        
        //获取成员变量
       unsigned int count = 0;
      Ivar *ivars =  class_copyIvarList([Camera class], &count);
        for (int i = 0; i <count; i++) {
            Ivar ivar = ivars[i];
         const char *anme = ivar_getName(ivar);
            const char *type = ivar_getTypeEncoding(ivar);
            NSLog(@"%s---%s", anme, type);
        }
        
        
        
        NSLog(@"蛤蛤");
        
        
        
    }
    return 0;
}
