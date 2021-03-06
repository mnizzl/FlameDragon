//
//  AIMagicalDelegate.m
//  FlameDragon
//
//  Created by sui toney on 12-11-8.
//  Copyright 2012 ms. All rights reserved.
//

#import "AIMagicalDelegate.h"
#import "MagicDefinition.h"
#import "DataDepot.h"
#import "FDRandom.h"
#import "Common.h"

@implementation AIMagicalDelegate

-(id) initWithCreature:(FDCreature *)c Layers:(ActionLayers *)l
{
	self = [super initWithCreature:c Layers:l];
	
	[self initDistanceResolver];
	
	return self;
}

-(void) takeAction
{
	NSLog(@"AIMagicalDelegate take action on creature %d", [creature getIdentifier]);
	if (!creature.pendingAction) {
		
		[self takeMagicAction];
	} else {
		
		[self takePendAction];
	}
}

-(void) takeMagicAction
{
	BattleField *field = [[layers getFieldLayer] getField];
	
    NSMutableArray *magicList = [self getAvailableMagic];
	
    if (magicList == nil || [magicList count] == 0) {
        [layers appendToCurrentActivityMethod:@selector(creaturePendAction:) Param1:creature Param2:nil];
        return;
    }
	
    NSMutableArray *canMagicList = [[NSMutableArray alloc] init];
    NSMutableArray *candidateList = [[NSMutableArray alloc] init];
    for (MagicDefinition *magic in magicList)
	{
        FDCreature *candidate = nil;
        if (magic.magicType == MagicType_Attack || magic.magicType == MagicType_Offensive) {
            candidate = [self findAffensiveTarget:magic];
        }
        else if (magic.magicType == MagicType_Recover || magic.magicType == MagicType_Defensive) {
            candidate = [self findDefensiveTarget:magic];
        }
	
        if (candidate != nil) {
            [canMagicList addObject:magic];
            [candidateList addObject:candidate];
        }
	}
    
    @try {
        if ([canMagicList count] == 0) {
            NSLog(@"Didn't find candidate.");
            [layers appendToCurrentActivityMethod:@selector(creaturePendAction:) Param1:creature Param2:nil];
            return;
        }
        
        int magicIndex = [self chooseMagicFromCandidate:canMagicList];
        MagicDefinition *selectedMagic = [canMagicList objectAtIndex:magicIndex];
        FDCreature *selectedCandidate = [candidateList objectAtIndex:magicIndex];
        
        if (selectedMagic == nil || selectedCandidate == nil) {
            NSLog(@"Didn't find candidate.");
            [layers appendToCurrentActivityMethod:@selector(creaturePendAction:) Param1:creature Param2:nil];
            return;
        }
        
        // Locate the Magic Position
        CGPoint magicPosition;
	CGPoint candidatePosition = [field getObjectPos:selectedCandidate];
	CGPoint creaturePosition = [field getObjectPos:creature];
	int directX = (candidatePosition.x > creaturePosition.x) ? 1 : -1;
	int directY = (candidatePosition.y > creaturePosition.y) ? 1 : -1;
	int distanceX = [Common getAbs:candidatePosition.x - creaturePosition.x];
	int distanceY = [Common getAbs:candidatePosition.y - creaturePosition.y];
	
	if (selectedMagic.effectScope >= distanceX + distanceY) {
		magicPosition = candidatePosition;
	} else if (selectedMagic.effectScope >= distanceX) {
		int dy = (selectedMagic.effectScope - distanceX) * directY;
		magicPosition = CGPointMake(candidatePosition.x, creaturePosition.y + dy);
	} else {
		int dx = selectedMagic.effectScope * directX;
		magicPosition = CGPointMake(creaturePosition.x + dx, creaturePosition.y);
	}

	// Use Magic
        [field setCursorTo:magicPosition];
        
        [layers magicFrom:creature TargetPos:magicPosition Id:selectedMagic.identifier];
        // [layers appendToCurrentActivityMethod:@selector(creatureEndTurn:) Param1:creature Param2:nil];
        
    }
    @finally {
        [canMagicList release];
        [candidateList release];
    }
}

-(void) takePendAction
{
	BattleField *field = [[layers getFieldLayer] getField];

	NSLog(@"takePendAction");
	FDCreature *target = [self findTarget];
	if (target != nil) {
		NSLog(@"target != nil");
		CGPoint targetPos = [self generatePos:[field getObjectPos:target]];
		NSLog(@"generated targetPos.");
		[field setCursorTo:targetPos];
		[layers moveCreature:creature To:targetPos showMenu:FALSE];
	}
	
    
    
	NSLog(@"End Pend Action;");
	[layers appendToCurrentActivityMethod:@selector(takeAttackAction) Param1:creature Param2:nil Obj:self];
}

-(void) takeAttackAction {
    
    BattleField *field = [[layers getFieldLayer] getField];
    FDRange *range = [creature attackRange];
	
    FDCreature *attackTarget = nil;
    
    NSMutableArray *targetList = [NSMutableArray arrayWithArray:[field getFriendList]];
    [targetList addObjectsFromArray:[field getNpcList]];
    
    for (FDCreature *target in targetList) {
        if (target != nil && [creature isAbleToAttack:target]
		&& (range != nil && [range containsValue:[field getDirectDistance:creature And:target]])) {
            attackTarget = target;
            break;
        }
    }
	
    if (attackTarget != nil) {
		[layers appendToCurrentActivityMethod:@selector(attackFrom:Target:) Param1:creature Param2:attackTarget];
	}
	else {
		[layers appendToCurrentActivityMethod:@selector(creatureEndTurn:) Param1:creature Param2:nil];
	}
}

-(FDCreature *) findAffensiveTarget:(MagicDefinition *)magic
{
    NSLog(@"finding Affensive Target for %d, %d %d", magic.identifier, magic.effectScope, magic.effectRange);
	BattleField *field = [[layers getFieldLayer] getField];
	
	NSMutableArray *candidateList = [[NSMutableArray alloc] init];
    
    if ([creature getCreatureType] == CreatureType_Enemy) {
        [candidateList addObjectsFromArray:[field getFriendList]];
        [candidateList addObjectsFromArray:[field getNpcList]];
	} else {
        [candidateList addObjectsFromArray:[field getEnemyList]];
    }
    
	FDCreature *candidate = nil;
	for (FDCreature *c in candidateList) {
		
		if (![c isNoticable]) {
			continue;	
		}
		
		float distance = [field getDirectDistance:creature And:c];
		
		if (distance <= magic.effectScope + magic.effectRange) {
			if (candidate == nil || candidate.data.hpCurrent > c.data.hpCurrent) {
				candidate = c;
			}
		}
	}
	
	[candidateList release];
	return candidate;
}

-(FDCreature *) findDefensiveTarget:(MagicDefinition *)magic
{
	BattleField *field = [[layers getFieldLayer] getField];
	
	NSMutableArray *candidateList = [[NSMutableArray alloc] init];
	
    if ([creature getCreatureType] == CreatureType_Enemy) {
        [candidateList addObjectsFromArray:[field getEnemyList]];
    } else {
        [candidateList addObjectsFromArray:[field getFriendList]];
        [candidateList addObjectsFromArray:[field getNpcList]];
    }
    
	FDCreature *candidate = nil;
	for (FDCreature *c in candidateList) {
		
		float distance = [field getDirectDistance:creature And:c];
		
		if (distance <= magic.effectScope + magic.effectRange) {
			if ([magic hasDefensiveEffectOn:c] && c.data.hpCurrent < c.data.hpMax && (candidate == nil || candidate.data.hpCurrent > c.data.hpCurrent)) {
				candidate = c;
			}
		}
	}
	
	[candidateList release];
	return candidate;
}

-(NSMutableArray *) getAvailableMagic
{
	if (![creature canFireMagic]) {
		return nil;
	}
	
    NSMutableArray *magicList = [[NSMutableArray alloc] init];
    
	for (int index = [creature.data.magicList count] - 1; index >= 0; index--) {
		NSNumber *magicId = [creature.data.magicList objectAtIndex:index];
		MagicDefinition *magic = [[DataDepot depot] getMagicDefinition:[magicId intValue]];
	
		if (magic == nil) {
			continue;
		}
		
		if (creature.data.mpCurrent >= magic.mpCost) {
			[magicList addObject:magic];
		}
	}
	
	return [magicList autorelease];
}

-(int) chooseMagicFromCandidate:(NSMutableArray *)candidateMagicList {
    
    int totalConsideration = 0;
    
    for (MagicDefinition *magic in candidateMagicList) {
        totalConsideration += magic.aiConsiderRate;
    }
    
    int ranValue = [FDRandom from:0 to:totalConsideration];
    for (int i = 0; i < [candidateMagicList count]; i++) {
        MagicDefinition *magic = [candidateMagicList objectAtIndex:i];
        ranValue -= magic.aiConsiderRate;
        if (ranValue <= 0) {
            return i;
        }
    }
    return 0;
}


@end
