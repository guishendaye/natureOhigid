//
//  ViewController.m
//  FirstDemo
//
//  Created by 欧嘉明 on 2017/11/16.
//  Copyright © 2017年 欧嘉明. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LocalMusicListCell.h"
#import "lame.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property  (nonatomic,strong) UITableView *tableView;
@property  (nonatomic,strong) NSMutableArray  *songArr;
@property  (nonatomic,strong) HotMusicModel *downingModel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"系统音乐";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 78) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status != AVAuthorizationStatusAuthorized&&status != AVAuthorizationStatusNotDetermined) {
        NSLog(@"提示用户发开访问媒体库的权限");
    }else{
        [self getSystemMusic];
    }
    
    UIButton *musicLocalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - 78, self.view.frame.size.width, 78)];
    [musicLocalBtn setTitle:@"重新扫描" forState:UIControlStateNormal];
    [musicLocalBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    musicLocalBtn.backgroundColor = [UIColor whiteColor];
    [musicLocalBtn addTarget:self action:@selector(getMusic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:musicLocalBtn];
}

- (void)getMusic{
    [self getSystemMusic];
}

- (void)getSystemMusic{
    self.songArr = [[NSMutableArray alloc] init];
    // 创建媒体选择队列
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    // 创建读取条件
    MPMediaPropertyPredicate *albumNamePredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType];
    // 给队列添加读取条件
    [query addFilterPredicate:albumNamePredicate];
    // 从队列中获取条件的数组集合
    NSArray *itemsFromGenericQuery = [query items];
    // 遍历解析数据
    for (MPMediaItem *music in itemsFromGenericQuery) {
        [self resolverMediaItem:music];
    }
    [self.tableView reloadData];
}

- (void)resolverMediaItem:(MPMediaItem *)music {
    // 歌名
    NSString *name = [music valueForProperty:MPMediaItemPropertyTitle];
    // 歌曲路径
    NSURL *fileURL = [music valueForProperty:MPMediaItemPropertyAssetURL];
    // 歌手名字
    NSString *singer = [music valueForProperty:MPMediaItemPropertyArtist];
    if(singer == nil){
        singer = @"未知歌手";
    }
    // 歌曲时长（单位：秒）
    NSTimeInterval duration = [[music valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    NSString *time = @"";
    if((int)duration % 60 < 10) {
        time = [NSString stringWithFormat:@"%d:0%d",(int)duration / 60,(int)duration % 60];
    }else {
        time = [NSString stringWithFormat:@"%d:%d",(int)duration / 60,(int)duration % 60];
    }
    // 歌曲插图（没有就返回 nil）
    MPMediaItemArtwork *artwork = [music valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image;
    if (artwork) {
        image = [artwork imageWithSize:CGSizeMake(72, 72)];
    }else {
        image = [UIImage imageNamed:@"duanshipin"];
    }
    HotMusicModel *tempModel = [HotMusicModel new];
    tempModel.title = name;
    tempModel.singer = singer;
    tempModel.systemUrl = fileURL;
    [self.songArr addObject:tempModel];
}

#pragma mark tableview
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LocalMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell"];
    if (cell == nil) {
        cell = [[LocalMusicListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MusicCell"];
    }
    HotMusicModel *tempModel = self.songArr[indexPath.row];
    [cell refleshData:tempModel];
    cell.typeBlock = ^(void) {
        [self saveSystemMusic:tempModel.systemUrl];
        self.downingModel = tempModel;
    };
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songArr.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)saveSystemMusic:(NSURL *)fileURL{
    [self convertToCAF:[NSString stringWithFormat:@"%@",fileURL] name:nil];
}

- (void)convertToCAF:(NSString *)songUrl name:(NSString *)songName{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD showWithStatus:@"正在保存，请稍等..."];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    });
    NSURL *url = [NSURL URLWithString:songUrl];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"YYYYMMddhhmmss"];
    NSString *str2 = [formatter2 stringFromDate:[NSDate date]];
    
    //由于中文歌名不行 这边采用时间戳
    NSString *fileName      = [NSString stringWithFormat:@"%@.caf",str2];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSError *assetError = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                                                                                     audioSettings: nil];
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    [assetReader addOutput: assetReaderOutput];
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL fileType:AVFileTypeCoreAudioFormat error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:outputSettings];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         // NSLog (@"top of block");
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 //             NSLog (@"appended a buffer (%d bytes)",
                 //                    CMSampleBufferGetTotalSampleSize (nextBuffer));
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
             } else {
                 // done!
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWriting];
                 [assetReader cancelReading];
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:exportPath error:nil];
                 //实现caf 转mp3
                 [self audioCAFtoMP3:exportPath];
                 NSLog (@"done. file size is %lld",
                        [outputFileAttributes fileSize]);
                 break;
             }
         }
     }];
}

- (void)audioCAFtoMP3:(NSString *)wavPath {
    
    NSString *cafFilePath = wavPath;
    
    NSString *mp3FilePath = [NSString stringWithFormat:@"%@.mp3",[NSString stringWithFormat:@"%@",[cafFilePath substringToIndex:cafFilePath.length - 4]]];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        
        lame_set_brate(lame,8);
        
        lame_set_mode(lame,3);
        
        lame_set_quality(lame,2);
        
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //主线程上传到oss
            [SVProgressHUD dismiss];
            NSLog(@"-----%@",mp3FilePath);
            NSArray *arr = [[NSString stringWithFormat:@"%@",mp3FilePath] componentsSeparatedByString:@"/"];
        });
    }
}

@end
