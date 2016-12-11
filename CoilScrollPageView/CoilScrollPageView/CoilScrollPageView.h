//
//  CoilScrollPageView.h
//  CoilScrollPageView
//
//  Created by YLCHUN on 2016/12/11.
//  Copyright © 2016年 YLCHUN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIContentView.h"

@class CoilScrollPageView;

@protocol CoilScrollPageViewDataSource<NSObject>

- (NSUInteger)numberOfPageInScrollPageView:(CoilScrollPageView*)scrollPageView;

- (void)scrollPageView:(CoilScrollPageView*)scrollPageView cellContentView:(UIContentView*)contentView atPageIndex:(NSUInteger)pageIndex isReuse:(BOOL)isReuse;

@optional

- (CGFloat)cellSpaceInScrollPageView:(CoilScrollPageView*)scrollPageView;

@end

@protocol CoilScrollPageViewDelegate <NSObject>

@optional
- (void)scrollPageView:(CoilScrollPageView *)scrollPageView didSelectPageAtIndex:(NSUInteger)pgeIndex;

- (void)scrollPageView:(CoilScrollPageView*)scrollPageView willDisplayPage:(UIContentView *)contentView atPageIndex:(NSUInteger )pageIndex;
- (void)scrollPageView:(CoilScrollPageView*)scrollPageView didEndDisplayingPage:(UIContentView *)contentView atPageIndex:(NSUInteger )pageIndex;
@end


@interface CoilScrollPageView : UIView

@property (nonatomic, assign)BOOL coilScrolling;//循环滚动
@property (nonatomic, assign)BOOL horizontalScrolling;//水平滚动
@property (nonatomic, readonly) NSUInteger currentPageIndex;

@property (nonatomic, weak) id<CoilScrollPageViewDataSource>dataSource;
@property (nonatomic, weak) id<CoilScrollPageViewDelegate>delegate;

- (void)reloadData;
- (void)scrollToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated;

- (void)scrollToLastPageWithAnimated:(BOOL)animated;
- (void)scrollToNextPageWithAnimated:(BOOL)animated;
@end
