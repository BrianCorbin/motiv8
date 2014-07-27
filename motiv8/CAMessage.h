//
//  CAMessage.h
//  motiv8
//
//  Created by Brian Corbin on 7/10/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

//CAMessage is to be used to store the specific message/quote and its author as a custom class.

@interface CAMessage : NSObject

@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* favorited;

//encode and decode to store in NSUserDefaults
- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
