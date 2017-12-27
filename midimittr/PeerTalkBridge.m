//  Copyright © 2014 Matthias Frick. All rights reserved.

#import "PeerTalkBridge.h"
#import "PTMidimittrProtocol.h"
#include <assert.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>
#import "MIDIController.h"

@interface PeerTalkBridge()
{
  __weak PTChannel *serverChannel_;
  __weak PTChannel *peerChannel_;
}
- (void)logMessage:(NSString*)message;
- (void)sendDeviceInfo;
@property (nonatomic, strong) PTChannel *channel;
@property (nonatomic, strong) id<PeerTalkMidiProtocol> midiDelegate;
@property (nonatomic) BOOL isActive;
@end

@implementation PeerTalkBridge
@synthesize channel, connectionViewDelegate, isActive, connectionState = _connectionState;

-(void)setConnectionState: (ConnectionState)connectionState {
  _connectionState = connectionState;
  [self didChangeValueForKey:@"connectionState"];
}

-(ConnectionState)connectionState {
  return _connectionState;
}

-(void)setActive:(BOOL)active {
  isActive = active;
  if (!active) {
    if ([peerChannel_ isConnected]) {
      [peerChannel_ cancel];
      [self.channel cancel];
      [serverChannel_ cancel];
    }
    self.channel = nil;
    peerChannel_ = nil;
    serverChannel_ = nil;
    self.connectionState = disabled;
  } else {
    self.connectionState = [peerChannel_ isConnected] ? connected : disconnected;
  }
  [self checkAndRestartNetwork];
}


-(id)initWithMidiDelegate:(id<PeerTalkMidiProtocol>) delegate
{
  self = [super init];
  if (self)
  {
    self.midiDelegate = delegate;
  }
  [self checkAndRestartNetwork];
  return self;
}


-(void)checkAndRestartNetwork
{
  if (![peerChannel_ isConnected] && isActive)
  {
    self.channel = [PTChannel channelWithDelegate:self];
    [self.channel listenOnPort:PTMidimittrProtocolIPv4PortNumber IPv4Address:INADDR_LOOPBACK callback:nil];
  }
}


- (void)logMessage:(NSString*)message {
  NSLog(@">> %@", message);
}


#pragma mark - Communicating

- (void)sendDeviceInfo {
  if (!peerChannel_) {
    return;
  }
  UIScreen *screen = [UIScreen mainScreen];
  CGSize screenSize = screen.bounds.size;
  NSDictionary *screenSizeDict = (__bridge_transfer NSDictionary*)CGSizeCreateDictionaryRepresentation(screenSize);
  UIDevice *device = [UIDevice currentDevice];
  NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                        device.localizedModel, @"localizedModel",
                        [NSNumber numberWithBool:device.multitaskingSupported], @"multitaskingSupported",
                        device.name, @"name",
                        (UIDeviceOrientationIsLandscape(device.orientation) ? @"landscape" : @"portrait"), @"orientation",
                        device.systemName, @"systemName",
                        device.systemVersion, @"systemVersion",
                        screenSizeDict, @"screenSize",
                        [NSNumber numberWithDouble:screen.scale], @"screenScale",
                        nil];
  dispatch_data_t payload = [info createReferencingDispatchData];
  [peerChannel_ sendFrameOfType:PTMidimittrFrameTypeDeviceInfo tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
    if (error) {
      [self logMessage:[NSString stringWithFormat:@"Failed to send PTMidimittrFrameTypeDeviceInfo: %@", error]];
    }
  }];
}


#pragma mark - PTChannelDelegate

// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
  if (channel != peerChannel_ && !isActive) {
    // A previous channel that has been canceled but not yet ended. Ignore.
    return NO;
  } else if (type != PTMidimittrFrameTypeTextMessage && type != PTMidimittrFrameTypePing) {
    [self logMessage:[NSString stringWithFormat:@"Unexpected frame of type %u", type]];
    [channel close];
    return NO;
  } else {
    return YES;
  }
}


// Invoked when a new frame has arrived on a channel.
- (void)ioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload {
  if (type == PTMidimittrFrameTypeTextMessage) {
    PTMidimittrTextFrame *textFrame = (PTMidimittrTextFrame*)payload.data;
    textFrame->length = ntohl(textFrame->length);
    uint8_t *text = textFrame->utf8text;
    struct MIDIPacket packet;
    packet.timeStamp = mach_absolute_time();
    packet.length = textFrame->length;
    for (int i= 0; i<textFrame->length; i++) {
      packet.data[i] = text[i];
    }
    [self.midiDelegate sendMidiMessage:&packet];
  } else if (type == PTMidimittrFrameTypePing && peerChannel_) {
    [peerChannel_ sendFrameOfType:PTMidimittrFrameTypePong tag:tag withPayload:nil callback:nil];
  }
}


// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
  if (error) {
    [self logMessage:[NSString stringWithFormat:@"%@ ended with error: %@", channel, error]];
    [self.channel close];
    [self checkAndRestartNetwork];
  } else {
    [self logMessage:[NSString stringWithFormat:@"Disconnected from %@", channel.userInfo]];
  }
  self.connectionState = isActive ? disconnected : disabled;
  [self.midiDelegate didCancelUSBConnection];
  if (connectionViewDelegate) {
    [connectionViewDelegate didDisconnectFromUSB];
  }
}


// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)ioFrameChannel:(PTChannel*)channel didAcceptConnection:(PTChannel*)otherChannel fromAddress:(PTAddress*)address {
  // Cancel any other connection. We are FIFO, so the last connection
  // established will cancel any previous connection and "take its place".
  if (peerChannel_) {
    [self.midiDelegate didCancelUSBConnection];
    if (connectionViewDelegate) {
      [connectionViewDelegate didDisconnectFromUSB];
    }
    [peerChannel_ cancel];
  }

  // Weak pointer to current connection. Connection objects live by themselves
  // (owned by its parent dispatch queue) until they are closed.
  peerChannel_ = otherChannel;
  peerChannel_.userInfo = address;
  [self logMessage:[NSString stringWithFormat:@"Connected to %@", address]];
  
  // Send some information about ourselves to the other end
  [self sendDeviceInfo];
  if (connectionViewDelegate) {
    [connectionViewDelegate didConnectToUSB];
  }
  self.connectionState = connected;
  [self.midiDelegate didEstablishUSBConnection:peerChannel_];
}

@end
