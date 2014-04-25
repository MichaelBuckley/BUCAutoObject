//
//  BUCAutoObjectImplementation.h
//
//  Version 2.2
//
//  Created by Buckley on 4/23/14.
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

#import <Foundation/Foundation.h>

@interface BUCAutoObjectImplementation : NSObject

+ (NSDictionary *)codablePropertiesForClass:(Class)cls;
+ (void)setObject: (id) object withCoder:(NSCoder *)aDecoder;
+ (void)encodeObject:(id)object withCoder:(NSCoder *)aCoder;
+ (BOOL) object: (id) object isEqual: (id) other;

//property access

+ (NSDictionary *)codablePropertiesForObject:(id)object;
+ (NSDictionary *)dictionaryRepresentationForObject:(id)object;

//loading / saving

+ (id)objectWithContentsOfFile:(NSString *)path;
+ (BOOL)writeObject:(id)object toFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile;

// copying
+ (id)copyObject:(id) object withZone: (NSZone *) zone;

@end
