//  Copyright (c) 2014 Matthias Frick. All rights reserved.

#import <Foundation/Foundation.h>
#import "PGMidi.h"
#import "PeerTalkBridge.h"
#import <Peertalk/peertalk.h>

@protocol MIDIControllerDelegate
-(void)updateResources;
@end

@interface MIDIController : NSObject<PeerTalkMidiProtocol> {
  PGMidi *midi;
  id midiPortsDelegate;
}

-(void)setMidiPortsDelegate:(id)newDelegate;
-(void)startBackgrounding;
-(void)stopBackgrounding;
-(void)saveSelection;
-(NSString*)sourceNameAtIndex:(NSInteger)index;
-(NSString*)destinationNameAtIndex:(NSInteger)index;
-(void)didSelectSourceAtIndexPath:(NSIndexPath*)indexPath;
-(void)didSelectDestinationAtIndexPath:(NSIndexPath*)indexPath;

@property (nonatomic, copy) void(^activityCallback)(void);
@property (nonatomic,strong) PGMidi *midi;
@property (nonatomic, strong) NSMutableArray *sources;
@property (nonatomic, strong) NSMutableArray *destinations;
@property (nonatomic, strong) NSMutableSet *selectSources;
@property (nonatomic, strong) NSMutableSet *selectDestinations;
@property (nonatomic, strong) NSMutableArray *savedDestinations;
@property (nonatomic, strong) NSMutableArray *savedSources;
@end
