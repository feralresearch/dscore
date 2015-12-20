//
//  DSDMXManager.m
//  OSCLight
//
//  Created by Andrew on 12/18/15.
//  Copyright © 2015 Digital Scenographic. All rights reserved.
//
//  This code is based heavily on the USB_PRO_EXAMPLE code
//  from the Enttec Website http://www.enttec.com/
//
//  Creates a singleton manager object, under which may live one or more "Boxes" to which are connected "Lamps"

#import "DSDMXManager.h"
#import "DSDMXBox.h"

@implementation DSDMXManager

+ (id)sharedInstance {
    static DSDMXManager *myInstance = nil; //Local static variable
    
    //Using dispatch_once from GCD. This method is thread safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myInstance = [[self alloc] init];
    });
    return myInstance;
    
}
- (id)init{
    if (self = [super init]){
        [self scanForDevices];
    }
    return self;
}


-(long)scanForDevices{
    
    int devCount = [self FTDI_ListDevices];
    _availableDevices = [[NSMutableArray alloc] init];
    
    // Number of Found Devices
    if (devCount == 0){
        NSLog(@"WARNING: No ENTTEC devices found");
    }
    
    for (int device_num=0;device_num<devCount;device_num++){
        DSDMXBox *newBox =[self FTDI_OpenDevice:device_num];
        if(newBox){
            [_availableDevices addObject:newBox];
        }else{
            NSLog(@"ERROR: %i devices found, cannot connect to ID:%i ",devCount,device_num);
        }
    }
    
    return devCount;
}

/* Function : FTDI_ClosePort
 * Author	: ENTTEC
 * Purpose  : Closes the Open DMX USB PRO Device Handle
 * Parameters: none
 **/
-(void) FTDI_ClosePort:(FT_HANDLE)device_handle{
    if (device_handle != NULL)
        FT_Close(device_handle);
}

/* Function : FTDI_ListDevices
 * Author	: ENTTEC
 * Purpose  : Returns the no. of PRO's conneced to the PC
 * Parameters: none
 **/
-(int) FTDI_ListDevices{
    FT_STATUS ftStatus;
    DWORD numDevs=0;
    ftStatus = FT_ListDevices((PVOID)&numDevs,NULL,FT_LIST_NUMBER_ONLY);
    if(ftStatus == FT_OK)
        return numDevs;
    return NO_RESPONSE;
}


/* Function : FTDI_SendData
 * Author	: ENTTEC
 * Purpose  : Send Data (DMX or other packets) to the PRO
 * Parameters: Label, Pointer to Data Structure, Length of Data
 **/
-(BOOL) FTDI_SendData:(FT_HANDLE)device_handle label:(int)label data:(unsigned char*)data length:(int)length{
    unsigned char end_code = DMX_END_CODE;
    FT_STATUS res = 0;
    DWORD bytes_written = 0;
    // Form Packet Header
    unsigned char header[DMX_HEADER_LENGTH];
    header[0] = DMX_START_CODE;
    header[1] = label;
    header[2] = length & OFFSET;
    header[3] = length >> BYTE_LENGTH;
    // Write The Header
    res = FT_Write(	device_handle,(unsigned char *)header,DMX_HEADER_LENGTH,&bytes_written);
    if (bytes_written != DMX_HEADER_LENGTH) return  NO;
    // Write The Data
    res = FT_Write(	device_handle,(unsigned char *)data,length,&bytes_written);
    if (bytes_written != length) return  NO;
    // Write End Code
    res = FT_Write(	device_handle,(unsigned char *)&end_code,ONE_BYTE,&bytes_written);
    if (bytes_written != ONE_BYTE) return  NO;
    if (res == FT_OK)
        return TRUE;
    else
        return FALSE;
}

/* Function : FTDI_ReceiveData
 * Author	: ENTTEC
 * Purpose  : Receive Data (DMX or other packets) from the PRO
 * Parameters: Label, Pointer to Data Structure, Length of Data
 **/
-(int) FTDI_ReceiveData:(FT_HANDLE)device_handle label:(int)label data:(unsigned char*)data expected_length:(unsigned int)expected_length{
    FT_STATUS res = 0;
    DWORD length = 0;
    DWORD bytes_read =0;
    unsigned char byte = 0;
    char buffer[600];
    // Check for Start Code and matching Label
    while (byte != label)
    {
        while (byte != DMX_START_CODE)
        {
            res = FT_Read(device_handle,(unsigned char *)&byte,ONE_BYTE,&bytes_read);
            if(bytes_read== NO_RESPONSE) return  NO_RESPONSE;
        }
        res = FT_Read(device_handle,(unsigned char *)&byte,ONE_BYTE,&bytes_read);
        if (bytes_read== NO_RESPONSE) return  NO_RESPONSE;
    }
    // Read the rest of the Header Byte by Byte -- Get Length
    res = FT_Read(device_handle,(unsigned char *)&byte,ONE_BYTE,&bytes_read);
    if (bytes_read== NO_RESPONSE) return  NO_RESPONSE;
    length = byte;
    res = FT_Read(device_handle,(unsigned char *)&byte,ONE_BYTE,&bytes_read);
    if (res != FT_OK) return  NO_RESPONSE;
    length += ((uint32_t)byte)<<BYTE_LENGTH;
    // Check Length is not greater than allowed
    if (length > DMX_PACKET_SIZE)
        return  NO_RESPONSE;
    // Read the actual Response Data
    res = FT_Read(device_handle,buffer,length,&bytes_read);
    if(bytes_read != length) return  NO_RESPONSE;
    // Check The End Code
    res = FT_Read(device_handle,(unsigned char *)&byte,ONE_BYTE,&bytes_read);
    if(bytes_read== NO_RESPONSE) return  NO_RESPONSE;
    if (byte != DMX_END_CODE) return  NO_RESPONSE;
    // Copy The Data read to the buffer passed
    memcpy(data,buffer,expected_length);
    return TRUE;
}

/* Function : FTDI_PurgeBuffer
 * Author	: ENTTEC
 * Purpose  : Clears the buffer used internally by the PRO
 * Parameters: none
 **/
-(void) FTDI_PurgeBuffer:(FT_HANDLE)device_handle{
    FT_Purge (device_handle,FT_PURGE_TX);
    FT_Purge (device_handle,FT_PURGE_RX);
}


/* Function : FTDI_OpenDevice
 * Author	: ENTTEC
 * Purpose  : Opens the PRO; Tests various parameters; outputs info
 * Parameters: device num (returned by the List Device fuc), Fw Version MSB, Fw Version LSB
 **/
-(DSDMXBox*) FTDI_OpenDevice:(int)device_num{
    DSDMXBox* newBox=[[DSDMXBox alloc] initWithMgr:self];

    int RTimeout =120;
    int WTimeout =100;
    int VersionMSB =0;
    int VersionLSB =0;
    uint8_t temp[4];
    long version;
    uint8_t major_ver,minor_ver,build_ver;
    int size = 0;
    int res = 0;
    int tries =0;
    uint8_t latencyTimer;
    FT_STATUS ftStatus;
    

    
    // FIXME: Should wait between tries
    // Try at least 3 times
    do  {
        // Open the PRO
        FT_HANDLE handle;
        ftStatus = FT_Open(device_num,&handle);
        [newBox setDevice_handle:handle];
        tries ++;
    } while ((ftStatus != FT_OK) && (tries < 3));
    
    // PRO Opened succesfully
    if (ftStatus == FT_OK){
        
        // Reset device
        ftStatus = FT_CyclePort(newBox.device_handle);
        if (ftStatus == FT_OK) {
            // FT_ResetDevice OK
        }
        else {
            NSLog(@"WARNING: Failed to reset device");
        }
       
        
        
        // GET D2XX Driver Version
        ftStatus = FT_GetDriverVersion(newBox.device_handle,(LPDWORD)&version);
        if (ftStatus == FT_OK){
            major_ver = (uint8_t) version >> 16;
            minor_ver = (uint8_t) version >> 8;
            build_ver = (uint8_t) version & 0xFF;
            _d2XXDriverVersion = [NSString stringWithFormat:@"%02X.%02X.%02X ",major_ver,minor_ver,build_ver];
        
        }else{
            NSLog(@"WARNING: Unable to Get D2XX Driver Version");
        }
        
        
        // GET Latency Timer
        ftStatus = FT_GetLatencyTimer (newBox.device_handle,(PUCHAR)&latencyTimer);
        if (ftStatus == FT_OK){
            [newBox setLatencyTimer:latencyTimer];
        }
        
        // SET Default Read & Write Timeouts (in micro sec ~ 100)
        FT_SetTimeouts(newBox.device_handle,RTimeout,WTimeout);
        // Piurges the buffer
        FT_Purge (newBox.device_handle,FT_PURGE_RX);
        
        // Send r Parameters to get Device Info
        BOOL response = [self FTDI_SendData:newBox.device_handle label:GET_WIDGET_PARAMS data:(unsigned char *)&size length:2];
        
        // Check Response
        if (!response){
            FT_Purge (newBox.device_handle,FT_PURGE_TX);
            res = [self FTDI_SendData:newBox.device_handle label:GET_WIDGET_PARAMS data:(unsigned char *)&size length:2];
            if (!response){
                [self FTDI_ClosePort:newBox.device_handle];
                return  nil;
            }
        }
        
        // Receive Widget Response
        res=[self FTDI_ReceiveData:newBox.device_handle label:GET_WIDGET_PARAMS_REPLY
                              data:(unsigned char *)&PRO_Params
                   expected_length:sizeof(DMXUSBPROParamsType)];
        
        // Check Response
        if (res == NO_RESPONSE){
            // Recive Widget Response packet
            res=[self FTDI_ReceiveData:newBox.device_handle
                                 label:GET_WIDGET_PARAMS_REPLY
                                  data:(unsigned char *)&PRO_Params
                       expected_length:sizeof(DMXUSBPROParamsType)];
            
            if (res == NO_RESPONSE){
                [self FTDI_ClosePort:newBox.device_handle];
                return  nil;
            }
        }
        
        // Firmware  Version
        VersionMSB = PRO_Params.FirmwareMSB;
        VersionLSB = PRO_Params.FirmwareLSB;
        
        // GET PRO's serial number
        res = [self FTDI_SendData:newBox.device_handle label:GET_WIDGET_SN data:(unsigned char *)&size length:2];
        res = [self FTDI_ReceiveData:newBox.device_handle label:GET_WIDGET_SN data:(unsigned char *)&temp expected_length:4];
        //FIXME: This doesn't work[newBox setSerialNumber:[NSString stringWithCString:temp encoding:NSUTF8StringEncoding]];
        
        // Record Params
        [newBox setDeviceID:device_num];
        [newBox setFirmwareVersion:[NSString stringWithFormat:@"%d.%d",VersionMSB,VersionLSB]];
        [newBox setBreakTimeInMicroseconds:(int) (PRO_Params.BreakTime * 10.67) + 100];
        [newBox setMabTimeInMicroseconds:(int) (PRO_Params.MaBTime * 10.67)];
        [newBox setRefreshRatePacketPerSeconds:PRO_Params.RefreshRate];
        
        // close and return success
        return newBox;
    
        
    // Can't open Device
    }else{
        [self FTDI_ClosePort:newBox.device_handle];
        return nil;
    }
}


// Read a DMX packet
-(uint8_t) FTDI_RxDMX:(FT_HANDLE)device_handle label:(uint8_t)label data:(unsigned char *)data expected_length:(uint32_t*) expected_length{
    FT_STATUS res = 0;
    DWORD length = 0;
    DWORD bytes_read =0;
    unsigned char byte = 0;
    unsigned char header[3];
    unsigned char buffer[600];
    // Check for Start Code and matching Label
    while (byte != DMX_START_CODE)
    {
        res = FT_Read(device_handle,(unsigned char *)&byte,ONE_BYTE,&bytes_read);
        if(bytes_read== NO_RESPONSE) return  NO_RESPONSE;
    }
    res = FT_Read(device_handle,header,3,&bytes_read);
    if(bytes_read== NO_RESPONSE) return  NO_RESPONSE;
    if(header[0] != label) return NO_RESPONSE;
    length = header[1];
    length += ((uint32_t)header[2])<<BYTE_LENGTH;
    length += 1;
    // Check Length is not greater than allowed
    if (length > DMX_PACKET_SIZE +3)
        return  NO_RESPONSE;
    // Read the actual Response Data
    res = FT_Read(device_handle,buffer,length,&bytes_read);
    if(bytes_read != length) return  NO_RESPONSE;
    // Check The End Code
    if (buffer[length-1] != DMX_END_CODE) return  NO_RESPONSE;
    *expected_length = (unsigned int)length;
    // Copy The Data read to the buffer passed
    memcpy(data,buffer,*expected_length);
    return TRUE;
}


-(void)shutDown{
    
    [_availableDevices removeAllObjects];
    
    int devCount = [self FTDI_ListDevices];
    
    
    FT_HANDLE ftHandle;
    FT_STATUS ftStatus;
    for (int device_num=0;device_num<devCount;device_num++){
        ftStatus = FT_Open(0,&ftHandle);
        if (ftStatus == FT_OK) {
            FT_Purge(ftHandle, FT_PURGE_RX);
            FT_Purge(ftHandle, FT_PURGE_TX);
            FT_ClrRts(ftHandle);
            FT_CyclePort(ftHandle);
            FT_Close(ftHandle);
            NSLog(@"Closing...");
        }
    }
}
@end
