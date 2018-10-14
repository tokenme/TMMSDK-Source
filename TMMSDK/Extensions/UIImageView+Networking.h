//
//  UIImageView+Networking.h
//  TMMSDK
//
//  Created by Syd Xu on 2018/10/15.
//  Copyright © 2018 tokenmama.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// UIImageView Extentions resposipble for downloading the image from remote server.

typedef void (^DownloadCompletionBlock) (BOOL succes, UIImage *image, NSError *error);

@interface UIImageView (Networking)
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *URLId;

- (void)setImageURL:(NSURL *)imageURL withCompletionBlock:(DownloadCompletionBlock)block;
@end
