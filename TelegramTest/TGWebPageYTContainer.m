//
//  TGWebPageYTContainer.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageYTContainer.h"
#import "TGImageView.h"
#import "TMLoaderView.h"
#import "TGCTextView.h"
#import "XCDYouTubeKit.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "YoutubeServiceDescription.h"
#import "ITProgressIndicator.h"
#import "TGPhotoViewer.h"
#import "MessageCellDescriptionView.h"
@interface TGWebpageYTContainer ()

@property (nonatomic, strong) MessageCellDescriptionView *videoTimeView;



@property (nonatomic,strong) NSImageView *youtubeImage;

@property (nonatomic,strong) AVPlayerView *playerView;

@property (nonatomic,strong) ITProgressIndicator *progressIndicator;

@property (nonatomic,strong) TMView *blackContainer;

@end

@implementation TGWebpageYTContainer



-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        _blackContainer = [[TMView alloc] initWithFrame:NSZeroRect];
        _blackContainer.backgroundColor = [NSColor blackColor];
        _blackContainer.wantsLayer = YES;
        _blackContainer.layer.cornerRadius = 4;
        
        
        self.progressIndicator = [[ITProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        
        
        self.progressIndicator.color = [NSColor whiteColor];
        
        [self.progressIndicator setIndeterminate:YES];
        
        self.progressIndicator.lengthOfLine = 8;
        self.progressIndicator.numberOfLines = 10;
        self.progressIndicator.innerMargin = 5;
        self.progressIndicator.widthOfLine = 3;
        
        
        [_blackContainer addSubview:_progressIndicator];
        
        _youtubeImage = imageViewWithImage(image_ModernMessageYoutubeButton());
        
        
        dispatch_block_t block = ^{
            
            
            [self playVideo];
            
        };
        
        
        
        [self.imageView setTapBlock:block];
        
        
        [self.imageView addSubview:_youtubeImage];
        
        
        _videoTimeView = [[MessageCellDescriptionView alloc] initWithFrame:NSZeroRect];
        
        [self.imageView addSubview:_videoTimeView];

    }
    
    return self;
}

-(void)setWebpage:(TGWebpageYTObject *)webpage {
    
    [self.author setHidden:!webpage.author];
    [self.date setHidden:!webpage.date];
    
    if(webpage.author ) {
        [self.author setAttributedStringValue:webpage.author];
        [self.date setStringValue:webpage.date];
        
        [self.author sizeToFit];
        [self.date sizeToFit];
        
        [self.author setFrameOrigin:NSMakePoint(0, NSMaxY(self.frame) - NSHeight(self.author.frame))];
        [self.date setFrameOrigin:NSMakePoint(NSMaxX(self.frame) - NSWidth(self.author.frame), NSMaxY(self.frame) - NSHeight(self.author.frame))];
        
    }
    
    [_blackContainer removeFromSuperview];
    
    [self.imageView setFrame:NSMakeRect(0, NSHeight(self.frame) - webpage.imageSize.height, webpage.imageSize.width, webpage.imageSize.height)];
    
    [self.imageView setObject:webpage.imageObject];
    
    [self.loaderView setCenterByView:self.imageView];
    [self.youtubeImage setCenterByView:self.imageView];
    
    [self.descriptionField setFrame:NSMakeRect(0, !self.author.isHidden ? 20 : 0, webpage.titleSize.width , webpage.titleSize.height )];
    [self.descriptionField setAttributedString:webpage.title];
    
    
    
    [_videoTimeView setString:webpage.videoTimeAttributedString];
    [_videoTimeView setFrameSize:webpage.videoTimeSize];
    [_videoTimeView setFrameOrigin:NSMakePoint(NSWidth(self.imageView.frame) - NSWidth(_videoTimeView.frame) - 5, 5)];
    
    
    
    
    [super setWebpage:webpage];
    
}

-(void)updateState:(TMLoaderViewState)state {
    [super updateState:state];
    
    
    [_youtubeImage setHidden:!self.item.isset];
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
}


-(void)playVideo {
    
    
    if (floor(NSAppKitVersionNumber) > 1187)  {
        if(![(TGWebpageYTObject *)self.webpage video]) {
            [_blackContainer setFrame:self.imageView.bounds];
            
            [_progressIndicator setCenterByView:_blackContainer];
            
            [_progressIndicator setAnimates:YES];
            
            [self.imageView addSubview:_blackContainer];
        }
        
        
        [(TGWebpageYTObject *)self.webpage loadVideo:^(XCDYouTubeVideo *video) {
            
            [_progressIndicator setAnimates:NO];
            [_blackContainer removeFromSuperview];
            
            
            
            [self playFullScreen];
            
//            if (video && !PLAY)
//            {
//                PLAY = YES;
//                
//                [self clearPlayer];
//                
//                _playerView = [[AVPlayerView alloc] initWithFrame:self.imageView.bounds];
//                
//                [_fullScreenImageView setCenterByView:_playerView];
//                
//                
//                [self addSubview:_playerView];
//                
//                NSDictionary *streamURLs = video.streamURLs;
//                NSURL *url = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?: streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];
//                AVPlayer *player = [AVPlayer playerWithURL:url];
//                _playerView.player = player;
//                [player play];
//                
//                [_playerView addSubview:_fullScreenImageView];
//            }
            
        }];
    } else {
        open_link(self.webpage.webpage.display_url);
    }
    
    
    
}

-(void)clearPlayer {
    [_playerView.player pause];
    _playerView.player = nil;
    [_playerView removeFromSuperview];
    _playerView = nil;
}

-(void)playFullScreen {
    
   
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:rand_long() media:[self.webpage.webpage.photo.sizes lastObject] peer_id:0];
    
    
    NSDictionary *streamURLs = [(TGWebpageYTObject *)self.webpage video].streamURLs;
    
    
    NSURL *url = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?: streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];
    
    
    NSSize size;
    
    if(streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] || streamURLs[@(XCDYouTubeVideoQualityHD720)]) {
        size = NSMakeSize(1280, 720);
    } else if(streamURLs[@(XCDYouTubeVideoQualityMedium360)]) {
        size = NSMakeSize(480, 360);
    } else if(streamURLs[@(XCDYouTubeVideoQualitySmall240)]) {
        size = NSMakeSize(320, 240);
    }
    
    
    previewObject.reservedObject = @{@"url":url,@"size":[NSValue valueWithSize:size],@"time":[NSValue valueWithCMTime:_playerView.player.currentTime]};
    
    
     [self setWebpage:self.webpage];
    
    [[TGPhotoViewer viewer] show:previewObject];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

@end
