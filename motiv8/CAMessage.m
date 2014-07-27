//
//  CAMessage.m
//  motiv8
//
//  Created by Brian Corbin on 7/10/14.
//  Copyright (c) 2014 Caramel Apps. All rights reserved.
//

#import "CAMessage.h"

@implementation CAMessage

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.message forKey:@"message"];
    [encoder encodeObject:self.author forKey:@"author"];
    [encoder encodeObject:self.favorited forKey:@"favorited"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.message = [decoder decodeObjectForKey:@"message"];
        self.author = [decoder decodeObjectForKey:@"author"];
        self.favorited = [decoder decodeObjectForKey:@"favorited"];
    }
    return self;
}

@end
