//
//  HXPhotoPreviewVideoViewCell.m
//  照片选择器
//
//  Created by 洪欣 on 2019/12/5.
//  Copyright © 2019 洪欣. All rights reserved.
//

#import "HXPhotoPreviewVideoViewCell.h"
#import "UIView+HXExtension.h"
#import "HXPhotoDefine.h"

@interface HXPhotoPreviewVideoViewCell ()

@end

@implementation HXPhotoPreviewVideoViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.previewContentView = [[HXPreviewContentView alloc] initWithType:HXPreviewContentViewTypeVideo];
        HXWeakSelf
        self.previewContentView.videoView.gotVideoDuration = ^(NSTimeInterval duration) {
            weakSelf.bottomSliderView.totalTime = [HXPhotoTools transformVideoTimeToString:duration];
        };
        self.previewContentView.videoView.gotVideoBufferEmptyValue = ^(CGFloat value) {
            weakSelf.bottomSliderView.progressValue = value;
        };
        self.previewContentView.videoView.gotVideoCurrentTime = ^(NSTimeInterval currentTime) {
            weakSelf.bottomSliderView.currentTime = [HXPhotoTools transformVideoTimeToString:currentTime];
        };
        self.previewContentView.videoView.changeValue = ^(CGFloat value, BOOL animaiton) {
            [weakSelf.bottomSliderView setCurrentValue:value animation:animaiton];
        };
        self.previewContentView.videoView.changePlayBtnState = ^(BOOL isSelected) {
            weakSelf.bottomSliderView.playBtnSelected = isSelected;
        };
        self.previewContentView.downloadNetworkImageComplete = ^{
            if (weakSelf.cellDownloadImageComplete) {
                weakSelf.cellDownloadImageComplete(weakSelf);
            }
            [weakSelf refreshImageSize];
        };
        [self.scrollView addSubview:self.previewContentView];
        [self.contentView addSubview:self.bottomSliderView];
    }
    return self;
}
- (void)cancelRequest {
    self.previewContentView.stopCancel = self.stopCancel;
    if (!self.stopCancel) {
        self.bottomSliderView.alpha = 0;
        self.bottomSliderView.hidden = YES;
    }
    [self.previewContentView cancelRequest];
    self.stopCancel = NO;
}
- (void)setModel:(HXPhotoModel *)model {
    [super setModel:model];
    self.bottomSliderView.totalTime = model.videoTime;
}
- (HXPreviewVideoSliderView *)bottomSliderView {
    if (!_bottomSliderView) {
        _bottomSliderView = [[HXPreviewVideoSliderView alloc] init];
        [_bottomSliderView setCurrentValue:0 animation:NO];
        _bottomSliderView.alpha = 0;
        _bottomSliderView.hidden = YES;
        HXWeakSelf
        _bottomSliderView.didPlayBtnBlock = ^(BOOL isPlay) {
            [weakSelf.previewContentView.videoView didPlayBtnClickWithSelected:isPlay];
        };
        _bottomSliderView.sliderChangedValueBlock = ^(CGFloat value, HXPreviewVideoSliderType type) {
            [weakSelf.previewContentView.videoView changePlayerTimeWithValue:value type:type];
        };
    }
    return _bottomSliderView;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.bottomSliderView.frame = CGRectMake(15, self.hx_h - hxBottomMargin - 60, self.hx_w - 30, 35);
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        self.bottomSliderView.frame = CGRectMake(15, self.hx_h - 60, self.hx_w - 15 - hxBottomMargin, 35);
    }
}
@end
