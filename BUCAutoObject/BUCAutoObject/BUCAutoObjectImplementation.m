//
//  BUCAutoObjectImplementation.m
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

#import <objc/runtime.h>

#import "BUCAutoObject.h"
#import "BUCAutoObjectImplementation.h"

#pragma GCC diagnostic ignored "-Wgnu"


static NSString *const AutocodingException = @"AutocodingException";

@implementation BUCAutoObjectImplementation

+ (id)objectWithContentsOfFile:(NSString *)filePath
{
    //load the file
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    //attempt to deserialise data as a plist
    id object = nil;
    if (data)
    {
        NSPropertyListFormat format;
        object = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:NULL];
        
		//success?
		if (object)
		{
			//check if object is an NSCoded unarchive
			if ([object respondsToSelector:@selector(objectForKey:)] && [(NSDictionary *)object objectForKey:@"$archiver"])
			{
				object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			}
		}
		else
		{
			//return raw data
			object = data;
		}
    }
    
	//return object
	return object;
}

+ (BOOL)writeObject:(id)object toFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile
{
    //note: NSData, NSDictionary and NSArray already implement this method
    //and do not save using NSCoding, however the objectWithContentsOfFile
    //method will correctly recover these objects anyway
    
    //archive object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    return [data writeToFile:filePath atomically:useAuxiliaryFile];
}

+ (NSDictionary *)codablePropertiesForClass:(Class)cls
{
    SEL deprecatedSelector = NSSelectorFromString(@"codableKeys");
    if ([cls respondsToSelector:deprecatedSelector] || [cls instancesRespondToSelector:deprecatedSelector])
    {
        NSLog(@"AutoCoding Warning: codableKeys method is no longer supported. Use codableProperties instead.");
    }
    deprecatedSelector = NSSelectorFromString(@"uncodableKeys");
    if ([cls respondsToSelector:deprecatedSelector] || [cls instancesRespondToSelector:deprecatedSelector])
    {
        NSLog(@"AutoCoding Warning: uncodableKeys method is no longer supported. Use ivars, or synthesize your properties using non-KVC-compliant names to avoid coding them instead.");
    }
    deprecatedSelector = NSSelectorFromString(@"uncodableProperties");
    NSArray *uncodableProperties = nil;
    if ([cls respondsToSelector:deprecatedSelector] || [cls instancesRespondToSelector:deprecatedSelector])
    {
        uncodableProperties = [cls valueForKey:@"uncodableProperties"];
        NSLog(@"AutoCoding Warning: uncodableProperties method is no longer supported. Use ivars, or synthesize your properties using non-KVC-compliant names to avoid coding them instead.");
    }
    
    unsigned int propertyCount;
    __autoreleasing NSMutableDictionary *codableProperties = [NSMutableDictionary dictionary];
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++)
    {
        //get property name
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        __autoreleasing NSString *key = @(propertyName);
        
        //check if codable
        if (![uncodableProperties containsObject:key])
        {
            //get property type
            Class propertyClass = nil;
            char *typeEncoding = property_copyAttributeValue(property, "T");
            switch (typeEncoding[0])
            {
                case '@':
                {
                    if (strlen(typeEncoding) >= 3)
                    {
                        char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                        __autoreleasing NSString *name = @(className);
                        NSRange range = [name rangeOfString:@"<"];
                        if (range.location != NSNotFound)
                        {
                            name = [name substringToIndex:range.location];
                        }
                        propertyClass = NSClassFromString(name) ?: [NSObject class];
                        free(className);
                    }
                    break;
                }
                case 'c':
                case 'i':
                case 's':
                case 'l':
                case 'q':
                case 'C':
                case 'I':
                case 'S':
                case 'L':
                case 'Q':
                case 'f':
                case 'd':
                case 'B':
                {
                    propertyClass = [NSNumber class];
                    break;
                }
                case '{':
                {
                    propertyClass = [NSValue class];
                    break;
                }
            }
            free(typeEncoding);
            
            if (propertyClass)
            {
                //check if there is a backing ivar
                char *ivar = property_copyAttributeValue(property, "V");
                if (ivar)
                {
                    //check if ivar has KVC-compliant name
                    __autoreleasing NSString *ivarName = @(ivar);
                    if ([ivarName isEqualToString:key] || [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
                    {
                        //no setter, but setValue:forKey: will still work
                        codableProperties[key] = propertyClass;
                    }
                    free(ivar);
                }
                else
                {
                    //check if property is dynamic and readwrite
                    char *dynamic = property_copyAttributeValue(property, "D");
                    char *readonly = property_copyAttributeValue(property, "R");
                    if (dynamic && !readonly)
                    {
                        //no ivar, but setValue:forKey: will still work
                        codableProperties[key] = propertyClass;
                    }
                    free(dynamic);
                    free(readonly);
                }
            }
        }
    }
    
    free(properties);
    return codableProperties;
}

+ (NSDictionary *)codablePropertiesForObject:(id)object
{
    __autoreleasing NSDictionary *codableProperties = objc_getAssociatedObject([object class], _cmd);
    if (!codableProperties)
    {
        codableProperties = [NSMutableDictionary dictionary];
        Class subclass = [object class];
        while (subclass != [NSObject class])
        {
            [(NSMutableDictionary *)codableProperties addEntriesFromDictionary:[subclass codableProperties]];
            subclass = [subclass superclass];
        }
        codableProperties = [NSDictionary dictionaryWithDictionary:codableProperties];
        
        //make the association atomically so that we don't need to bother with an @synchronize
        objc_setAssociatedObject([object class], _cmd, codableProperties, OBJC_ASSOCIATION_RETAIN);
    }
    return codableProperties;
}

+ (NSDictionary *)dictionaryRepresentationForObject:(id)object
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (__unsafe_unretained NSString *key in [object codableProperties])
    {
        id value = [object valueForKey:key];
        if (value) dict[key] = value;
    }
    return dict;
}

+ (void)setObject: (id) object withCoder:(NSCoder *)aDecoder
{
    BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
    BOOL secureSupported = [[object class] supportsSecureCoding];
    NSDictionary *properties = [object codableProperties];
    for (NSString *key in properties)
    {
        id decodedObject = nil;
        Class propertyClass = properties[key];
        if (secureAvailable)
        {
            decodedObject = [aDecoder decodeObjectOfClass:propertyClass forKey:key];
        }
        else
        {
            decodedObject = [aDecoder decodeObjectForKey:key];
        }
        if (decodedObject)
        {
            if (secureSupported && ![decodedObject isKindOfClass:propertyClass])
            {
                [NSException raise:AutocodingException format:@"Expected '%@' to be a %@, but was actually a %@", key, propertyClass, [decodedObject class]];
            }
            [object setValue:decodedObject forKey:key];
        }
    }
}

+ (void)encodeObject:(id)object withCoder:(NSCoder *)aCoder
{
    for (NSString *key in [object codableProperties])
    {
        id encodedObject = [object valueForKey:key];
        if (encodedObject) [aCoder encodeObject:encodedObject forKey:key];
    }
}

+ (id)copyObject:(id) object withZone: (NSZone *) zone
{
    id copy = [[[object class] alloc] init];
    for (NSString *key in [object codableProperties])
    {
        [copy setValue:[object valueForKey:key] forKey:key];
    }
    return copy;
}

+ (BOOL) object: (id) object isEqual: (id) other
{
    return [[object dictionaryRepresentation] isEqual: [other dictionaryRepresentation]];
}

@end
