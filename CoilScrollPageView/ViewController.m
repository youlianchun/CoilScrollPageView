//
//  ViewController.m
//  CoilScrollPageView
//
//  Created by YLCHUN on 2016/12/11.
//  Copyright © 2016年 YLCHUN. All rights reserved.
//

#import "ViewController.h"
#import "CoilScrollPageView.h"

@interface ViewController ()<CoilScrollPageViewDataSource, CoilScrollPageViewDelegate>
@property (nonatomic) CoilScrollPageView *pageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageView = [[CoilScrollPageView alloc] initWithFrame:self.view.bounds];
    self.pageView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
    self.pageView.horizontalScrolling = YES;
    self.pageView.coilScrolling = YES;
    self.pageView.dataSource = self;
    self.pageView.delegate = self;
//    [self.view addSubview:self.pageView];
    [self.view insertSubview:self.pageView atIndex:0];
    [self.pageView reloadData];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)lastAction:(UIButton *)sender {
    [self.pageView scrollToLastPageWithAnimated:YES];
}
- (IBAction)nextAction:(UIButton *)sender {
    [self.pageView scrollToNextPageWithAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfPageInScrollPageView:(CoilScrollPageView*)scrollPageView {
    return 4;
}
-(CGFloat)cellSpaceInScrollPageView:(CoilScrollPageView *)scrollPageView {
    return 40;
}
- (void)scrollPageView:(CoilScrollPageView*)scrollPageView cellContentView:(UIContentView*)contentView atPageIndex:(NSUInteger)pageIndex isReuse:(BOOL)isReuse {
//    contentView.backgroundColor = [UIColor whiteColor];
    if (!isReuse) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:contentView.bounds];
        [contentView addSubview:imageView];
        UIView *v = imageView.superview;
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"h%ld.jpg",pageIndex]];
        imageView.image = img;
    }
}

@end
