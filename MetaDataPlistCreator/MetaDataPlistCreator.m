//
//  MetaDataPlistCreator.m
//  MetaDataPlistCreator
//
//  Created by Martin Böttcher on 09.02.22.
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetaDataPlistCreator.h"
#import "NBGeneratedPhoneNumberMetaData.h"

@implementation MetaDataPlistCreator: NSObject

+ (BOOL) createPlistFile:(NSString*) path {
    NSDictionary *result = [MetaDataPlistCreator jsonObjectFromZippedDataWithBytes:kPhoneNumberMetaData
                                                                  compressedLength:kPhoneNumberMetaDataCompressedLength
                                                                    expandedLength:kPhoneNumberMetaDataExpandedLength];

    // The jsonMap is large and held in memory.
    // It's contents are deeply nested and very repetitive.
    // We can greatly reduce the memory used by jsonMap
    // by traversing its contents and de-duplicating repeated values.
    result = [MetaDataPlistCreator deduplicateJsonMap:result];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:result requiringSecureCoding:NO error:NULL];
    return data != nil && [data writeToFile:path atomically:YES];
}

+ (NSDictionary<NSObject *, NSObject *> *)deduplicateJsonMap:(NSDictionary<NSObject *, NSObject *> *)inputMap {
    NSMutableSet<NSObject *> *valueSet = [NSMutableSet new];
    NSObject *result = [self deduplicateJsonValue:inputMap valueSet:valueSet];
    return (NSDictionary<NSObject *, NSObject *> *) result;
}

+ (NSObject *)deduplicateJsonValue:(NSObject *)jsonValue valueSet:(NSMutableSet<NSObject *> *)valueSet {
    
    NSObject *_Nullable existingValue = [valueSet member:jsonValue];
    if (existingValue != nil) {
        assert([existingValue isKindOfClass:jsonValue.class]);
        return existingValue;
    } else {
        [valueSet addObject:jsonValue];
    }

    if ([jsonValue isKindOfClass:NSArray.class]) {
        return [self deduplicateJsonArray:(NSArray<NSObject *> *) jsonValue
                                 valueSet:valueSet];
    } else if ([jsonValue isKindOfClass:NSDictionary.class]) {
        return [self deduplicateJsonDictionary:(NSDictionary<NSObject *, NSObject *> *) jsonValue
                                      valueSet:valueSet];
    } else if ([jsonValue isKindOfClass:NSString.class] ||
               [jsonValue isKindOfClass:NSNumber.class] ||
               [jsonValue isKindOfClass:NSData.class] ||
               [jsonValue isKindOfClass:NSNull.class]) {
        return jsonValue;
    } else {
        NSLog(@"Unexpected value: %@, %@", jsonValue.class, jsonValue);
        return jsonValue;
    }
}

+ (NSArray<NSObject *> *)deduplicateJsonArray:(NSArray<NSObject *> *)jsonArray
                                     valueSet:(NSMutableSet<NSObject *> *)valueSet {
    NSMutableArray<NSObject *> *result = [NSMutableArray new];
    for (NSObject *jsonValue in jsonArray) {
        [result addObject:[self deduplicateJsonValue:jsonValue valueSet:valueSet]];
    }
    return result;
}

+ (NSDictionary<NSObject *, NSObject *> *)deduplicateJsonDictionary:(NSDictionary<NSObject *, NSObject *> *)jsonDictionary
                                                           valueSet:(NSMutableSet<NSObject *> *)valueSet {
    NSMutableDictionary<NSObject *, NSObject *> *result = [NSMutableDictionary new];
    [jsonDictionary enumerateKeysAndObjectsUsingBlock:^(NSObject * _Nonnull jsonKey,
                                                        NSObject * _Nonnull jsonValue,
                                                        BOOL * _Nonnull stop) {
        result[(id<NSCopying>) jsonKey] = [self deduplicateJsonValue:jsonValue valueSet:valueSet];
    }];
    return result;
}

/**
 * Expand gzipped data into a JSON object.

 * @param bytes Array<Bytef> of zipped data.
 * @param compressedLength Length of the compressed bytes.
 * @param expandedLength Length of the expanded bytes.
 * @return JSON dictionary.
 */
+ (NSDictionary *)jsonObjectFromZippedDataWithBytes:(z_const Bytef [])bytes
                                   compressedLength:(NSUInteger)compressedLength
                                     expandedLength:(NSUInteger)expandedLength {
  // Data is a gzipped JSON file that is embedded in the binary.
  // See GeneratePhoneNumberHeader.sh and PhoneNumberMetaData.h for details.
  NSMutableData* gunzippedData = [NSMutableData dataWithLength:expandedLength];

  z_stream zStream;
  memset(&zStream, 0, sizeof(zStream));
  __attribute((unused)) int err = inflateInit2(&zStream, 16);
  NSAssert(err == Z_OK, @"Unable to init stream. err = %d", err);

  zStream.next_in = bytes;
  zStream.avail_in = (uint)compressedLength;
  zStream.next_out = (Bytef *)gunzippedData.bytes;
  zStream.avail_out = (uint)gunzippedData.length;

  err = inflate(&zStream, Z_FINISH);
  NSAssert(err == Z_STREAM_END, @"Unable to inflate compressed data. err = %d", err);

  err = inflateEnd(&zStream);
  NSAssert(err == Z_OK, @"Unable to inflate compressed data. err = %d", err);

  NSError *error = nil;
  NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:gunzippedData
                                                             options:0
                                                               error:&error];
  NSAssert(error == nil, @"Unable to convert JSON - %@", error);

  return jsonObject;
}

@end
