//
//  BUCAutoObject.m
//
//  Version 2.2
//
//  Created by Michael Buckley on 4/18/14.
//
//  Modified from Autocoding. Original copyright and license below
//
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/AutoCoding
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "BUCAutoObject.h"
#import "BUCAutoObjectImplementation.h"

@implementation BUCAutoObject

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (instancetype)objectWithContentsOfFile:(NSString *)filePath
{
    return [BUCAutoObjectImplementation objectWithContentsOfFile: filePath];
}

- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile
{
    return [BUCAutoObjectImplementation writeObject: self toFile: filePath atomically: useAuxiliaryFile];
}

+ (NSDictionary *)codableProperties
{
    //deprecated
    return [BUCAutoObjectImplementation codablePropertiesForClass: self];
}

- (NSDictionary *)codableProperties
{
    return [BUCAutoObjectImplementation codablePropertiesForObject: self];
}

- (NSDictionary *)dictionaryRepresentation
{
    return [BUCAutoObjectImplementation dictionaryRepresentationForObject: self];
}

- (void)setWithCoder:(NSCoder *)aDecoder
{
    [BUCAutoObjectImplementation setObject: self withCoder: aDecoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    [self setWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [BUCAutoObjectImplementation encodeObject: self withCoder: aCoder];
}

- (id)copyWithZone: (NSZone *) zone
{
    return [BUCAutoObjectImplementation copyObject: self withZone: zone];
}

- (BOOL) isEqual: (id) object
{
    return [BUCAutoObjectImplementation object: self isEqual: object];
}

@end
