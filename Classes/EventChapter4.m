//
//  EventChapter4.m
//  FlameDragon
//
//  Created by sui toney on 12-11-18.
//  Copyright 2012 ms. All rights reserved.
//

#import "EventChapter4.h"
#import "FDDurationActivity.h"
#import "FDEmptyActivity.h"

@implementation EventChapter4

-(void) loadEvents
{
	[self loadTurnEvent:TurnType_Friend Turn:0 Action:@selector(round1)];
	[self loadTurnEvent:TurnType_Friend Turn:4 Action:@selector(round4)];
	
	[self loadDyingEvent:40 Action:@selector(showBossDyingMessage)];
	
	[self loadDieEvent:1 Action:@selector(gameOver)];
	
	[self loadDieEvent:81 Action:@selector(oneDead)];
	[self loadDieEvent:82 Action:@selector(oneDead)];
	[self loadDieEvent:83 Action:@selector(oneDead)];
	[self loadDieEvent:84 Action:@selector(oneDead)];
	
	[self loadTeamEvent:CreatureType_Enemy Action:@selector(enemyClear)];
	
	NSLog(@"Chapter4 events loaded.");
}

-(void) round1
{
	NSLog(@"round1 event triggered.");
	
	// Creatures
	[self settleFriend:1 At:CGPointMake(11, 20)];
	[self settleFriend:2 At:CGPointMake(11, 20)];
	[self settleFriend:3 At:CGPointMake(11, 20)];
	[self settleFriend:4 At:CGPointMake(11, 20)];
	[self settleFriend:5 At:CGPointMake(11, 20)];
	[self settleFriend:6 At:CGPointMake(11, 20)];
	[self settleFriend:7 At:CGPointMake(11, 20)];
	
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:708 Id:21] autorelease] Position:CGPointMake(8, 6)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:708 Id:22] autorelease] Position:CGPointMake(10, 6)];
	
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:712 Id:23] autorelease] Position:CGPointMake(11, 5)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:712 Id:24] autorelease] Position:CGPointMake(14, 6)];
	
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:25] autorelease] Position:CGPointMake( 7, 5)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:26] autorelease] Position:CGPointMake( 9, 5)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:27] autorelease] Position:CGPointMake(13, 5)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:28] autorelease] Position:CGPointMake( 8, 4)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:29] autorelease] Position:CGPointMake(12, 4)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:30] autorelease] Position:CGPointMake(14, 4)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:31] autorelease] Position:CGPointMake( 6, 3)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:32] autorelease] Position:CGPointMake( 9, 3)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:33] autorelease] Position:CGPointMake(11, 3)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:34] autorelease] Position:CGPointMake(13, 3)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:35] autorelease] Position:CGPointMake(15, 3)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1701 Id:36] autorelease] Position:CGPointMake(10, 2)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:1702 Id:40] autorelease] Position:CGPointMake(10, 4)];
	
	
	[layers moveCreatureId:1 To:CGPointMake(11, 18) showMenu:FALSE];
	[layers appendToCurrentActivity:[[[FDDurationActivity alloc] initWithDuration:0.5] autorelease]];
	[layers appendToCurrentActivityMethod:@selector(setCursorObjTo:) Param1:[FDPosition positionX:11 Y:18] Param2:nil Obj:field];
	
	for (int i = 1; i <= 9; i++) {
		[self showTalkMessage:4 conversation:1 sequence:i];
	}
	
	// Add branch activities	
	[layers appendNewActivity:[[[FDEmptyActivity alloc] init] autorelease]];
	[layers moveCreatureId:2 To:CGPointMake(11, 19) showMenu:FALSE];
	
	[layers appendNewActivity:[[[FDEmptyActivity alloc] init] autorelease]];
	[layers moveCreatureId:3 To:CGPointMake(10, 19) showMenu:FALSE];
	
	[layers appendNewActivity:[[[FDEmptyActivity alloc] init] autorelease]];
	[layers moveCreatureId:4 To:CGPointMake(12, 19) showMenu:FALSE];
	
	[layers appendNewActivity:[[[FDEmptyActivity alloc] init] autorelease]];
	[layers moveCreatureId:5 To:CGPointMake(11, 20) showMenu:FALSE];
	
	[layers appendNewActivity:[[[FDEmptyActivity alloc] init] autorelease]];
	[layers moveCreatureId:6 To:CGPointMake(10, 20) showMenu:FALSE];
	
	[layers appendNewActivity:[[[FDEmptyActivity alloc] init] autorelease]];
	[layers moveCreatureId:7 To:CGPointMake(12, 20) showMenu:FALSE];
}


-(void) round4
{
	NSLog(@"round1 event triggered.");

	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:706 Id:81] autorelease] Position:CGPointMake(1, 9)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:706 Id:82] autorelease] Position:CGPointMake(20, 8)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:706 Id:83] autorelease] Position:CGPointMake(1, 19)];
	[field addEnemy:[[[FDEnemy alloc] initWithDefinition:706 Id:84] autorelease] Around:CGPointMake(11, 20)];
	
	for (int i = 1; i <= 4; i++) {
		[self showTalkMessage:4 conversation:2 sequence:i];
	}
}

-(void) oneDead
{
	[self showTalkMessage:4 conversation:3 sequence:1];
	
	[super setAiOfId:81 EscapeTo:CGPointMake( 1, 9)];
	[super setAiOfId:82 EscapeTo:CGPointMake(20, 8)];
	[super setAiOfId:83 EscapeTo:CGPointMake(1, 19)];
	[super setAiOfId:84 EscapeTo:CGPointMake(11, 20)];
	
	[self loadPositionEvent:81 AtPosition:CGPointMake( 1, 9) Action:@selector(onEscaped1)];
	[self loadPositionEvent:82 AtPosition:CGPointMake(20, 8) Action:@selector(onEscaped2)];
	[self loadPositionEvent:83 AtPosition:CGPointMake(1, 19) Action:@selector(onEscaped3)];
	[self loadPositionEvent:84 AtPosition:CGPointMake(11,20) Action:@selector(onEscaped4)];
}

-(void) onEscaped1
{
	FDCreature *c = [field getCreatureById:81];
	if (c != nil) {
		[field removeObject:c];
	}
}
-(void) onEscaped2
{
	FDCreature *c = [field getCreatureById:82];
	if (c != nil) {
		[field removeObject:c];
	}
}
-(void) onEscaped3
{
	FDCreature *c = [field getCreatureById:83];
	if (c != nil) {
		[field removeObject:c];
	}
}
-(void) onEscaped4
{
	FDCreature *c = [field getCreatureById:84];
	if (c != nil) {
		[field removeObject:c];
	}
}


@end