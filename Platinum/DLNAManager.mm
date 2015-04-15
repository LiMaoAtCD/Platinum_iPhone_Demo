//
//  DLNAManager.m
//  Platinum
//
//  Created by AlienLi on 15/4/14.
//  Copyright (c) 2015年 AlienLi. All rights reserved.
//

#import "DLNAManager.h"
#include <string.h>

@implementation DLNAManager

//static const char * deviceName;


+(instancetype)DefaultManager{
    
    static DLNAManager *sharedSingleton = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedSingleton = [[DLNAManager alloc] init];
        
        [sharedSingleton transferDeviceToBeServerAndControlPoint];
    });
    return sharedSingleton;
}

-(void)transferDeviceToBeServerAndControlPoint {
    
    NPT_LogManager::GetDefault().Configure("plist:.level=FINE;.handlers=ConsoleHandler;.ConsoleHandler.colors=off;.ConsoleHandler.filter=42");
    
    [self configureDMSOptions];
    
    /* for faster DLNA faster testing */
    PLT_Constants::GetInstance().SetDefaultDeviceLease(NPT_TimeInterval(60.));
    
    upnpS = new PLT_UPnP();
    
    PLT_DeviceHostReference device(
                                   new PLT_FileMediaServer(Options.path,Options.friendly_name,false,NULL,(NPT_UInt16)(Options.port))
                                   );
    NPT_List<NPT_IpAddress> list;
    PLT_UPnPMessageHelper::GetIPAddresses(list);
    NPT_String ip = list.GetFirstItem()->ToString();
    
    device->m_ModelDescription = "Platinum File Media Server";
    device->m_ModelURL = "http://www.plutinosoft.com/";
    device->m_ModelNumber = "1.0";
    device->m_ModelName = "Platinum File Media Server";
    device->m_Manufacturer = "Plutinosoft";
    device->m_ManufacturerURL = "http://www.plutinosoft.com/";
    
    upnpS->AddDevice(device);
    uuid = device->GetUUID();
    
    upnpS->Start();
    
    // Create control point
    upnpC = new PLT_UPnP();
    
    PLT_CtrlPointReference ctrlPoint(new PLT_CtrlPoint());
    mediaController = new PLT_MicroMediaController(ctrlPoint);
//    mediaController->setiPhoneName(deviceName);
//    const char* name = mediaController->getiPhoneName();
    
    upnpC->AddCtrlPoint(ctrlPoint);
    
    upnpC->Start();
    
}

-(void)getServerResources {
    
    self->mediaController->LocalUUID = uuid;

//    self->mediaController->getDMS();
    self->mediaController->setDMS();
    
//    NPT_AutoLock lock(mediaController->m_CurMediaServerLock);
//    
//    mediaController->PopDirectoryStackToRoot();
//    
//    deviceList = mediaController->GetMediaServersMap();
//    
//    PLT_StringMap            namesTable;
//    PLT_DeviceDataReference* result = NULL;
//    NPT_String               chosenUUID;
//    NPT_AutoLock             lock1(mediaController->m_MediaServers);
//    
//    // create a map with the device UDN -> device Name
//    const NPT_List<PLT_DeviceMapEntry*>& entries = deviceList.GetEntries();
//    NPT_List<PLT_DeviceMapEntry*>::Iterator entry = entries.GetFirstItem();
//    while (entry) {
//        PLT_DeviceDataReference device = (*entry)->GetValue();
//        NPT_String              name   = device->GetFriendlyName();
//        namesTable.Put((*entry)->GetKey(), name);
//        
//        ++entry;
//    }
//    
//    
//    NPT_List<PLT_StringMapEntry*> entriesnew = namesTable.GetEntries();
//    NPT_List<PLT_StringMapEntry*>::Iterator entry1 = entriesnew.GetFirstItem();
//    int count = 0;
//    while (entry1)
//    {
//        printf("%d)\t%s (%s)\n", ++count, (const char*)(*entry1)->GetValue(), (const char*)(*entry1)->GetKey());
//        
//        if (strcmp((const char*)(uuid), (const char*)(*entry1)->GetKey())==0) {
//            chosenUUID = (*entry1)->GetKey();
//            break;
//        }
//        ++entry1;
//    }
//    
////    if (count != 0) {
////        entry1 = entriesnew.GetFirstItem();
////        while (entry1 && --count) {
////            ++entry1;
////        }
////        if (entry1) {
////            chosenUUID = (*entry1)->GetKey();
////        }
////    }
//    
//    
//    if (chosenUUID.GetLength())
//    {
//        deviceList.Get(chosenUUID, result);
//    }
//    if(result != NULL)
//    {
//        mediaController->m_CurMediaServer = *result;
//    }
//    
//    
//
}


-(void)getRedererResources{
    self->mediaController->setDMR();
}






/*----------------------------------------------------------------------
 |   globals Device Configuration
 +---------------------------------------------------------------------*/
struct Options {
    const char* path;
    const char* friendly_name;
    const char* guid;
    NPT_UInt32  port;
} Options;




-(void)configureDMSOptions {
 
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"122924954.mp3"];
    
    if(![fileManager fileExistsAtPath:filePath]) //如果不存在
    {
        NSLog(@"xxx.txt is not exist");
        NSString *dataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/122924954.mp3"];//获取程序包中相应文件的路径
        NSError *error;
        if([fileManager copyItemAtPath:dataPath toPath:filePath error:&error]) //拷贝
        {
            NSLog(@"copy bundle file to document ");
        }
        else
        {
            NSLog(@"%@",error);
        }
    }
    
    
    const char *path = [docDir cStringUsingEncoding:NSASCIIStringEncoding];
    
    Options.path = path;
    
    UIDevice *device = [UIDevice currentDevice];
    const char * friendlyName = [[device name] cStringUsingEncoding:NSASCIIStringEncoding];
    Options.friendly_name = friendlyName;
    Options.port = 0;
    Options.guid = NULL;
}






@end
