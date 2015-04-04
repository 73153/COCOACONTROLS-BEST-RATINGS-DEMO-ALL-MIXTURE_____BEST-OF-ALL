//
//  StringHelper.m
//  
//
//  Created by Sergio on 22/10/10.
//  Copyright 2010 Sergio. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (helper)

- (NSString*) substringFrom: (NSInteger) a to: (NSInteger) b {
	NSRange r;
	r.location = a;
	r.length = b - a;
	return [self substringWithRange:r];
}

- (NSInteger) indexOf: (NSString*) substring from: (NSInteger) starts {
	NSRange r;
	r.location = starts;
	r.length = [self length] - r.location;
	
	NSRange index = [self rangeOfString:substring options:NSLiteralSearch range:r];
	if (index.location == NSNotFound) {
		return -1;
	}
	return index.location + index.length;
}

- (NSString*) trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) startsWith:(NSString*) s {
	if([self length] < [s length]) return NO;
	return [s isEqualToString:[self substringFrom:0 to:[s length]]];
}

- (BOOL)containsString:(NSString *)aString
{
	NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
	return range.location != NSNotFound;
}

- (NSString *)urlEncodeCopy
{
	NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				   NULL,
																				   (CFStringRef) self,
																				   NULL,
																				   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				   kCFStringEncodingUTF8 );
	
    return [encodedString autorelease];
}

- (NSString *)reverseGeocode
{
	NSString *urlEncode = [self urlEncodeCopy];
	NSString *gUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&hl=%@&oe=UTF8", urlEncode, NSLocalizedString(@"language", @"")];
	
	NSString *infoData = [[[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:gUrl] 
														 encoding:NSUTF8StringEncoding 
															error:nil] autorelease];
	
	NSString *value = @"";
	
	if ((infoData == nil) || 
		([infoData isEqualToString:@"[]"])) 
	{
		return value;
	} 
	else 
	{
		NSDictionary *dict = [infoData JSONValue];
		NSArray* placemarks = [dict objectForKey:@"Placemark"];
		
		for (NSDictionary* placemark in placemarks) 
		{
			NSDictionary* point = [placemark objectForKey:@"Point"];
			NSArray* coordinates = [point objectForKey:@"coordinates"];
			value = [NSString stringWithFormat:@"%.10f,%.10f", [[coordinates objectAtIndex:0] doubleValue], [[coordinates objectAtIndex:1] doubleValue]];
			break;
		}
	}	
	
	return value;
}

- (NSString *)shortURL
{
	NSString *apiEndpoint = [NSString stringWithFormat:@"http://is.gd/api.php?longurl=%@", self];
	NSString *shortURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpoint]
												  encoding:NSASCIIStringEncoding
													 error:nil];
	
	return shortURL;
}

- (NSString *)reformatTelephone
{
    if ([self containsString:@"-"]) 
    {
        self = [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    if ([self containsString:@" "]) 
    {
        self = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if ([self containsString:@"("]) 
    {
        self = [self stringByReplacingOccurrencesOfString:@"(" withString:@""];
    }
    
    if ([self containsString:@")"]) 
    {
        self = [self stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    
    return self;
}

- (BOOL)containsNullString
{
    return ([[self lowercaseString] containsString:@"null"]) ? YES : NO;
}

@end
