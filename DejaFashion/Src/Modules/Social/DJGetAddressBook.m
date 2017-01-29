//
//  DJGetAddressBook.m
//  DejaFashion
//
//  Created by jiao qing on 21/3/16.
//  Copyright © 2016 Mozat. All rights reserved.
//
#import "DejaFashion-swift.h"
#import "DJGetAddressBook.h"
#import <AddressBook/AddressBook.h>

@interface DJGetAddressBook ()
@property (nonatomic, assign) ABAddressBookRef addressBookRef;

@end


@implementation DJGetAddressBook

-(void)getContacts:(void (^)())completion{
    CFErrorRef error;
    _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            [self getContactsFromAddressBook];
        }
        if (completion) {
            completion();
        }
    });
}

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return;
    }
    NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    self.contacts = [NSMutableArray arrayWithCapacity:allContacts.count];
    
    NSUInteger i = 0;
    for (i = 0; i<[allContacts count]; i++)
    {
        ABContact *contact = [ABContact new];
        ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
        // contact.recordId = ABRecordGetRecordID(contactPerson);
        
        ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
        NSString *phoneNumber = [self getMobilePhoneProperty:phonesRef];
        if(phonesRef) {
            CFRelease(phonesRef);
        }
        if (phoneNumber) {
            contact.phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        }else{
            continue;
        }
        
        NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
        if (firstName) {
            contact.firstName = firstName;
        }
        if (lastName) {
            contact.lastName = lastName;
        }
        
        NSData *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
        if (imgData){
            contact.imageData = imgData;
        }
        [self.contacts addObject:contact];
    }
    
    if(addressBook) {
        CFRelease(addressBook);
    }
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i = 0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            NSString *tmp = (__bridge NSString *)currentPhoneValue;
            CFRelease(currentPhoneLabel);
            
            if(currentPhoneValue) {
                CFRelease(currentPhoneValue);
            }
            return tmp;
        }
        
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

@end
