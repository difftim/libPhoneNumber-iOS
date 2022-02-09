//
//  main.m
//  MetaDataPlistCreator
//
//  Created by Martin Böttcher on 09.02.22.
//  Copyright (c) 2022 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetaDataPlistCreator.h"

int main(int argc, const char * argv[]) {
    return [MetaDataPlistCreator createPlistFile:@"phoneNumberMap.plist"] ? 0 : 1;
}
