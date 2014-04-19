//
//  BUCAutoObjectTests.m
//  BUCAutoObjectTests
//
//  Created by Buckley on 4/18/14.
//  Copyright (c) 2014 Michael Buckley. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TestObject.h"

@interface BUCAutoObjectTests : XCTestCase

@end

@implementation BUCAutoObjectTests

- (void)testOutputEqualsInput
{
    //create object
    TestObject *input = [[TestObject alloc] init];
    input.publicString = @"Hello World";
    input.publicInteger = 5;
    input.publicUncodable = 7;
    input.dynamicProperty = @"Foobar";
    [input setUpReadonlyAndPrivateData];
    
    //save object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:input];
    
    //load object
    TestObject *output = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //check eligible values are saved
    XCTAssertEqualObjects([output publicString], [input publicString], @"Public string test failed");
    XCTAssert(output.publicInteger == input.publicInteger, @"Public integer test failed");
    XCTAssert(output.readonlyIntegerWithSupportedIvar == input.readonlyIntegerWithSupportedIvar, @"Readonly integer with KVC-compliant ivar test failed");
    XCTAssert([output privateDataIsEqual:input], @"Private integer test failed");
    XCTAssertEqualObjects([output dynamicProperty], [input dynamicProperty], @"Dynamic string test failed");
    
    //check ineligible values are not saved
    XCTAssert(output.publicUncodable != input.publicUncodable, @"Public uncodable test failed");
    XCTAssert(![output privateUncodableIsEqual:input], @"Private uncodable test failed");
    XCTAssert(output.readonlyIntegerWithUnsupportedIvar != input.readonlyIntegerWithUnsupportedIvar, @"Readonly integer without KVC-compliant ivar test failed");
    XCTAssert(output.readonlyIntegerWithPrivateSetter != input.readonlyIntegerWithPrivateSetter, @"Readonly integer with private setter test failed");
    XCTAssertNotEqualObjects([output readonlyDynamicProperty], [input readonlyDynamicProperty], @"Readonly dynamic string test failed");
}

- (void)testCopy
{
    //create object
    TestObject *input = [[TestObject alloc] init];
    input.publicString = @"Hello World";
    input.publicInteger = 5;
    input.publicUncodable = 7;
    input.dynamicProperty = @"Foobar";
    [input setUpReadonlyAndPrivateData];
    
    //load object
    TestObject *output = [input copy];
    
    //check eligible values are saved
    XCTAssertEqualObjects([output publicString], [input publicString], @"Public string test failed");
    XCTAssert(output.publicInteger == input.publicInteger, @"Public integer test failed");
    XCTAssert(output.readonlyIntegerWithSupportedIvar == input.readonlyIntegerWithSupportedIvar, @"Readonly integer with KVC-compliant ivar test failed");
    XCTAssert([output privateDataIsEqual:input], @"Private integer test failed");
    XCTAssertEqualObjects([output dynamicProperty], [input dynamicProperty], @"Dynamic string test failed");
    
    //check ineligible values are not saved
    XCTAssert(output.publicUncodable != input.publicUncodable, @"Public uncodable test failed");
    XCTAssert(![output privateUncodableIsEqual:input], @"Private uncodable test failed");
    XCTAssert(output.readonlyIntegerWithUnsupportedIvar != input.readonlyIntegerWithUnsupportedIvar, @"Readonly integer without KVC-compliant ivar test failed");
    XCTAssert(output.readonlyIntegerWithPrivateSetter != input.readonlyIntegerWithPrivateSetter, @"Readonly integer with private setter test failed");
    XCTAssertNotEqualObjects([output readonlyDynamicProperty], [input readonlyDynamicProperty], @"Readonly dynamic string test failed");
}

- (void)testIsEqual
{
    //create object
    TestObject *input = [[TestObject alloc] init];
    input.publicString = nil;
    input.publicInteger = 5;
    input.publicUncodable = 7;
    input.dynamicProperty = @"Foobar";
    // Do not include read-only dynamic property
    
    //load object
    TestObject *duplicate = [input copy];
    
    TestObject* altered = [input copy];
    [altered setPublicInteger: 8];
    
    XCTAssertEqualObjects(input, duplicate, @"Copy is equal to input test failed");
    
    XCTAssertNotEqualObjects(input, altered, @"Altered copy is equal to input test failed");
}

- (void)testSecureCoding
{
    //create object
    TestObject *input = [[TestObject alloc] init];
    input.publicString = (NSString *)@5; //deliberate type mismatch
    
    //save object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:input];
    
    BOOL didCrash = NO;
    @try
    {
        //load object (should crash)
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        [unarchiver setRequiresSecureCoding:YES];
        [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    }
    @catch (NSException *exception)
    {
        didCrash = YES;
    }
    @finally
    {
        XCTAssert(didCrash, @"Decoding invalid object type failed");
    }
}

@end
