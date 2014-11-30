//
//  MVAData.m
//  Best Blur
//
//  Created by Mauro Vime Castillo on 11/10/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "MVAData.h"

@implementation MVAData
- (void)encodeWithCoder:(NSCoder *)coder;
{
    [coder encodeInt:self.tintIndex forKey:@"tintIndex"];
    [coder encodeFloat:self.radius forKey:@"radius"];
    [coder encodeFloat:self.max forKey:@"max"];
    NSData *data =  UIImageJPEGRepresentation(self.original, 1.0f);
    [coder encodeObject:data forKey:@"imagen"];
    [coder encodeObject:self.status forKey:@"status"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [[MVAData alloc] init];
    if (self != nil) {
        self.tintIndex = [coder decodeIntForKey:@"tintIndex"];
        self.radius = [coder decodeFloatForKey:@"radius"];
        self.max = [coder decodeFloatForKey:@"max"];
        NSData *data = [coder decodeObjectForKey:@"imagen"];
        self.original = [UIImage imageWithData:data];
        self.status = [coder decodeObjectForKey:@"status"];
    }
    return self;
}

@end
