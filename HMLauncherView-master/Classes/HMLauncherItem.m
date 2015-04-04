//
// Copyright 2014 Heiko Maaß (mail@heikomaass.de)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "HMLauncherItem.h"

@implementation HMLauncherItem

-(void) encodeWithCoder:(NSCoder*) coder {
	[coder encodeObject: _identifier forKey: @"identifier"];
	[coder encodeObject: _iconPath forKey: @"iconPath"];
	[coder encodeObject: _titleText forKey: @"titleText"];
    [coder encodeObject: _iconBackgroundPath forKey:@"iconBackgroundPath"];
}

-(id) initWithCoder:(NSCoder*) decoder {
	if (self = [super init]) {
        _identifier = [decoder decodeObjectForKey:@"identifier"];
        _iconPath   = [decoder decodeObjectForKey:@"iconPath"];
        _titleText  = [decoder decodeObjectForKey:@"titleText"];
        _iconBackgroundPath = [decoder decodeObjectForKey:@"iconBackgroundPath"];
    }
	return self;
}

@end
