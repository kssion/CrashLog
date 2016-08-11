//
//  CrashDetailController.m
//  CrashLogRecord
//
//  Created by Chance on 16/3/28.
//  Copyright © 2016年 Chance. All rights reserved.
//

#import "CrashDetailController.h"

@interface CrashDetailController () <UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) UIImageView *screenImageView;

@end

@implementation CrashDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData *data = [NSData dataWithContentsOfFile:_filePath];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.textView.text = string;
    
    NSString *name = [[self.filePath substringToIndex:_filePath.length - 4] stringByAppendingString:@".jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:name];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    float height = rect.size.height / 2 + 30;
    rect.origin.y = -height + 15;
    rect.size.height = height - 30;
    self.imageView = [[UIImageView alloc] initWithFrame:rect];
    self.imageView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.image = image;
    
    self.textView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
    self.textView.contentOffset = CGPointMake(0, -height);
    [self.textView addSubview:_imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureShow:)];
    [self.imageView addGestureRecognizer:tap];
    
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    self.scrollView.delegate = self;
    
    self.screenImageView = [[UIImageView alloc] init];
    self.screenImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.screenImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.screenImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapHidden = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHidden:)];
    [self.screenImageView addGestureRecognizer:tapHidden];
    
    [self.scrollView addSubview:_screenImageView];
    
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _screenImageView;
}

- (void)tapGestureShow:(UITapGestureRecognizer *)tap
{
    self.originFrame = [self.imageView.superview convertRect:_imageView.frame toView:nil];
    self.screenImageView.frame = _originFrame;
    self.screenImageView.image = _imageView.image;
    self.screenImageView.hidden = NO;
    [self.view.window addSubview:_scrollView];
    
    __weak __typeof(self) _self = self;
    [UIView animateWithDuration:.25 delay:0 options:7<<16 animations:^{
        _self.screenImageView.frame = [[UIScreen mainScreen] bounds];
        self.scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    } completion:nil];
    
}

- (void)tapGestureHidden:(UITapGestureRecognizer *)tap
{
    __weak __typeof(self) _self = self;
    [UIView animateWithDuration:.25 delay:0 options:7<<16 animations:^{
        _self.screenImageView.frame = _self.originFrame;
        self.scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [_self.scrollView removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
