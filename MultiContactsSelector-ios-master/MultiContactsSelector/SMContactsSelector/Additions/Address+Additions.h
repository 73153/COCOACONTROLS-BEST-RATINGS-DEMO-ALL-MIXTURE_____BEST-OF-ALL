//
//  Address+Additions.h
//  MultiContactsSelector
//
//  Created by Sergio on 19/01/12.
//  Copyright (c) 2012 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface NSObject (RecordID)

+ (NSArray *)getAllRecordIDs;

+ (ABRecordRef)infoWithRecordID:(NSInteger)recordID;

@end
