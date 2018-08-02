//
//  TMMHook.h
//  TMMSDK
//
//  Created by Syd on 2018/7/30.
//  Copyright © 2018年 tokenmama.io. All rights reserved.
//

#ifndef TMMHook_h
#define TMMHook_h

@interface TMMHook: NSObject
+(instancetype) shareInstance;
+(instancetype) initWithDelegate:(id) delegate;
@end

#endif /* TMMHook_h */
