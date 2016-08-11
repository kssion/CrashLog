//
//  CrashHandle.m
//  CrashLogRecord
//
//  Created by Chance on 16/8/11.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CrashHandle.h"

static CrashHandle *handle;

#pragma mark - 记录崩溃日志

/**
 *  获取路径
 */
NSString *pathForCrashLogFileName(NSString *name) {
    NSMutableString *path = [NSMutableString stringWithFormat:@"%@/Library/Caches/CrashLog", NSHomeDirectory()];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (name && ![name isEqualToString:@""]) {
        [path appendFormat:@"/%@", name];
    }
    
    return [path copy];
}

/**
 *  生成屏幕截图
 */
UIImage *viewScreenshot(UIView *view) {
    CGSize imageSize = [view bounds].size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef contextWindow = UIGraphicsGetCurrentContext();
    [[view layer] renderInContext:contextWindow];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"Screenshot OK.");
    return image;
}

/**
 *  绘制崩溃截图
 */
UIImage *drawImage(UITouch *touch) {
    
    // 崩溃页面截图
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIImage *image = viewScreenshot(window);
    
    CGPoint point = [touch locationInView:window];
    UIView *view = touch.view;
    CGRect rect = [view.superview convertRect:view.frame toView:nil];
    //    CGPoint center = [view.superview convertPoint:view.center toView:nil];
    
    // 绘制点击位置
    CGSize sz = [image size];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sz.width, sz.height), NO, 0);
    [image drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor redColor] setStroke];
    
    CGContextAddRect(context, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(1, 1, 1, 1)));
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
    
    CGContextAddArc(context, point.x, point.y, 1, 0, M_PI * 2, 0);
    CGContextStrokePath(context);
    
    CGContextAddArc(context, point.x, point.y, 5, 0, M_PI * 2, 0);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    
    NSString *text = NSStringFromClass(view.class);
    
    CGPoint p = CGPointMake(rect.origin.x + 2, rect.origin.y + 2);
    [text drawAtPoint:p withAttributes:@{NSForegroundColorAttributeName: [UIColor redColor],
                                         NSFontAttributeName: [UIFont systemFontOfSize:8],
                                         NSBackgroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.9]}];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"DrawImage OK.");
    return image;
}

/**
 *  异常捕获
 */
void UncaughtExceptionHandler(NSException *exception) {
    
    NSMutableString *infoString = [NSMutableString stringWithString:@"Date: "];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy.MM.dd HH:mm:ss";
    
    [infoString appendString:[formatter stringFromDate:[NSDate date]]];
    [infoString appendString:@"\n\n"];
    
    UITouch *touch = handle.lastTouch;
    
    UIImage *image = drawImage(touch);
    
    [infoString appendFormat:@"%@", touch];
    [infoString appendString:@"\n\n"];
    
    formatter.dateFormat = @"yyyy.MM.dd_HH.mm.ss";
    NSString *fileName = [NSString stringWithFormat:@"crash_%@", [formatter stringFromDate:[NSDate date]]];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *path = pathForCrashLogFileName([fileName stringByAppendingString:@".jpg"]);
    [imageData writeToFile:path atomically:YES];
    
    // 崩溃信息
    NSArray *array = [exception callStackSymbols]; // 当前调用栈信息
    NSString *reason = [exception reason]; // 崩溃的原因
    NSString *name = [exception name]; // 异常类型
    
    [infoString appendString:@"nexception type: "];
    [infoString appendString:name];
    [infoString appendString:@"\n crash reason: "];
    [infoString appendString:reason];
    [infoString appendString:@"\ncall stack info: "];
    [infoString appendString:[array description]];
    [infoString appendString:@"\n\n\n"];
    
    NSData *data = [infoString dataUsingEncoding:NSUTF8StringEncoding]; // 2016.03.28 20.30.01
    
    path = pathForCrashLogFileName([fileName stringByAppendingString:@".log"]);
    [data writeToFile:path atomically:YES];
    
    NSLog(@"Record OK.");
}



#pragma mark -
@interface CrashHandle () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIViewController *bugListNav;

@end

@implementation CrashHandle

+ (void)openCrashLogRecord
{
    if (!handle) {
        handle = [CrashHandle new];
    }
    [handle setCrashRecord];
}

+ (void)showCrashLogList
{
    if (!handle.bugListNav) {
        UIViewController *vc = [NSClassFromString(@"CrashListController") new];
        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
        vc.title = @"Bug List";
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.navigationBar.tintColor = [UIColor whiteColor];
        handle.bugListNav = nav;
    }
    
    UIViewController *topViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [topViewController presentViewController:handle.bugListNav animated:YES completion:nil];
}

+ (void)closeAction
{
    [handle.bugListNav dismissViewControllerAnimated:YES completion:nil];
}


+ (void)clearCrashLog
{
    NSString *path = pathForCrashLogFileName(nil);
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error) {
        NSLog(@"清空缓存失败: %@", error);
    } else {
        NSLog(@"已清空缓存");
    }
}

- (void)setCrashRecord
{
    NSLog(@"%@", NSHomeDirectory());
    
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    [window addGestureRecognizer:tap];
    tap.delegate = self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    self.lastTouch = touch;
    return NO;
}

@end
