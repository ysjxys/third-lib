//
//  CustomViewController.m
//  officialDemoNavi
//
//  Created by AutoNavi on 15/7/1.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "CustomViewController.h"

@interface CustomViewController () <AMapNaviViewControllerDelegate>

@property (nonatomic, strong) AMapNaviViewController *naviViewController;

@property (nonatomic, strong) AMapNaviPoint* startPoint;
@property (nonatomic, strong) AMapNaviPoint* endPoint;

@property (nonatomic, strong) UILabel *naviInfoLabel;

@end

@implementation CustomViewController

#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _startPoint = [AMapNaviPoint locationWithLatitude:39.989614 longitude:116.481763];
        _endPoint   = [AMapNaviPoint locationWithLatitude:39.983456 longitude:116.315495];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNaviViewController];
    
    [self configSubViews];
    
    [self configNaviViewController];
}

#pragma mark - Init & Construct

- (void)initNaviViewController
{
    if (_naviViewController == nil)
    {
        _naviViewController = [[AMapNaviViewController alloc] initWithMapView:self.mapView delegate:self];
    }
}

- (void)configSubViews
{
    UILabel *startPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 20)];
    
    startPointLabel.textAlignment = NSTextAlignmentCenter;
    startPointLabel.font = [UIFont systemFontOfSize:14];
    startPointLabel.text = [NSString stringWithFormat:@"起 点：%f, %f", _startPoint.latitude, _startPoint.longitude];
    
    [self.view addSubview:startPointLabel];
    
    UILabel *endPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 20)];
    
    endPointLabel.textAlignment = NSTextAlignmentCenter;
    endPointLabel.font = [UIFont systemFontOfSize:14];
    endPointLabel.text = [NSString stringWithFormat:@"终 点：%f, %f", _endPoint.latitude, _endPoint.longitude];
    
    [self.view addSubview:endPointLabel];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    startBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    startBtn.layer.borderWidth  = 0.5;
    startBtn.layer.cornerRadius = 5;
    
    [startBtn setFrame:CGRectMake(60, 160, 200, 30)];
    [startBtn setTitle:@"开始导航" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    
    [startBtn addTarget:self action:@selector(startGPSNavi:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:startBtn];
}

- (void)configNaviViewController
{
    [_naviViewController setShowUIElements:NO];
    
    _naviInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 300, 170)];
    _naviInfoLabel.textAlignment = NSTextAlignmentCenter;
    _naviInfoLabel.font = [UIFont systemFontOfSize:14];
    _naviInfoLabel.numberOfLines = 10;
    
    [_naviViewController.view addSubview:_naviInfoLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backButton.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    backButton.layer.borderWidth  = 0.5;
    backButton.layer.cornerRadius = 5;
    
    [backButton setFrame:CGRectMake(60, 210, 200, 30)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor whiteColor]];
    backButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_naviViewController.view addSubview:backButton];
}

#pragma mark - Button Action

- (void)startGPSNavi:(id)sender
{
    // 算路
    [self calculateRoute];
}

- (void)calculateRoute
{
    NSArray *startPoints = @[_startPoint];
    NSArray *endPoints   = @[_endPoint];
    
    [self.naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:0];
}

- (void)backButtonAction
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.iFlySpeechSynthesizer stopSpeaking];
    });
    
    [self.naviManager stopNavi];
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}

#pragma mark - AMapNaviManager Delegate

- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
{
    [super naviManager:naviManager didPresentNaviViewController:naviViewController];
    
    [self.naviManager startEmulatorNavi];
}

- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    [super naviManagerOnCalculateRouteSuccess:naviManager];
    
    [self.naviManager presentNaviViewController:self.naviViewController animated:YES];
}

- (void)naviManager:(AMapNaviManager *)naviManager didUpdateNaviInfo:(AMapNaviInfo *)naviInfo
{
    [super naviManager:naviManager didUpdateNaviInfo:naviInfo];
    
    [_naviInfoLabel setText:[NSString stringWithFormat:@"%@", naviInfo]];
}

#pragma mark - AManNaviViewController Delegate

- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.iFlySpeechSynthesizer stopSpeaking];
    });
    
    [self.naviManager stopNavi];
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}

@end
