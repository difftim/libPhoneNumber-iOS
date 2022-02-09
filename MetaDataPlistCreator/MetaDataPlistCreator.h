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

+ (NSDictionary *)jsonObjectFromZippedDataWithBytes:(z_const Bytef [])bytes
                                   compressedLength:(NSUInteger)compressedLength
                                     expandedLength:(NSUInteger)expandedLength;

+ (NSDictionary<NSObject *, NSObject *> *)deduplicateJsonMap:(NSDictionary<NSObject *, NSObject *> *)inputMap;

+ (NSObject *)deduplicateJsonValue:(NSObject *)jsonValue valueSet:(NSMutableSet<NSObject *> *)valueSet;

+ (NSArray<NSObject *> *)deduplicateJsonArray:(NSArray<NSObject *> *)jsonArray
                                     valueSet:(NSMutableSet<NSObject *> *)valueSet;

+ (NSDictionary<NSObject *, NSObject *> *)deduplicateJsonDictionary:(NSDictionary<NSObject *, NSObject *> *)jsonDictionary
                                                           valueSet:(NSMutableSet<NSObject *> *)valueSet;

@end

#endif /* MetaDataPlistCreator_h */
