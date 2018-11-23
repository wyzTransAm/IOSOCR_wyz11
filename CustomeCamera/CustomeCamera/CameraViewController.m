//
//  CameraViewController.m
//  CustomeCamera
//
//  Created by ios2chen on 2017/7/20.
//  Copyright © 2017年 ios2chen. All rights reserved.
//

#import "CameraViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AipOcrSdk/AipOcrSdk.h>
#import "Class/MPVolumeObserverPro.h"
#import "DetailViewController.h"
@interface CameraViewController ()<AVCaptureFileOutputRecordingDelegate,MPVolumeObserverProtocol>{
    NSMutableArray *mutArr;
    NSInteger pictureCount;
    NSMutableArray *Arr;
}
//500005249387
/*
 *  AVCaptureSession:它从物理设备得到数据流（比如摄像头和麦克风），输出到一个或
 *  多个目的地，它可以通过
 *  会话预设值(session preset)，来控制捕捉数据的格式和质量
 */
@property(nonatomic,strong)UIView *focusView;
@property (nonatomic, strong) AVCaptureSession *iSession;
//设备
@property (nonatomic, strong) AVCaptureDevice *iDevice;
//输入
@property (nonatomic, strong) AVCaptureDeviceInput *iInput;

//照片输出
@property (nonatomic, strong) AVCaptureStillImageOutput *iOutput;
//视频输出
@property (nonatomic, strong) AVCaptureMovieFileOutput *iMovieOutput;
//预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *iPreviewLayer;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;

@end

@implementation CameraViewController{
    // 默认的识别成功的回调
    void (^_successHandler)(id);
    // 默认的识别失败的回调
    void (^_failHandler)(NSError *);
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.iSession) {
        [self.iSession startRunning];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.iSession) {
        [self.iSession stopRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Arr = [[NSMutableArray alloc]init];
    NSString *thepath1 =@"http://10.194.51.14:8086/Checklist/CORCTracking/";
    NSString *thepath3 =@"/";
    NSString *thepath2 =@"_CurrentConfig.txt";
    
    NSString *thepath = [NSString stringWithFormat:@"%@%@%@%@%@",thepath1,[_Slot uppercaseString],thepath3,[_Slot uppercaseString],thepath2];
    
    //    NSString *content = [NSString stringWithContentsOfFile:thepath encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"NSString类方法读取的内容是：\n%@",content);
    
    
    NSURL *url =[NSURL URLWithString:thepath] ;
    NSError *err = nil;
    NSString *strFinal =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    if (err == nil)
    {
        NSLog(@"%@",strFinal);
    }
    else
    {
        NSLog(@"读取失败");
        NSLog(@"%@",err.localizedDescription);
    }
    
    
    
    NSArray *dataarr = [strFinal componentsSeparatedByString:@"\n"];
    for (NSString *str in dataarr) {
        for (int i=1; i<25; i++) {
            NSString *scount = [NSString stringWithFormat:@"%d%@",i,@".0"];
            BOOL isPre=[str hasPrefix:scount];
            if (isPre) {
                NSArray *temp = [str componentsSeparatedByString:@"\t"];
                [Arr addObject:temp];
            }
        }
    }
    
    
    
    
    
    
    
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;
    
    
    UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT_wyz/16*5, WIDTH_wyz, HEIGHT_wyz/8*3)];
    //边框宽
    myView.layer.borderWidth = 2;
    //边框颜色
    myView.layer.borderColor = [[UIColor redColor] CGColor];
    
    [self.view addSubview:myView];
    
    pictureCount = 0;
    [[AipOcrService shardService] authWithAK:@"FvKkxrLR4pG3KZh5i8VULiNU" andSK:@"iqP1XXlMTXktrgllsMfGen8KBAztSKfr"];
    mutArr = [NSMutableArray array];
    
    [MPVolumeObserverPro sharedInstance].delegate = self;
    [[MPVolumeObserverPro sharedInstance]startObserveVolumeChangeEvents];
    
    self.iSession = [[AVCaptureSession alloc]init];
    self.iSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in deviceArray) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.iDevice = device;
        }
    }
    
    //添加摄像头设备
    //对设备进行设置时需上锁，设置完再打开锁
    [self.iDevice lockForConfiguration:nil];
    if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [self.iDevice setFlashMode:AVCaptureFlashModeAuto];
    }
    if ([self.iDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self.iDevice setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([self.iDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        [self.iDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    }
    [self.iDevice unlockForConfiguration];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subjectAreaDidChange:)name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.iDevice];
    
    //添加音频设备
    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    
    self.iInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.iDevice error:nil];
    
    
    
    self.iOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *setDic = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    self.iOutput.outputSettings = setDic;
    
    self.iMovieOutput = [[AVCaptureMovieFileOutput alloc]init];
    
    if ([self.iSession canAddInput:self.iInput]) {
        [self.iSession addInput:self.iInput];
    }
    if ([self.iSession canAddOutput:self.iOutput]) {
        [self.iSession addOutput:self.iOutput];
    }
    if ([self.iSession canAddInput:audioInput]) {
        [self.iSession addInput:audioInput];
    }
    
    self.iPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.iSession];
    self.iPreviewLayer.orientation =UIDeviceOrientationLandscapeLeft;
    // self.iPreviewLayer.orientation =UIDeviceOrientationLandscapeRight;
    // self.iPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.iSession];
    [self.iPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.iPreviewLayer.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:self.iPreviewLayer atIndex:0];
    
    
    
    //  UIInterfaceOrientation curOrientation = self.interfaceOrientation;
    
    [self.iSession startRunning];
    
    
    //    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    //    [stillImageConnection setVideoOrientation:avcaptureOrientation];
}
- (void)subjectAreaDidChange:(NSNotification *)notification
{
    
    // CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake(500,500);
    //先进行判断是否支持控制对焦
    if (_iDevice.isFocusPointOfInterestSupported &&[_iDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        NSError *error =nil;
        //对cameraDevice进行操作前,需要先锁定,防止其他线程访问,
        [_iDevice lockForConfiguration:&error];
        [_iDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        [self focusAtPoint:focusPoint];
        //操作完成后,记得进行unlock。
        [_iDevice unlockForConfiguration];
    }
    
}
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([_iDevice lockForConfiguration:&error]) {
        if ([_iDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [_iDevice setFocusPointOfInterest:focusPoint];
            [_iDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        [_iDevice unlockForConfiguration];
    }
    /*
     * 下面是手触碰屏幕后对焦的效果
     */
    _focusView.center = point;
    _focusView.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            _focusView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _focusView.hidden = YES;
        }];
    }];
}

- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}
- (void)generalAccurateBasicOCR{
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextAccurateBasicFromImage:image
                                                           withOptions:options
                                                        successHandler:_successHandler
                                                           failHandler:_failHandler];
    }];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)configCallback {
    DetailViewController *dtVC = [[DetailViewController alloc]init];
    dtVC.CurrentArr = Arr;
    dtVC.resultArr = mutArr;
    
    pictureCount = 0;
    [self.navigationController pushViewController:dtVC animated:YES];
    //[mutArr  removeAllObjects];
}
-(void) volumeButtonCameraClick:(MPVolumeObserver *) button
{
    
    
    if ([self.takePhotoBtn.titleLabel.text isEqualToString:@"拍照"]) {
        if (pictureCount==13) {
            NSLog(@"取消");
            [self dismissViewControllerAnimated:YES completion:nil];
            [self configCallback];
        }else{
            pictureCount ++;//图片的张数
            
            AVCaptureConnection *connection = [self.iOutput connectionWithMediaType:AVMediaTypeVideo];
            if (!connection) {
                [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"Default"];
            } else{
                [self.iOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                    if (!imageDataSampleBuffer) {
                        [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"Default"];
                    } else{
                        [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"Success"];
                        
                        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                        UIImage *image = [UIImage imageWithData:imageData];
                        
                        CGImageRef sourceImageRef = [image CGImage];//将UIImage转换成CGImageRef
                        
                        CGSize imageSize = image.size;
                        CGRect rect;
                        rect =  CGRectMake(0,image.size.width/16*5, image.size.height,image.size.width/8*3 );
                        //  rect =  CGRectMake(0,image.size.width/16*7, image.size.height,image.size.width/8 );
                        
                        
                        //根据图片的大小计算出图片中间矩形区域的位置与大小
                        //                    if (imageSize.width > imageSize.height) {
                        //
                        //                              rect = CGRectMake(472.5,0,  135,1920);
                        //
                        //                    }else{
                        //                           rect = CGRectMake(472.5,0,  135,1920);
                        //                    }
                        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);//按照给定的矩形区域进行剪裁
                        UIImage *newImage = [UIImage imageWithCGImage:newImageRef] ;
                        
                        CGSize NewSize = CGSizeMake(100, 45);
                        UIGraphicsBeginImageContext(NewSize);
                        [newImage drawInRect:CGRectMake(0, 0, NewSize.width, NewSize.height)];
                        UIImage * newImage1 = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
                        [[AipOcrService shardService] detectTextAccurateBasicFromImage:newImage withOptions:options successHandler:^(id result) {
                            // 成功识别的后续逻辑
                            NSLog(@"%ld",pictureCount);
                            [mutArr addObject:result];
                        } failHandler:^(NSError *err) {
                            // 失败的后续逻辑
                            NSLog(@"失败");
                        }];
                        
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
                        //  UIImageWriteToSavedPhotosAlbum(newImage1, nil, nil, nil);
                    }
                }];
            }
        }
    } else if([self.takePhotoBtn.titleLabel.text isEqualToString:@"开始"]){
        [self.takePhotoBtn setTitle:@"结束" forState:UIControlStateNormal];
        AVCaptureConnection *connect = [self.iMovieOutput connectionWithMediaType:AVMediaTypeVideo];
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"]];
        if (![self.iMovieOutput isRecording]) {
            [self.iMovieOutput startRecordingToOutputFileURL:url recordingDelegate:self];
        }
        
    } else if ([self.takePhotoBtn.titleLabel.text isEqualToString:@"结束"]){
        [self.takePhotoBtn setTitle:@"开始" forState:UIControlStateNormal];
        if ([self.iMovieOutput isRecording]) {
            [self.iMovieOutput stopRecording];
        }
    }
    
    NSLog(@"+take Photo+");
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(subjectAreaDidChange:)name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.iDevice];
}

-(void) volumeButtonStarVideoClick:(MPVolumeObserver *) button
{
    NSLog(@"+start video+");
}

-(void) volumeButtonEndVideoClick:(MPVolumeObserver *) button
{
    NSLog(@"+end video+");
}
#pragma mark - ButtonAction

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//闪光灯
- (IBAction)flashAction:(id)sender {
    
    [self.iDevice lockForConfiguration:nil];
    
    UIButton *flashButton = (UIButton *)sender;
    flashButton.selected = !flashButton.selected;
    if (flashButton.selected) {
        if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeOn]) {
            [self.iDevice setFlashMode:AVCaptureFlashModeOn];
            [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"闪光灯已开启"];
        }
    } else{
        if ([self.iDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
            [self.iDevice setFlashMode:AVCaptureFlashModeOff];
            [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"闪光灯已关闭"];
        }
    }
    
    [self.iDevice unlockForConfiguration];
}

//前后摄像头置换
- (IBAction)changePositionAction:(id)sender {
    
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *newDevice;
    AVCaptureDeviceInput *newInput;
    
    if (self.iDevice.position == AVCaptureDevicePositionBack) {
        for (AVCaptureDevice *device in deviceArray) {
            if (device.position == AVCaptureDevicePositionFront) {
                newDevice = device;
            }
        }
    } else {
        for (AVCaptureDevice *device in deviceArray) {
            if (device.position == AVCaptureDevicePositionBack) {
                newDevice = device;
            }
        }
    }
    
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
    if (newInput!=nil) {
        
        [self.iSession beginConfiguration];
        
        [self.iSession removeInput:self.iInput];
        if ([self.iSession canAddInput:newInput]) {
            [self.iSession addInput:newInput];
            self.iDevice = newDevice;
            self.iInput = newInput;
        } else{
            [self.iSession addInput:self.iInput];
        }
        
        [self.iSession commitConfiguration];
    }
    
}

- (IBAction)takePhotoAction:(id)sender {
//    if ([self.takePhotoBtn.titleLabel.text isEqualToString:@"拍照"]) {
//        if (pictureCount==13) {
//            NSLog(@"取消");
//            [self dismissViewControllerAnimated:YES completion:nil];
//            [self configCallback];
//        }else{
//            pictureCount ++;//图片的张数
//            AVCaptureConnection *connection = [self.iOutput connectionWithMediaType:AVMediaTypeVideo];
//            if (!connection) {
//                [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"Default"];
//            } else{
//                [self.iOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//                    if (!imageDataSampleBuffer) {
//                        [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"Default"];
//                    } else{
//                        [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"Success"];
//                        
//                        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//                        UIImage *image = [UIImage imageWithData:imageData];
//                        
//                        CGImageRef sourceImageRef = [image CGImage];//将UIImage转换成CGImageRef
//                        
//                        CGSize imageSize = image.size;
//                        CGRect rect;
//                        rect =  CGRectMake(0,image.size.width/16*5, image.size.height,image.size.width/8*3 );
//                        
//                        
//                        //根据图片的大小计算出图片中间矩形区域的位置与大小
//                        //                    if (imageSize.width > imageSize.height) {
//                        //                        float leftMargin = (imageSize.width - imageSize.height) * 0.5;
//                        //                        //  rect = CGRectMake(leftMargin, 0, imageSize.height, imageSize.height);
//                        //                         rect = CGRectMake( image.size.width/16*7,0, imageSize.width/8, image.size.height);
//                        //                    }else{
//                        //                        float topMargin = (imageSize.height - imageSize.width) * 0.5;
//                        //                        //  rect = CGRectMake(0, topMargin, imageSize.width, imageSize.width);
//                        //
//                        //                         rect = CGRectMake(image.size.width/16*7,  0, image.size.width/8,image.size.height);
//                        //                    }
//                        
//                        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);//按照给定的矩形区域进行剪裁
//                        
//                        
//                        UIImage *newImage = [UIImage imageWithCGImage:newImageRef] ;
//                        
//                        
//                        CGSize NewSize = CGSizeMake(100, 45);
//                        UIGraphicsBeginImageContext(NewSize);
//                        [newImage drawInRect:CGRectMake(0, 0, NewSize.width, NewSize.height)];
//                        UIImage * newImage1 = UIGraphicsGetImageFromCurrentImageContext();
//                        UIGraphicsEndImageContext();
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                
//                        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
//                        [[AipOcrService shardService] detectTextAccurateBasicFromImage:newImage withOptions:options successHandler:^(id result) {
//                            // 成功识别的后续逻辑
//                            NSLog(@"%ld",pictureCount);
//                            [mutArr addObject:result];
//                        } failHandler:^(NSError *err) {
//                            // 失败的后续逻辑
//                            NSLog(@"失败");
//                        }];
//                        
//                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//                        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
//                        //     UIImageWriteToSavedPhotosAlbum(newImage1, nil, nil, nil);
//                    }
//                }];
//                
//            }
//        }
//    } else if([self.takePhotoBtn.titleLabel.text isEqualToString:@"开始"]){
//        
//        [self.takePhotoBtn setTitle:@"结束" forState:UIControlStateNormal];
//        
//        AVCaptureConnection *connect = [self.iMovieOutput connectionWithMediaType:AVMediaTypeVideo];
//        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"]];
//        if (![self.iMovieOutput isRecording]) {
//            [self.iMovieOutput startRecordingToOutputFileURL:url recordingDelegate:self];
//        }
//        
//    } else if ([self.takePhotoBtn.titleLabel.text isEqualToString:@"结束"]){
//        [self.takePhotoBtn setTitle:@"开始" forState:UIControlStateNormal];
//        if ([self.iMovieOutput isRecording]) {
//            [self.iMovieOutput stopRecording];
//        }
//    }
}
- (IBAction)videoButtonAction:(id)sender {
    
    self.videoBtn.selected = !self.videoBtn.selected;
    if (self.videoBtn.selected) {
        
        [self.iSession beginConfiguration];
        [self.iSession removeOutput:self.iOutput];
        if ([self.iSession canAddOutput:self.iMovieOutput]) {
            [self.iSession addOutput:self.iMovieOutput];
            
            [self.takePhotoBtn setTitle:@"开始" forState:UIControlStateNormal];
            
            //设置视频防抖
            AVCaptureConnection *connection = [self.iMovieOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported]) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
            }
            
        } else{
            [self.iSession addOutput:self.iOutput];
        }
        
        [self.iSession commitConfiguration];
        
    } else{
        [self.iSession beginConfiguration];
        [self.iSession removeOutput:self.iMovieOutput];
        if ([self.iSession canAddOutput:self.iOutput]) {
            [self.iSession addOutput:self.iOutput];
            
         //   [self.takePhotoBtn setTitle:@"拍照" forState:UIControlStateNormal];
            
        } else{
            [self.iSession addOutput:self.iMovieOutput];
        }
        
        [self.iSession commitConfiguration];
    }
    
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
    //保存视频到相册
    ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:nil];
    [[CustomeAlertView shareView] showCustomeAlertViewWithMessage:@"视频保存成功"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
