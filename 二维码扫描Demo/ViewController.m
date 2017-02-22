//
//  ViewController.m
//  二维码扫描Demo
//
//  Created by SunGuoYan on 17/2/10.
//  Copyright © 2017年 SunGuoYan. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#define screenH [UIScreen mainScreen].bounds.size.height
#define screenW [UIScreen mainScreen].bounds.size.width
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>

//扫描模块
@property(nonatomic,strong)AVCaptureDevice *device;
@property(nonatomic,strong)AVCaptureDeviceInput *input;
@property(nonatomic,strong)AVCaptureMetadataOutput *output;
@property(nonatomic,strong)AVCaptureSession *session;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *preview;

//图片动画模块
@property(nonatomic,strong)UIView *scanView;
@property(nonatomic,strong)UIImageView *scanRectView;
@property(nonatomic,strong)UIImageView *scanLineImageView;

//用于展示扫描结果
@property(nonatomic,strong)UILabel *resultLab;
@end

@implementation ViewController
/*
 需要真机测试
 勾选自动管理证书 选择孙国焱team就可以真机运行
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self judgeCamera];
    
    [self getDevices];
    
    //1.获取摄像设备
    self.device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.输入流
    self.input=[AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    
    //3.输出流
    self.output=[[AVCaptureMetadataOutput alloc]init];
    //设置扫描区域:rect的四个值的范围都是(0~1),按比例计算
    //和平常的rect不太一样
    //x,y调换,width和height调换
    self.output.rectOfInterest = CGRectMake(0.33, 0.2, 0.33, 0.6);//0.6, 0.33
    //设置代理,在主线程中刷新
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //4.初始化链接对象
    self.session=[[AVCaptureSession alloc]init];
    //高质量采集率
    [self.session setSessionPreset:(screenH<500)?AVCaptureSessionPreset640x480:AVCaptureSessionPresetHigh];
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    
    //设置扫描支持的编码格式
    //以下两行代码只能放在4之后，不能放在4的前面
    self.output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode];
    //self.output.rectOfInterest=CGRectMake(0.12, 0.12, 0.5, 0.75);
    
    //5.
    self.preview=[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.frame=[UIScreen mainScreen].bounds;
    
    //注意这里previews要放在canRectView的下面，否者扫描的线条出不来
    [self.view.layer insertSublayer:self.preview atIndex:0];
   // [self.view.layer addSublayer:self.preview];
    
    //6.
    [self.session startRunning];
    
    //设置扫描的图片
    [self setScanImages];
    //设置扫描的图片 的动画
    [self startScanLineImageViewAnimation];
    
    self.resultLab=[[UILabel alloc]initWithFrame:CGRectMake(0, screenH-60, screenW, 50)];
    self.resultLab.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:self.resultLab];
}
-(void)setScanImages{
    //1.背景
    self.scanView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, screenW, screenH)];
    self.scanView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.scanView];
    //2.扫描框
    self.scanRectView=[[UIImageView alloc]initWithFrame:CGRectMake(100, 200, screenW/2, screenW/2)];
    self.scanRectView.center=CGPointMake(screenW/2, screenH/2);
    self.scanRectView.image=[UIImage imageNamed:@"sacn_frame"];
    [self.scanView addSubview:self.scanRectView];
    //3.扫描线
    self.scanLineImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, screenW/2-20, 2)];
    self.scanLineImageView.image=[UIImage imageNamed:@"scan_line"];
    [self.scanRectView addSubview:self.scanLineImageView];
}

-(void)startScanLineImageViewAnimation{
    [UIView animateWithDuration:2.4 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        //注意父视图是scanRectView
        self.scanLineImageView.frame=CGRectMake(10, screenW/2-10, screenW/2-20, 2);
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark --- 扫描结果的回调函数
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count==0) {
        return;
    }
    if (metadataObjects.count>0) {
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        
        NSLog(@"%@",metadataObject.stringValue);
        
        self.resultLab.text=metadataObject.stringValue;
        self.resultLab.backgroundColor=[UIColor greenColor];
    }
}



-(void)getDevices{
    NSArray *devices=[AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        NSLog(@"Device name:%@",[device localizedName]);
        if ([device hasMediaType:AVMediaTypeVideo]) {
            // AVCaptureDevicePosition
            if ([device position]== AVCaptureDevicePositionBack) {
                NSLog(@"Back");
            }else{
                NSLog(@"font");
            }
        }
    }
}
-(void)judgeCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO) {
        NSLog(@"no camera");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
