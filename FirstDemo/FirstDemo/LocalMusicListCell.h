//
//  LocalMusicListCell.h
//  QingQing
//
//  Created by 欧嘉明 on 2018/12/12.
//  Copyright © 2018年 欧嘉明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotMusicModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LocalMusicListCell : UITableViewCell
- (void)refleshData:(HotMusicModel *)sender;
@property(nonatomic,copy)void(^typeBlock)(void);
@end

NS_ASSUME_NONNULL_END
