//
//  CrashHandle.h
//  CrashLogRecord
//
//  Created by Chance on 16/8/11.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *pathForCrashLogFileName(NSString *name);

@interface CrashHandle : NSObject
@property (nonatomic, strong) UITouch *lastTouch;

/**
 *  启用崩溃记录 在app启动的时候调用 可写在AppDelegate内
 */
+ (void)openCrashLogRecord;

/**
 *  显示崩溃日志列表
 */
+ (void)showCrashLogList;

+ (void)clearCrashLog;

@end
