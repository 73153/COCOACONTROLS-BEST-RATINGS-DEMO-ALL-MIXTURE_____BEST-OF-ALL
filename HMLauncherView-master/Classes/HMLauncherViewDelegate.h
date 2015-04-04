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

#import <Foundation/Foundation.h>

@class HMLauncherView;
@class HMLauncherIcon;
@protocol HMLauncherViewDelegate <NSObject>

@required
/**
   Returns the `HMLauncherView`, which should embed the icon, when the dragging ends.
   @param icon The icon which laucher home should be evaluated.
 **/
- (HMLauncherView*) targetLauncherViewForIcon:(HMLauncherIcon*) icon;


- (BOOL) launcherViewShouldStopEditingAfterDraggingEnds:(HMLauncherView *)launcherView;

@optional
- (void) launcherView:(HMLauncherView*) launcherView didStartDragging:(HMLauncherIcon*) icon;

- (void) launcherView:(HMLauncherView*) launcherView didStopDragging:(HMLauncherIcon*) icon;

- (void) launcherView:(HMLauncherView*) launcherView didTapLauncherIcon:(HMLauncherIcon*) icon;

- (void) launcherView:(HMLauncherView*) launcherView willAddIcon:(HMLauncherIcon*) icon;

- (void) launcherView:(HMLauncherView*) launcherView didDeleteIcon:(HMLauncherIcon*) icon;

- (void) launcherView:(HMLauncherView*) launcherView willMoveIcon:(HMLauncherIcon*) icon 
            fromIndex:(NSIndexPath*) fromIndex 
              toIndex:(NSIndexPath*) toIndex;


- (void) launcherViewDidAppear:(HMLauncherView *)launcherView;

- (void) launcherViewDidDisappear:(HMLauncherView *)launcherView;

- (void) launcherViewDidStartEditing:(HMLauncherView*) launcherView;

- (void) launcherViewDidStopEditing:(HMLauncherView*) launcherView;


@end
