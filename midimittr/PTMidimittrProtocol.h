#ifndef peertalk_PTMidimittrProtocol_h
#define peertalk_PTMidimittrProtocol_h
#import <UIKit/UIKit.h>
#include <CoreMIDI/MIDIServices.h>
#import <Foundation/Foundation.h>
#include <stdint.h>

static const int PTMidimittrProtocolIPv4PortNumber = 2349;

enum {
  PTMidimittrFrameTypeDeviceInfo = 100,
  PTMidimittrFrameTypeTextMessage = 101,
  PTMidimittrFrameTypePing = 102,
  PTMidimittrFrameTypePong = 103,
};

typedef struct _PTMidimittrTextFrame {
  uint32_t length;
  uint8_t utf8text[0];
  MIDIPacketList list;
} PTMidimittrTextFrame;


static dispatch_data_t PTMidimittrTextDispatchDataWithString(const MIDIPacketList *message) {
  // Use a custom struct
    PTMidimittrTextFrame *textFrame;
  // const char *utf8text = [message cStringUsingEncoding:NSUTF8StringEncoding];
  size_t length = sizeof(message);
 textFrame = (PTMidimittrTextFrame*)CFAllocatorAllocate(nil, sizeof(PTMidimittrTextFrame) + length, 0);
  memcpy(textFrame->utf8text, message, length); // Copy bytes to utf8text array
  textFrame->length = htonl(length); // Convert integer to network byte order
  
  // Wrap the textFrame in a dispatch data object
  return dispatch_data_create((const void*)textFrame, sizeof(PTMidimittrTextFrame)+length, nil, ^{
    CFAllocatorDeallocate(nil, textFrame);
  });
}

static dispatch_data_t PTMidimittrTextDispatchDataWithBytes(const UInt8 *data,  UInt32 size) {
    // Use a custom struct
    PTMidimittrTextFrame *textFrame;
    // const char *utf8text = [message cStringUsingEncoding:NSUTF8StringEncoding];
    size_t length = size;
    textFrame = (PTMidimittrTextFrame*)CFAllocatorAllocate(nil, sizeof(PTMidimittrTextFrame) + length, 0);
    memcpy(textFrame->utf8text, data, length); // Copy bytes to utf8text array
    textFrame->length = htonl(length); // Convert integer to network byte order
    
    // Wrap the textFrame in a dispatch data object
    return dispatch_data_create((const void*)textFrame, sizeof(PTMidimittrTextFrame)+length, nil, ^{
        CFAllocatorDeallocate(nil, textFrame);
    });
}

static dispatch_data_t MIDIDataDispatchDataWithList(const MIDIPacketList *data,  UInt32 size) {
    // Use a custom struct
    PTMidimittrTextFrame *textFrame;
    // const char *utf8text = [message cStringUsingEncoding:NSUTF8StringEncoding];
    size_t length = size;
    textFrame = (PTMidimittrTextFrame*)CFAllocatorAllocate(nil, sizeof(PTMidimittrTextFrame) + length, 0);
    memcpy(textFrame->utf8text, data, length); // Copy bytes to utf8text array
    textFrame->length = htonl(length); // Convert integer to network byte order
    
    // Wrap the textFrame in a dispatch data object
    return dispatch_data_create((const void*)textFrame, sizeof(PTMidimittrTextFrame)+length, nil, ^{
        CFAllocatorDeallocate(nil, textFrame);
    });
}

#endif
