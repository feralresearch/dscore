//
//  DSDMXManager.h
//  OSCLight
//
//  Created by Andrew on 12/18/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Ftd2xx.h"
@class DSDMXBox;

// Enttec Pro definitions
#define GET_WIDGET_PARAMS 3
#define GET_WIDGET_SN 10
#define GET_WIDGET_PARAMS_REPLY 3
#define SET_WIDGET_PARAMS 4
#define SET_DMX_RX_MODE 5
#define SET_DMX_TX_MODE 6
#define SEND_DMX_RDM_TX 7
#define RECEIVE_DMX_ON_CHANGE 8
#define RECEIVED_DMX_COS_TYPE 9
#define ONE_BYTE 1
#define DMX_START_CODE 0x7E
#define DMX_END_CODE 0xE7
#define OFFSET 0xFF
#define DMX_HEADER_LENGTH 4
#define BYTE_LENGTH 8
#define HEADER_RDM_LABEL 5
#define NO_RESPONSE 0
#define DMX_PACKET_SIZE 512
#define DMX_DATA_LENGTH 513
#pragma pack(1)
typedef struct {
    unsigned char FirmwareLSB;
    unsigned char FirmwareMSB;
    unsigned char BreakTime;
    unsigned char MaBTime;
    unsigned char RefreshRate;
}DMXUSBPROParamsType;

typedef struct {
    unsigned char UserSizeLSB;
    unsigned char UserSizeMSB;
    unsigned char BreakTime;
    unsigned char MaBTime;
    unsigned char RefreshRate;
}DMXUSBPROSetParamsType;
#pragma pack()

struct ReceivedDmxCosStruct
{
    unsigned char start_changed_byte_number;
    unsigned char changed_byte_array[5];
    unsigned char changed_byte_data[40];
};

#define MAX_PROS 20
#define SEND_NOW 0
#define TRUE 1
#define FALSE 0
#define HEAD 0
#define IO_ERROR 9

@interface DSDMXManager : NSObject{
    DMXUSBPROParamsType PRO_Params;
    NSString* _statusMessage;
}

-(BOOL) error;
-(void)resetErrorMsg;

@property NSString* statusMessage;
@property (readonly) NSImage* statusLight;

@property (readonly) NSMutableArray *availableDevices;
@property (readonly) NSString* d2XXDriverVersion;

+(id)sharedInstance;
-(int) FTDI_ListDevices;
-(void) FTDI_ClosePort:(FT_HANDLE)device_handle;
-(BOOL) FTDI_SendData:(FT_HANDLE)device_handle label:(int)label data:(unsigned char*)data length:(int)length;
-(int) FTDI_ReceiveData:(FT_HANDLE)device_handle label:(int)label data:(unsigned char*)data expected_length:(unsigned int)expected_length;
-(DSDMXBox*) FTDI_OpenDevice:(int)device_num;
-(uint8_t) FTDI_RxDMX:(FT_HANDLE)device_handle label:(uint8_t)label data:(unsigned char *)data expected_length:(uint32_t*) expected_length;
-(void)shutDown;
-(void)FTDI_PurgeBuffer:(FT_HANDLE)device_handle;
@end
