//
//  CXKeychainHelper.h
//  KeychainSwiftAPI
//
//  Created by Denis Krivitski on 26/11/14.
//  Copyright (c) 2014 Checkmarx. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface CXResultWithStatus : NSObject
@property (assign,nonatomic) OSStatus status;
@property (strong,nonatomic) NSObject* result;
@end

@interface CXALCContent: NSObject
@property (assign,nonatomic) OSStatus status;
@property (strong,nonatomic) NSArray* applicationList;
@property (strong,nonatomic) NSString* desc;
@property (assign,nonatomic) SecKeychainPromptSelector promptSelector;
@end

@interface CXKeychainHelper : NSObject
+(CXResultWithStatus*)secItemCopyMatchingCaller:(NSDictionary*)query;
+(CXResultWithStatus*)secItemAddCaller:(NSDictionary*)query;

//
+(CXALCContent*)secACLCopyContents:(SecACLRef) acl;

@end
