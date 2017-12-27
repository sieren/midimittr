//  Copyright (c) 2014 Matthias Frick. All rights reserved.

#import "MIDIController.h"
#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "PTMidimittrProtocol.h"
#import "PGMidi.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

id thisClass;
@interface MIDIController() <PGMidiDelegate, PGMidiSourceDelegate> {
    MIDIClientRef   theMidiClient;
    MIDIEndpointRef midiOut;
    MIDIEndpointRef midiIn;
    MIDIPortRef     outPort;
    MIDIPortRef     inPort;
    PTChannel *peerChannel_;
}
@property (nonatomic, strong) NSMutableArray *entities;
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation MIDIController
@synthesize midi, selectDestinations, selectSources, destinations, sources, savedSources, savedDestinations;

-(id)init
{
  self = [super init];
  thisClass = self;
  [self initDefaults];
  self.selectSources = [[NSMutableSet alloc] init];
  self.selectDestinations = [[NSMutableSet alloc] init];
  self.midi = [[PGMidi alloc] init];
  self.midi.delegate = self;
  self.midi.networkEnabled = YES;
  [self attachToAllExistingSources];

  self.sources = midi.sources;
  self.destinations = midi.destinations;

  return self;
}


-(void)initDefaults {
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Sources"] != nil) {
    self.savedSources = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Sources"]];
  }
  else {
    self.savedSources = [NSMutableArray new];
  }
  if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"Destinations"] != nil) {
    self.savedDestinations = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Destinations"]];
  }
  else {
    self.savedDestinations = [NSMutableArray new];
  }
}


-(void)didSelectSourceAtIndexPath:(NSIndexPath*)indexPath
{
  if ([selectSources containsObject:[sources objectAtIndex:indexPath.row]])
  {
    PGMidiSource *src = [sources objectAtIndex:indexPath.row];
    [selectSources removeObject:src];
    if ([savedSources containsObject:src.name])
    {
      [savedSources removeObject:src.name];
    }
  } else {
    [selectSources addObject:[sources objectAtIndex:indexPath.row]];
  }
  [self saveSelection];
}


-(void)didSelectDestinationAtIndexPath:(NSIndexPath*)indexPath
{
  if ([selectDestinations containsObject:[destinations objectAtIndex:indexPath.row]])
  {
    [selectDestinations removeObject:[destinations objectAtIndex:indexPath.row]];
  } else {
    [selectDestinations addObject:[destinations objectAtIndex:indexPath.row]];
  }
  [self saveSelection];
}


-(NSString*)sourceNameAtIndex:(NSInteger)index
{
  PGMidiSource *src = self.midi.sources[index];
  return src.name;
}


-(NSString*)destinationNameAtIndex:(NSInteger)index
{
  PGMidiDestination *dst = self.midi.destinations[index];
  return dst.name;
}


-(void)sendMidiMessage:(MIDIPacket *) packet {
    char pktBuffer[2048];
    MIDIPacketList* pktList = (MIDIPacketList*) pktBuffer;
    MIDIPacket     *pkt;
    pkt = MIDIPacketListInit(pktList);
    pkt = MIDIPacketListAdd(pktList, 2048, pkt, 0, packet->length, packet->data);
    if (pkt == NULL || MIDIReceived(midiOut, pktList)) {
      NSAssert(true, @"Failed to send MIDI");
    }
}


-(void)didEstablishUSBConnection:(PTChannel *) peerChan {
    peerChannel_ = peerChan;
    MIDIClientCreate(CFSTR("midimittr"), NULL, NULL,
      &theMidiClient);
    MIDISourceCreate(theMidiClient, CFSTR("midimittr USB Source"),
      &midiOut);
    MIDIOutputPortCreate(theMidiClient, CFSTR("midimittr Out Port"),
      &outPort);
    MIDIDestinationCreate(theMidiClient, CFSTR("midimittr USB Destination"), ReadProc,  (__bridge void *)self, &midiIn);
}


-(void)didCancelUSBConnection {
  MIDIClientDispose(theMidiClient);
}


void ReadProc(const MIDIPacketList *packetList, void *readProcRefCon, void *srcConnRefCon) {
  for (int i = 0; i < packetList->numPackets; i++)
  {
    const MIDIPacket *packet = &packetList->packet[0];
    [thisClass sendDataToUSB:packet->data size:packet->length];
    packet = MIDIPacketNext(packet);
  }
}


-(void)startBackgrounding {
  NSError *sessionError = nil;
  [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
  
  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"silence" withExtension:@"mp3"]];
  
  if ([self player] == nil) {
    [self setPlayer:[[AVPlayer alloc] initWithPlayerItem:item]];
  }
  NSString *error = [NSString stringWithFormat:@"Starting Audio Session failed: %@", sessionError.description];
  NSAssert(!sessionError, error);
  [[self player] play];
  [[self player] setActionAtItemEnd:AVPlayerActionAtItemEndNone];
}


-(void)stopBackgrounding {
  if ([self player] == nil) {
    return;
  }
  NSError *sessionError = nil;
  
  [[self player] pause];
  [[self player] setActionAtItemEnd:AVPlayerActionAtItemEndPause];
  [self setPlayer:nil];
  [[AVAudioSession sharedInstance] setActive:NO error:&sessionError];
}


-(void)setMidiPortsDelegate:(id)newDelegate {
  midiPortsDelegate = newDelegate;
}


NSString *getDisplayName(MIDIObjectRef object) {
  // Returns the display name of a given MIDIObjectRef as an NSString
  CFStringRef name = nil;
  if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name)) {
    return nil;
  }
  return (__bridge NSString *)name;
}


-(void)midiSource:(PGMidiSource*)midisrc midiReceived:(const MIDIPacketList *)packetList
{
  if (self.activityCallback) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.activityCallback();
    });
  }
  if ([self.selectSources containsObject:midisrc]) {
    for (PGMidiDestination *dest in selectDestinations) {
      if (![dest.name isEqualToString:midisrc.name]) {
        if([dest.name isEqualToString:@"midimittr USB Destination"]) {
          const MIDIPacket *packet = &packetList->packet[0];
          for (int i = 0; i < packetList->numPackets; ++i) {
            [self sendDataToUSB:packet->data size:packet->length];
            packet = MIDIPacketNext(packet);
          }
        } else {
          const MIDIPacket *packet = &packetList->packet[0];
          for (int i = 0; i < packetList->numPackets; ++i) {
            char pktBuffer[1024];
            MIDIPacketList* pktList = (MIDIPacketList*) pktBuffer;
            MIDIPacket *pkt;
            pkt = MIDIPacketListInit(pktList);
            pkt = MIDIPacketListAdd(pktList, 1024, pkt, 0, packet->length, packet->data);
            [dest sendPacketList:pktList];
            packet = MIDIPacketNext(packet);
          }
        }
      }
    }
  }
}


-(void)saveSelection
{
  if (savedSources == nil) {
    savedSources = [[NSMutableArray alloc] initWithCapacity:[self.selectSources count]];
  }
  for (PGMidiSource *source in self.selectSources) {
    if (![savedSources containsObject:source.name]) {
      [savedSources addObject:source.name];
    }
  }
  [[NSUserDefaults standardUserDefaults] setObject:savedSources forKey:@"Sources"];

  if (savedDestinations == nil) {
    savedDestinations = [[NSMutableArray alloc] initWithCapacity:[self.selectDestinations count]];
  }
  for (PGMidiSource *destination in self.selectDestinations) {
    if (![savedDestinations containsObject:destination.name]) {
      [savedDestinations addObject:destination.name];
    }
  }
  [[NSUserDefaults standardUserDefaults] setObject:savedSources forKey:@"Sources"];
  [[NSUserDefaults standardUserDefaults] setObject:savedDestinations forKey:@"Destinations"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)sendDataToUSB:(const UInt8 *)data size:(UInt32)size {

    if (peerChannel_) {
      dispatch_data_t payload = PTMidimittrTextDispatchDataWithBytes(data, size);
      [peerChannel_ sendFrameOfType:PTMidimittrFrameTypeTextMessage tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
        if (error) {
          NSLog(@"Failed to send message: %@", error);
        }
      }];
    } else {
      NSLog(@"No Peer Found");
    }
}


-(void)logToConsole:(NSString *)text {
#ifdef DEBUG
  NSLog(@"%@", text);
#endif
}


- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
  [source addDelegate:self];
  if (![self.sources containsObject:source]) {
        [self.sources addObject:source];
  }
  if ([self.savedSources containsObject:source.name]) {
    [self.selectSources addObject:source];
  }
  [midiPortsDelegate updateResources];
  [self logToConsole:[NSString stringWithFormat:@"Source added: %@", ToString(source)]];
}


- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
  [self.sources removeObject:source];
  if ([self.selectSources containsObject:source]) {
        [self.selectSources removeObject:source];
  }
  [midiPortsDelegate updateResources];
  [self logToConsole:[NSString stringWithFormat:@"Source removed: %@", ToString(source)]];
}


- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination {
  if (![self.destinations containsObject:destination]) {
    [self.destinations addObject:destination];
  }
  if ([self.savedDestinations containsObject:destination.name]) {
    [self.selectDestinations addObject:destination];
  }
  [midiPortsDelegate updateResources];
  [self logToConsole:[NSString stringWithFormat:@"Desintation added: %@", ToString(destination)]];
}


- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
  [self.destinations removeObject:destination];
  if ([self.selectDestinations containsObject:destination]) {
    [self.selectDestinations removeObject:destination];
  }
  [midiPortsDelegate updateResources];
  [self logToConsole:[NSString stringWithFormat:@"Desintation removed: %@", ToString(destination)]];
}

const char *ToString(BOOL b) {
  return b ? "yes":"no";
}

static NSString *ToString(PGMidiConnection *connection) {
  return [NSString stringWithFormat:@"< PGMidiConnection: name=%@ isNetwork=%s >",
    connection.name, ToString(connection.isNetworkSession)];
}


- (void) attachToAllExistingSources {
  for (PGMidiSource *source in midi.sources)
  {
    [source addDelegate:self];
    if ([self.savedSources containsObject:source.name]) {
      [self.selectSources addObject:source];
    }
  }
  for (PGMidiDestination *destination in midi.destinations)
  {
    if ([self.savedDestinations containsObject:destination.name]) {
      [self.selectDestinations addObject:destination];
    }
  }
}

@end
