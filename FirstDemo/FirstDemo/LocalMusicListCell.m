

//
//  LocalMusicListCell.m
//  QingQing
//
//  Created by 欧嘉明 on 2018/12/12.
//  Copyright © 2018年 欧嘉明. All rights reserved.
//

#import "LocalMusicListCell.h"

@interface LocalMusicListCell()
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UILabel *nameLab;
@property (strong, nonatomic) UIButton *typeBtn;
@end
@implementation LocalMusicListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //布局View
        [self setUpView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - setUpView
- (void)setUpView{
    _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15,18,200, 15)];
    _titleLab.textColor = [UIColor orangeColor];
    [self.contentView addSubview:_titleLab];
    
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(15,37,200, 10)];
    _nameLab.textColor = [UIColor redColor];
    [self.contentView addSubview:_nameLab];
    
    _typeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 52, 0, 52, 70)];
    [_typeBtn setImage:[UIImage imageNamed:@"LocalNoDown"] forState:UIControlStateNormal];
    [_typeBtn addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
    _typeBtn.imageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_typeBtn];
}

- (void)refleshData:(HotMusicModel *)sender{
    if (sender.hadDownBool) {
        _typeBtn.enabled = NO;
    }else{
        _typeBtn.enabled = YES;
    }
    _titleLab.text = sender.title;
    _nameLab.text = sender.singer;
}

- (void)typeClick:(UIButton *)sender{
    if (_typeBlock) {
        _typeBlock();
    }
}

@end
