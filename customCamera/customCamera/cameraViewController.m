//
//  cameraViewController.m
//  customCamera
//
//  Created by David on 16/7/24.
//  Copyright © 2016年 detu. All rights reserved.
//

#import "cameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "albumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


typedef void (^PropertyChangeBlock)(AVCaptureDevice *captureDevice);


typedef void (^hahhhah)(int a);
@interface cameraViewController ()<UIGestureRecognizerDelegate, AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureInput *videoInput;;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;//皂片输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;//AV输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//预览
@property (nonatomic, strong) UIButton *toggleButton;//切换镜头
@property (nonatomic, strong) UIButton *shutterButton;//快门
@property (nonatomic, strong) UIButton *albumBtn;//相册
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *recordingLabel;//录制中
@property (nonatomic, strong) UIView *cameraShowView;//预览图层的底
@property (nonatomic, strong) AVCaptureDevice *currentDevice;//当前device
@property (nonatomic, strong) UIButton *modeSetBtn;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIImageView *focusCursor;//聚焦矩形
@property (nonatomic, assign) CGFloat beginGestureScale;//开始的缩放scale
@property (nonatomic, assign) CGFloat effectiveScale;//最终的scale
@property (nonatomic, assign, getter=isRecordMode) BOOL recordMode;//是否是录像模式
@end

@implementation cameraViewController

- (instancetype)init {
    
    if (self = [super init]) {
        self.session = [AVCaptureSession new];
        if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {//设置分辨率
            [self.session canSetSessionPreset:AVCaptureSessionPreset1280x720];
        }
        
        self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera]  error:nil];
        self.currentDevice = [self backCamera];
        AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];//添加麦克风
        NSError *error=nil;
        
       
        AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];//音频出入
        self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];//视频输出
        self.stillImageOutput = [AVCaptureStillImageOutput new];
        self.cameraShowView = [UIView new];
        self.cameraShowView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-200);
        [self.view addSubview:self.cameraShowView];
        [self addGenstureRecognizer];//添加手势
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil] ;//输出格式
        [self.stillImageOutput setOutputSettings:outputSettings];//给对话添加设备
        if ([self.session canAddInput:self.videoInput]) {
            [self.session addInput:self.videoInput];
            [self.session addInput:audioCaptureDeviceInput];
            AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([captureConnection isVideoStabilizationSupported ]) {
                captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
            }
        }
        
        if ([self.session canAddOutput:self.stillImageOutput]) {
            [self.session addOutput:self.stillImageOutput];
            [self.session addOutput:self.captureMovieFileOutput];
        }
        
    }
    
    
    return self;

}





- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIButton *shutterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.shutterButton = shutterBtn;
        shutterBtn.center = CGPointMake(ScreenW/2, ScreenH-70);
        [shutterBtn setImage:[UIImage imageNamed:@"shutter1"] forState:UIControlStateNormal];
        [shutterBtn setImage:[UIImage imageNamed:@"shutter2"] forState:UIControlStateSelected];
        [self.view addSubview:shutterBtn];
        [shutterBtn addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchDown];
        
        UIButton *toggleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        self.toggleButton = toggleBtn;
        toggleBtn.center = CGPointMake(ScreenW/2, ScreenH-170);
        toggleBtn.layer.cornerRadius = 14;
        toggleBtn.layer.borderWidth = 1;
        toggleBtn.layer.masksToBounds = YES;
        toggleBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [toggleBtn setImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
        [self.view addSubview:toggleBtn];
        [toggleBtn addTarget:self action:@selector(toggleCamera) forControlEvents:UIControlEventTouchDown];
        
        self.recordMode = NO;
        UIButton *modeSetBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        modeSetBtn.center = CGPointMake(ScreenW*3/4, ScreenH-70);
        _modeSetBtn = modeSetBtn;
        [modeSetBtn setImage:[UIImage imageNamed:@"tovideo"] forState:UIControlStateNormal];
        [modeSetBtn setImage:[UIImage imageNamed:@"tocamera"] forState:UIControlStateSelected];
        [self.view addSubview:modeSetBtn];
        [modeSetBtn addTarget:self action:@selector(setShutterMode) forControlEvents:UIControlEventTouchDown];
        
        
        UIButton *albumBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.albumBtn = albumBtn;
        albumBtn.center = CGPointMake(ScreenW/4, ScreenH-70);
        [albumBtn setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
        [self.view addSubview:albumBtn];
        [albumBtn addTarget:self action:@selector(toAlbum) forControlEvents:UIControlEventTouchDown];
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenH-200, 50, 50)];
        self.backBtn = backBtn;
        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [self.view addSubview:backBtn];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];

        
        UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW-50, ScreenH-200, 50, 50)];
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        device.flashMode = AVCaptureFlashModeOff;
         [device unlockForConfiguration];
        [flashBtn setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
        [self.view addSubview:flashBtn];
        [flashBtn addTarget:self action:@selector(setFlash) forControlEvents:UIControlEventTouchDown];
        self.flashBtn = flashBtn;
        
        self.recordingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        self.recordingLabel.center = CGPointMake(ScreenW/2, ScreenH-130);
        self.recordingLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:self.recordingLabel];
        self.recordingLabel.text = @"录制中。。。";
        self.recordingLabel.textAlignment = NSTextAlignmentCenter;
        self.recordingLabel.alpha = 0;
    });
    
   
}


- (void)toAlbum {
    
    [self presentViewController:[albumViewController new] animated:YES completion:nil];
    
}
- (void)setFlash {
    
    __weak typeof(self) weakSelf = self;
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        AVCaptureDevice *device = captureDevice;
        if ([device hasFlash]) {
            if (device.flashMode == AVCaptureFlashModeOff) {
                device.flashMode = AVCaptureFlashModeOn;
                [weakSelf.flashBtn setImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
            } else if (device.flashMode == AVCaptureFlashModeOn) {
                device.flashMode = AVCaptureFlashModeAuto;
                [weakSelf.flashBtn setImage:[UIImage imageNamed:@"flashAuto"] forState:UIControlStateNormal];
            } else if (device.flashMode == AVCaptureFlashModeAuto) {
                device.flashMode = AVCaptureFlashModeOff;
                [weakSelf.flashBtn setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
            }
            
        } else {
            
            NSLog(@"设备不支持闪光灯");
        }
    }];
    
    
}
- (void)back {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];

    if (self.previewLayer == nil) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];;
        UIView *view = self.cameraShowView;
        CALayer *viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];
        CGRect bounds = view.bounds;
        [self.previewLayer setFrame:bounds];
        
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        UIImageView *focusCursor = [UIImageView new];
        self.focusCursor = focusCursor;
        focusCursor.frame = CGRectMake(0, 0, 50, 50);
        [view addSubview:focusCursor];
        focusCursor.layer.borderColor = [UIColor orangeColor].CGColor;
        focusCursor.layer.borderWidth = 1;
        focusCursor.alpha = 0;
        
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}


- (void)setShutterMode {
    _recordMode = !_recordMode;
    _modeSetBtn.selected = !_modeSetBtn.selected;
    _shutterButton.selected = !_shutterButton.selected;
    
}

- (void) shutterCamera
{
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    if (!self.isRecordMode) { //拍照模式
        [videoConnection setVideoScaleAndCropFactor:self.effectiveScale>0 ? :1];
        self.previewLayer.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.previewLayer.hidden = NO;
        });
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer == NULL) {
                return;
            }
            NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage * image = [UIImage imageWithData:imageData];
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            NSLog(@"image size = %@",NSStringFromCGSize(image.size));
        }];
    } else {
        if (![self.captureMovieFileOutput isRecording]) {
           
            NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
            NSLog(@"save path is :%@",outputFielPath);
            NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
            [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        }
        else{
            [self.captureMovieFileOutput stopRecording];//停止录制
            
                    self.recordingLabel.text = @"录制完成";
                    [UIView animateWithDuration:1.0
                                     animations:^{
                                         self.recordingLabel.alpha = 0;
                                     }
                                     completion:^(BOOL finished) {
                                         self.recordingLabel.text = @"录制中。。。";
                                     }];
        }
        
    }
    
    
}


- (void)toggleCamera {
    
   
    
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [self.currentDevice position];
        
        if (position == AVCaptureDevicePositionBack){
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
            self.currentDevice = [self frontCamera];
        }else if (position == AVCaptureDevicePositionFront){
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
            self.currentDevice = [self backCamera];

        } else
            return;
        
        if (newVideoInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
    
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    animation.toValue = [ NSValue valueWithCATransform3D:
                         CATransform3DMakeRotation(M_PI, 0, 0.5, 0) ];
    animation.duration = 0.5;
    animation.repeatCount = 1;
    UIGraphicsEndImageContext();
    [self.cameraShowView.layer addAnimation:animation forKey:nil];
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *view = [[UIVisualEffectView alloc]initWithEffect:beffect];
    
    view.frame = self.cameraShowView.frame;
    
    [self.cameraShowView addSubview:view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view removeFromSuperview];
    });
    
  
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition *)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == (int)position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:(AVCaptureDevicePosition *)AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:(AVCaptureDevicePosition *)AVCaptureDevicePositionBack];
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    
    
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 *  添加手势，点按时聚焦,缩放调节焦距
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.cameraShowView addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    [self.cameraShowView addGestureRecognizer:pinchGesture];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.cameraShowView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        CGFloat maxScaleAndCropFactor = 4.8;
        
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];  

        if (!self.beginGestureScale) {
            self.beginGestureScale = self.effectiveScale;
        }
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.cameraShowView];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= self.currentDevice;
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.5 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
        
    }];
}


- (void)dealloc {
    NSLog(@"cameraViewController dealloc");
}

#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
    self.toggleButton.hidden = self.backBtn.hidden = self.albumBtn.hidden = self.flashBtn.hidden = self.modeSetBtn.hidden = YES;
    self.recordingLabel.alpha = 1;
    
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");
    self.toggleButton.hidden = self.backBtn.hidden = self.albumBtn.hidden = self.flashBtn.hidden = self.modeSetBtn.hidden = NO;
    self.recordingLabel.alpha = 0;
    
    //视频录入完成之后在后台将视频存储到相簿
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"保存视频到相簿过程中发生错误，错误信息：%@",error.localizedDescription);
        }
      
        NSLog(@"成功保存视频到相簿.");
    }];

    
}

#pragma mark - 通知
/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    NSLog(@"设备已连接...");
}
/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    NSLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    NSLog(@"会话发生错误.");
}

@end
