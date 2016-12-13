//
//  UIContentView.m
//  PageSwitchView
//
//  Created by YLCHUN on 16/11/30.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "UIContentView.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark - _UIContentView
@interface _UIContentView : UIView
@end
@implementation _UIContentView
@end

#pragma mark -
#pragma mark - UIView(UIContentView)
@implementation UIView(UIContentView)
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(superview);
        SEL swizzledSelector = @selector(superview_contentView);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}
-(UIView *)superview_contentView {
    UIView *superview = [self superview_contentView];
    if ([superview isKindOfClass:[_UIContentView class]]) {
        return superview.superview;
    }else {
        return superview;
    }
}
@end

#pragma mark -
#pragma mark - UIContentView
@interface UIContentView ()
@property (nonatomic, retain) UIView *contentView;
@end

@implementation UIContentView

-(NSArray<UIView *> *)subviews {
    return self.contentView.subviews;
}

-(void)addSubview:(UIView *)view {
    [self.contentView addSubview:view];
}

-(void)clearSubviews {
    [self.contentView removeFromSuperview];
    self.contentView = nil;
}

-(UIView *)contentView {
    if (!_contentView) {
        _contentView = [[_UIContentView alloc]init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.opaque = NO;
        [super addSubview:_contentView];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    return _contentView;
}

@end
