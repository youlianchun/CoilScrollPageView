//
//  UIContentViewCell.m
//  PageSwitchView
//
//  Created by YLCHUN on 16/12/7.
//  Copyright © 2016年 ylchun. All rights reserved.
//

#import "UIContentViewCell.h"

@interface UIContentViewCell ()
{
    UIContentView *_contentView;
}
//@property (nonatomic) UIContentView *view;
@end

@implementation UIContentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UIContentView *)contentView {
    if (!_contentView) {
        _contentView = [[UIContentView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.opaque = NO;
        [self addSubview:_contentView];
        [[super contentView] setHidden:YES];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    return _contentView;
}

@end
