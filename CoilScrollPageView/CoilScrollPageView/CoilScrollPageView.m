//
//  CoilScrollPageView.m
//  CoilScrollPageView
//
//  Created by YLCHUN on 2016/12/11.
//  Copyright © 2016年 YLCHUN. All rights reserved.
//

#import "CoilScrollPageView.h"
#import "UIContentViewCell.h"
#pragma mark -
#pragma mark - _CoilTableView
@interface _CoilTableView : UITableView
@property (nonatomic, copy) void(^layoutSubviewsCallBack)();
//@property (nonatomic, copy) void(^setContentOffsetCallBack)();

@end

@implementation _CoilTableView
- (void)layoutSubviews {
    if (self.layoutSubviewsCallBack) {
        self.layoutSubviewsCallBack();
    }
    [super layoutSubviews];
}
//-(void)setContentOffset:(CGPoint)contentOffset {
//    [super setContentOffset:contentOffset];
//    if (self.setContentOffsetCallBack) {
//        self.setContentOffsetCallBack();
//    }
//}
@end
#pragma mark -
#pragma mark - CoilScrollPageView
@interface CoilScrollPageView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) _CoilTableView *tableView;
@property (nonatomic, strong) NSLayoutConstraint *tableViewV_CW;//垂直
@property (nonatomic, strong) NSLayoutConstraint *tableViewV_CH;
@property (nonatomic, strong) NSLayoutConstraint *tableViewH_CW;//水平
@property (nonatomic, strong) NSLayoutConstraint *tableViewH_CH;

@property (nonatomic, retain) UIView *panelView;
@property (nonatomic, strong) NSLayoutConstraint *panelView_CT;
@property (nonatomic, strong) NSLayoutConstraint *panelView_CB;
@property (nonatomic, strong) NSLayoutConstraint *panelView_CL;
@property (nonatomic, strong) NSLayoutConstraint *panelView_CR;

@property (nonatomic, assign) CGFloat cellSpace_inner;

@property (nonatomic, assign) NSUInteger cellCount_inner;
@property (nonatomic, assign) NSUInteger cellCount_outer;

@property (nonatomic, readonly) NSUInteger currentPageIndex_inner;
@property (nonatomic, readonly) NSUInteger currentPageIndex_outer;


@property (nonatomic, assign) BOOL pageChange;
@property (nonatomic, assign) BOOL pageChange_tag;

@end

@implementation CoilScrollPageView

- (void)customIntitialization {
    self.coilScrolling = NO;
    _horizontalScrolling = NO;
    _cellSpace_inner = 0;
    self.pageChange = NO;
    self.pageChange_tag = NO;
}

- (NSUInteger)morphedIndexForIndexPath:(NSIndexPath*)indexPath actualCellCount:(NSUInteger)cellCount{
    return self.coilScrolling ? indexPath.section % cellCount : indexPath.section;
}

- (void)resetTableViewContentOffsetIfNeeded {
    if(!(self.coilScrolling)) {
        return;
    }
    CGPoint contentOffset  = self.tableView.contentOffset;
    CGFloat boundsh=self.tableView.bounds.size.height;
    //滚动到顶部
    if( contentOffset.y <= 0.0 ) {
        if (self.pageChange_tag) {//第一次不设置lastPage
            self.pageChange = YES;
        }
        self.pageChange_tag = YES;
        contentOffset.y = self.tableView.contentSize.height/3.0f;//将第一个cell开始位置偏移量往下挪动三分之一
    }
    else if( contentOffset.y >= ( self.tableView.contentSize.height - boundsh) ) {//滚动到底部
        //将第一个cell开始位置偏移量往上挪动三分之一
        self.pageChange = YES;
        contentOffset.y = self.tableView.contentSize.height/3.0f-boundsh;
    }else {
        self.pageChange = NO;
    }
    [self.tableView setContentOffset: contentOffset];
}

-(void)tableViewLayoutSubviews {
    [self resetTableViewContentOffsetIfNeeded];
}
//-(void)tableViewSetContentOffset {
//    NSUInteger n = self.tableView.contentOffset.y / self.tableView.bounds.size.height;
//    CGFloat offset = self.tableView.contentOffset.y - self.tableView.bounds.size.height*n;
//    if (offset <= 0.0000001) {
//        printf("changePage\n");
//    }
//}

#pragma mark - Get Set

-(UIView *)panelView {
    if (!_panelView) {
        _panelView = [[UIView alloc]init];
        _panelView.backgroundColor = [UIColor grayColor];
        _panelView.hidden = YES;
        [self insertSubview:_panelView atIndex:0];
        _panelView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.panelView_CT = [NSLayoutConstraint constraintWithItem:_panelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        self.panelView_CB = [NSLayoutConstraint constraintWithItem:_panelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        self.panelView_CL = [NSLayoutConstraint constraintWithItem:_panelView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        self.panelView_CR = [NSLayoutConstraint constraintWithItem:_panelView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        
        [self addConstraint:self.panelView_CT];
        [self addConstraint:self.panelView_CB];
        [self addConstraint:self.panelView_CL];
        [self addConstraint:self.panelView_CR];
        [self updatePanelViewLayputWithSpace:self.cellSpace_inner isH:self.horizontalScrolling];
    }
    return _panelView;
}

-(_CoilTableView *)tableView {
    if (!_tableView) {
        _tableView = [[_CoilTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.pagingEnabled = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = _horizontalScrolling ? self.bounds.size.width : self.bounds.size.height;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        __weak typeof(self) wself = self;
        _tableView.layoutSubviewsCallBack = ^(){
            [wself tableViewLayoutSubviews];
        };
//        _tableView.setContentOffsetCallBack = ^(){
//            [wself tableViewSetContentOffset];
//        };
        [self addSubview:_tableView];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
        
        self.tableViewH_CH = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.panelView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        self.tableViewH_CW = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.panelView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        
        self.tableViewV_CH = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.panelView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        self.tableViewV_CW = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.panelView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        
        [self addConstraint:self.tableViewV_CW];
        [self addConstraint:self.tableViewV_CH];
        
        [self addConstraint:self.tableViewH_CW];
        [self addConstraint:self.tableViewH_CH];
        
        self.tableViewV_CW.active = !_horizontalScrolling;
        self.tableViewV_CH.active = !_horizontalScrolling;
        self.tableViewH_CW.active = _horizontalScrolling;
        self.tableViewH_CH.active = _horizontalScrolling;
    }
    return _tableView;
}

-(void)setHorizontalScrolling:(BOOL)horizontalScrolling {
    if (_horizontalScrolling == horizontalScrolling) {
        return;
    }
    _horizontalScrolling = horizontalScrolling;
    self.tableViewV_CW.active = !_horizontalScrolling;
    self.tableViewV_CH.active = !_horizontalScrolling;
    self.tableViewH_CW.active = _horizontalScrolling;
    self.tableViewH_CH.active = _horizontalScrolling;
    self.tableView.transform = _horizontalScrolling ? CGAffineTransformMakeRotation(M_PI/-2) : CGAffineTransformIdentity;
    [self updatePanelViewLayputWithSpace:_cellSpace_inner isH:_horizontalScrolling];
    self.tableView.rowHeight = _horizontalScrolling ? self.bounds.size.width : self.bounds.size.height;
}

-(void)setCellSpace_inner:(CGFloat)cellSpace_inner {
    _cellSpace_inner = cellSpace_inner;
    [self updatePanelViewLayputWithSpace:_cellSpace_inner isH:self.horizontalScrolling];
}

-(NSUInteger)currentPageIndex_inner {
    if (self.horizontalScrolling) {
        return (self.tableView.contentOffset.y+CGRectGetHeight(self.tableView.bounds)/2.0)/CGRectGetHeight(self.tableView.bounds);
    }else {
        return (self.tableView.contentOffset.y+CGRectGetWidth(self.tableView.bounds)/2.0)/CGRectGetWidth(self.tableView.bounds);
    }
}

-(NSUInteger)currentPageIndex_outer {
    return self.coilScrolling ? self.currentPageIndex_inner % self.cellCount_outer : self.currentPageIndex_inner;
}

-(NSUInteger)currentPageIndex {
    return self.currentPageIndex_outer;
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellCount_inner;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSUInteger pageIndex = [self morphedIndexForIndexPath:indexPath actualCellCount:self.cellCount_outer];
    NSString *identifier = [NSString stringWithFormat:@"CoilScrollPageViewCellIdentifier_%ld",(long)pageIndex];
    BOOL isReuse = YES;
    UIContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UIContentViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        isReuse = NO;
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        cell.opaque = self.opaque;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.transform = CGAffineTransformIdentity;
    if (self.horizontalScrolling) {
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
    if (!self.pageChange) {//pageChange YES 时候是上一页跳转过来的同cell，不进执行代理，不限制时在切页时候会执行两次代理
        [self.dataSource scrollPageView:self cellContentView:cell.view atPageIndex:pageIndex isReuse:isReuse];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.cellSpace_inner;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.cellSpace_inner;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(scrollPageView:didSelectPageAtIndex:)]) {
        [self.delegate scrollPageView:self didSelectPageAtIndex:indexPath.section];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UIContentViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(scrollPageView:willDisplayPage:atPageIndex:)]) {
        [self.delegate scrollPageView:self willDisplayPage:cell.view atPageIndex:indexPath.section];
    }
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UIContentViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(scrollPageView:didEndDisplayingPage:atPageIndex:)]) {
        [self.delegate scrollPageView:self didEndDisplayingPage:cell.view atPageIndex:indexPath.section];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.hidden = YES;
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.hidden = YES;
}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    printf("scrollViewDidEndDecelerating\n");
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
//    printf("scrollViewDidEndScrollingAnimation\n");
//}

#pragma mark -

-(void)updatePanelViewLayputWithSpace:(CGFloat)space isH:(BOOL)isH {
    self.panelView_CT.constant = isH?0:-space;
    self.panelView_CB.constant = isH?0:space;
    self.panelView_CL.constant = isH?-space:0;
    self.panelView_CR.constant = isH?space:0;
}

- (void)reloadData {
    if ([self.dataSource respondsToSelector:@selector(cellSpaceInScrollPageView:)]) {
        NSUInteger cellSpace_outer = ABS([self.dataSource cellSpaceInScrollPageView:self]);
        self.cellSpace_inner = cellSpace_outer/2.0;
    }else {
        self.cellSpace_inner = 0;
    }
    self.cellCount_outer = [self.dataSource numberOfPageInScrollPageView:self];
    self.cellCount_inner = self.cellCount_outer * 3;
    [self.tableView reloadData];
}

- (void)scrollToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated {
    if (pageIndex >= self.cellCount_outer) {
        return;
    }
    
    NSInteger offset = pageIndex - self.currentPageIndex_outer;
    if (offset<0) {
        offset = -offset;
    }
    NSInteger interval1 = offset-1;//间隔1
    NSInteger interval2 = self.cellCount_outer-offset-1;//间隔2
    NSUInteger nIndex1_inner = 0;
    NSUInteger nIndex2_inner = 0;
    NSInteger n;
    n = self.currentPageIndex_inner + interval1 + 1;
    if (n%self.cellCount_outer == pageIndex) {
        nIndex1_inner = n;
    }
    n = self.currentPageIndex_inner - interval1 - 1;
    if (n%self.cellCount_outer == pageIndex) {
        nIndex1_inner = n;
    }
    n = self.currentPageIndex_inner + interval2 + 1;
    if (n%self.cellCount_outer == pageIndex) {
        nIndex2_inner = n;
    }
    n = self.currentPageIndex_inner - interval2 - 1;
    if (n%self.cellCount_outer == pageIndex) {
        nIndex2_inner = n;
    }

    NSInteger offset1 = nIndex1_inner - self.currentPageIndex_inner;
    if (offset1 < 0) {
        offset1 = -offset1;
    }
    NSInteger offset2 = nIndex2_inner - self.currentPageIndex_inner;
    if (offset2 < 0) {
        offset2 = -offset2;
    }
    NSUInteger nIndex_inner = nIndex1_inner;
    if (offset1 >= offset2) {
        nIndex_inner = nIndex2_inner;
    }
    
    [self.tableView  scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:nIndex_inner] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

- (void)scrollToLastPageWithAnimated:(BOOL)animated {
    NSInteger lastPage = (self.currentPageIndex_outer + self.cellCount_outer - 1)%self.cellCount_outer;
    [self scrollToPageAtIndex:lastPage animated:animated];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentPageIndex_inner-1];
//    [self.tableView  scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

- (void)scrollToNextPageWithAnimated:(BOOL)animated {
    NSInteger nextPage = (self.currentPageIndex_outer + 1)%self.cellCount_outer;
    [self scrollToPageAtIndex:nextPage animated:animated];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentPageIndex_inner+1];
//    [self.tableView  scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

@end
