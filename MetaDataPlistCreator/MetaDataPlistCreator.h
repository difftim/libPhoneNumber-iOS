//
//  MetaDataPlistCreator.h
//  MetaDataPlistCreator
//
//  Created by Martin Böttcher on 09.02.22.
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

#ifndef MetaDataPlistCreator_h
#define MetaDataPlistCreator_h

#include <zlib.h>

@interface MetaDataPlistCreator : NSObject

+ (BOOL) createPlistFile:(NSString*) path;

@end

#endif /* MetaDataPlistCreator_h */
