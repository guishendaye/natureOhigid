//
//  HotMusicModel.h
//  QingQing
//
//  Created by 欧嘉明 on 2018/12/11.
//  Copyright © 2018年 欧嘉明. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HotMusicModel : NSObject
@property(nonatomic,strong) NSString *ID;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *singer;
@property(nonatomic,strong) NSString *length;
@property(nonatomic,strong) NSString *lyrics;
@property(nonatomic,strong) NSString *downloadurl;
@property(nonatomic,strong) NSString *bitrate;

//自增
@property(nonatomic)BOOL hadDownBool;//是否已经下载
@property(nonatomic,strong) NSString *local;//本地音乐路径
@property(nonatomic,strong) NSString *localLyrics;//本地歌词地址
@property(nonatomic,strong) NSString *onlyMD5;//本地文件唯一md5标识

//系统音乐地址
@property(nonatomic,strong)NSURL *systemUrl;

@end

NS_ASSUME_NONNULL_END
