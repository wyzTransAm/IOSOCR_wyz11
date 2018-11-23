#import "MPVolumeObserverPro.h"


@interface MPVolumeObserverPro()
{
    MPVolumeView   *_volumeView;
    float           launchVolume;
    BOOL            _isObservingVolumeButtons;
    BOOL            _suspended;
    int             Isfirst;
    NSString       *strNowVolume;
    NSTimer        *timeVideoBtn;
    NSInteger       secondsElapsed;
    BOOL            isVideoStar;
    BOOL            isVideoEnd;
    
    float           fVolume;
}

@end

@implementation MPVolumeObserverPro

+(MPVolumeObserverPro*) sharedInstance;
{
    static MPVolumeObserverPro *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MPVolumeObserverPro alloc] init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    if( self ){
        _isObservingVolumeButtons = NO;
        _suspended = NO;
        Isfirst = 0;
        secondsElapsed = 0;
        CGRect frame = CGRectMake(0, -100, 5, 5);
        _volumeView = [[MPVolumeView alloc] initWithFrame:frame];
        [[UIApplication sharedApplication].windows[1] addSubview:_volumeView];
        
    }
    return self;
}

-(void)startObserveVolumeChangeEvents
{
    _suspended = NO;
    isVideoStar = YES;
    isVideoEnd = NO;
    fVolume = [self volume];
    [self startObserve];
}

-(void) startObserve;
{
    NSLog(@"start add notification");
    if(_isObservingVolumeButtons)
    {
        return;
    }
    
    
    [[AVAudioSession sharedInstance] setActive:NO error: nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error: nil];
    
    _isObservingVolumeButtons = YES;
    strNowVolume = [[ NSString stringWithFormat:@"%f",[self volume] ] substringToIndex:4];
    strNowVolume = [strNowVolume  isEqualToString: @"0.00"] ? @"0.05" : strNowVolume;
    strNowVolume = [strNowVolume  isEqualToString: @"1.00"] ? @"0.95" : strNowVolume;
    if ([strNowVolume  isEqual: @"0.05"] || [strNowVolume isEqualToString:@"0.95"])
    {
        [self setVolume:[strNowVolume floatValue]];
    }
    if (!_suspended)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(suspendObserveVolumeChangeEvents:)
                                                     name:UIApplicationWillResignActiveNotification     // -> Inactive
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeObserveVolumeButtonEvents:)
                                                     name:UIApplicationDidBecomeActiveNotification      // <- Active
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChangeNotification:)
                                                     name:@"SystemVolumeDidChange" object:nil];
    }
}

-(void) volumeChangeNotification:(NSNotification *) no
{
    static id sender = nil;
    if (sender == nil && no.object) {
        sender = no.object;
    }
    
    NSString * NowChangeVolume = [[ NSString stringWithFormat:@"%f",[[no.userInfo objectForKey:@"AudioVolume"] floatValue] ] substringToIndex:4];
    if (no.object != sender || [NowChangeVolume isEqualToString: strNowVolume]) {
        return;
    }
    
    NSLog(@"音量变化");
    
    [self setVolume:[strNowVolume floatValue]];
    if(timeVideoBtn)
    {
        if(secondsElapsed == 1)
        {
            if (isVideoStar)
            {
                NSLog(@"start video");
                if ([self.delegate respondsToSelector:@selector(volumeButtonStarVideoClick:)]) {
                    [self.delegate volumeButtonStarVideoClick:self];
                }
                isVideoStar = NO;
                isVideoEnd = YES;
            }
        }
        secondsElapsed ++;
        [timeVideoBtn invalidate];
    }
    
    timeVideoBtn = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                    target:self
                                                  selector:@selector(onTimeFire)
                                                  userInfo:nil
                                                   repeats:NO];
}

-(void)onTimeFire
{
    
    timeVideoBtn = nil;
    
    if (secondsElapsed > 2)
    {
        if (isVideoEnd) {
            
            secondsElapsed = 0;
            NSLog(@"end video");
            if ([self.delegate respondsToSelector:@selector(volumeButtonEndVideoClick:)]) {
                [self.delegate volumeButtonEndVideoClick:self];
                isVideoEnd = NO;
                isVideoStar = YES;
            }
        }
    }
    else
    {
        double delayInSeconds = 0.55;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tackPhoto];
        });
    }
}




- (void)tackPhoto
{
    if (isVideoStar)
    {
        NSLog(@"take Photo");
        if ([self.delegate respondsToSelector:@selector(volumeButtonCameraClick:)]) {
            [self.delegate volumeButtonCameraClick:self];
        }
    }
}


- (void)suspendObserveVolumeChangeEvents:(NSNotification *)notification
{
    if(_isObservingVolumeButtons)
    {
        _suspended = YES; // Call first!
        [self stopObserveVolumeChangeEvents];
        Isfirst = 0;
    }
}

- (void)resumeObserveVolumeButtonEvents:(NSNotification *)notification
{
    if(_suspended)
    {
        [self startObserveVolumeChangeEvents];
        Isfirst = 0;
        _suspended = NO; // Call last!
    }
}

-(void)stopObserveVolumeChangeEvents
{
    
    if(!_isObservingVolumeButtons){
        return;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SystemVolumeDidChange" object:nil];
    
    Isfirst = 0;
    [timeVideoBtn invalidate];
    secondsElapsed = 0;
    _isObservingVolumeButtons = NO;
    [[AVAudioSession sharedInstance] setActive:NO error: nil];
    
}

- (float)volume
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat volume = audioSession.outputVolume;
    return volume;
}

- (void)setVolume:(float)newVolume
{
    MPVolumeView* volumeView = [[MPVolumeView alloc] init];
    
    //find the volumeSlider
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    [volumeViewSlider setValue:newVolume animated:YES];
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}
-(void)dealloc
{
    _suspended = NO;
    Isfirst = 0;
}

@end




