//
//  STXComment.m
//  STXDynamicTableView
//
//  Created by Jesse Armand on 27/1/14.
//  Copyright (c) 2014 2359 Media. All rights reserved.
//

#import "STXComment.h"
#import "STXUser.h"

@interface STXComment ()

@property (copy, nonatomic) NSString *commentID;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSDate *postDate;
@property (copy, nonatomic) NSDictionary *fromDictionary;

@end

@implementation STXComment

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_commentID forKey:@"commentID"];
    [encoder encodeObject:_text forKey:@"text"];
    [encoder encodeObject:_postDate forKey:@"postDate"];
    [encoder encodeObject:_fromDictionary forKey:@"fromDictionary"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _commentID = [decoder decodeObjectForKey:@"commentID"];
        _text = [decoder decodeObjectForKey:@"text"];
        _postDate = [decoder decodeObjectForKey:@"postDate"];
        _fromDictionary = [decoder decodeObjectForKey:@"fromDictionary"];
    }
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    STXComment *theCopy = [[[self class] allocWithZone:zone] init];
    [theCopy setCommentID:[_commentID copy]];
    [theCopy setText:[_text copy]];
    [theCopy setPostDate:[_postDate copy]];
    [theCopy setFromDictionary:[_fromDictionary copy]];
    
    return theCopy;
}

#pragma mark - Initializers

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        NSArray *errors;
        NSDictionary *mappingDictionary = @{ @"id": KZProperty(commentID),
                                             @"text": KZProperty(text),
                                             @"created_time": KZBox(Date, postDate),
                                             @"from": KZProperty(fromDictionary) };
        
        [KZPropertyMapper mapValuesFrom:dictionary toInstance:self usingMapping:mappingDictionary errors:&errors];
    }
    return self;
}

- (NSUInteger)hash
{
    return [_commentID hash];
}

- (BOOL)isEqualToComment:(STXComment *)comment
{
    return [comment.commentID isEqualToString:_commentID];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[STXComment class]]) {
        return NO;
    }
    
    return [self isEqualToComment:(STXComment *)object];
}

- (NSString *)description
{
    NSDictionary *dictionary = @{ @"commentID": self.commentID ? : @"",
                                  @"from": self.from ? [self.from username] : @"",
                                  @"text": self.text ? : @"" };
    return [NSString stringWithFormat:@"<%@: %p> %@", NSStringFromClass([self class]), self, dictionary];
}

#pragma mark - STXCommentItem

- (id<STXUserItem>)from
{
    STXUser *user = [[STXUser alloc] initWithDictionary:self.fromDictionary];
    return user;
}

@end
