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
    printf("%s",(const char*)ip);
    
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


-(NSArray*)getRendererResources{
    
//    self->mediaController->setDMR();
    
    RendererArray = [[NSMutableArray alloc] init];

    deviceList = mediaController->m_MediaRenderers;
    
    NPT_AutoLock lock(mediaController->m_CurMediaRendererLock);
    
    PLT_StringMap            namesTable;
//    NPT_String               chosenUUID;
//    NPT_AutoLock             lock1(mediaController->m_MediaServers);
    
    // create a map with the device UDN -> device Name
    const NPT_List<PLT_DeviceMapEntry*>& entries = deviceList.GetEntries();
    NPT_List<PLT_DeviceMapEntry*>::Iterator entry = entries.GetFirstItem();
    while (entry) {
        PLT_DeviceDataReference device = (*entry)->GetValue();
        

        NPT_String              name   = device->GetFriendlyName();
        
        namesTable.Put((*entry)->GetKey(), name);
        
        ++entry;
    }

//    chosenUUID = ChooseRendererIDFromTable(namesTable);
    NPT_List<PLT_StringMapEntry*> entries1 = namesTable.GetEntries();
    if (entries1.GetItemCount() == 0) {
        printf("None available\n");
        return [NSArray array];
        
    } else {
        
        // display the list of entries
        
        
        NPT_List<PLT_StringMapEntry*>::Iterator entry1 = entries1.GetFirstItem();
        int count = 0;
        
        while (entry1) {
            
            printf("%d)\t%s (%s)\n", ++count, (const char*)(*entry1)->GetValue(), (const char*)(*entry1)->GetKey());
            NSString * entry1String = [[NSString alloc] initWithCString:(const char*)(*entry1)->GetValue() encoding:NSUTF8StringEncoding];
            [RendererArray addObject:entry1String];
            ++entry1;
        }
        return RendererArray;
    }
}

    
-(void)specifyRenderer:(NSInteger) index{
    NPT_String               chosenUUID;
    PLT_DeviceDataReference* result = NULL;

    NSString * selectedRenderName = RendererArray[index];
    
    const char* chosenName = [selectedRenderName cStringUsingEncoding:NSUTF8StringEncoding];
    
    // create a map with the device UDN -> device Name
    const NPT_List<PLT_DeviceMapEntry*>& entries = deviceList.GetEntries();
    NPT_List<PLT_DeviceMapEntry*>::Iterator entry = entries.GetFirstItem();
    while (entry) {
        PLT_DeviceDataReference device = (*entry)->GetValue();
        NPT_String              name   = device->GetFriendlyName();
        if (strcmp((const char*)name, chosenName) == 0&& entry) {
            
            
            chosenUUID =  (*entry)->GetKey();
            printf("SelectMDR:::%s",(const char*)(name));
            break;
        }
        ++entry;
    }

    

    
    if (chosenUUID.GetLength()) {
        deviceList.Get(chosenUUID, result);
    }
    
    mediaController->m_CurMediaRenderer = result?*result:PLT_DeviceDataReference();
    
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


-(NSArray*)fetchLocalFilesfromDMS{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];

    NSLog(@"%@",fileList);
    return fileList;
    
    
}

-(void)specifyFileInDMS:(NSInteger) index{
    
    NPT_String              object_id;
    PLT_StringMap           tracks;
    PLT_DeviceDataReference device;
    
    mediaController->GetCurrentMediaRenderer(device);
//    GetCurMediaRenderer(device);
    if (!device.IsNull()) {
        // get the protocol info to try to see in advance if a track would play on the device
        
        // issue a browse
        
        //DoBrowse;
        
        NPT_Result res = NPT_FAILURE;
        PLT_DeviceDataReference device1;
        
        mediaController->GetCurrentMediaServer(device1);
        if (!device1.IsNull()) {
            NPT_String cur_object_id;
            mediaController->m_CurBrowseDirectoryStack.Peek(cur_object_id);
            
            // send off the browse packet and block
            res = mediaController->BrowseSync(
                             device1,
                             (const char*)cur_object_id,
                             mediaController->m_MostRecentBrowseResults,
                             false);
        }
        
        
        
        if (!mediaController->m_MostRecentBrowseResults.IsNull()) {
            // create a map item id -> item title
            NPT_List<PLT_MediaObject*>::Iterator item = mediaController->m_MostRecentBrowseResults->GetFirstItem();
            while (item) {
                if (!(*item)->IsContainer()) {
                    tracks.Put((*item)->m_ObjectID, (*item)->m_Title);
                }
                ++item;
            }
            // let the user choose which one
//            object_id = ChooseIDFromTable(tracks);
            
            NPT_List<PLT_StringMapEntry*> entries = tracks.GetEntries();
            if (entries.GetItemCount() == 0) {
                printf("None available\n");
            } else {
                // display the list of entries
                NPT_List<PLT_StringMapEntry*>::Iterator entry = entries.GetFirstItem();
                int count = 0;
                while (entry) {
                    printf("%d)\t%s (%s)\n", ++count, (const char*)(*entry)->GetValue(), (const char*)(*entry)->GetKey());
                    ++entry;
                }
                
                //选择index +1；
                index++;
                
                // find the entry back
                if (index != 0) {
                    entry = entries.GetFirstItem();
                    while (entry && --index) {
                        ++entry;
                    }
                    if (entry) {
                        object_id = (*entry)->GetKey();
                    }
                }
            }
            
            if (object_id.GetLength()) {
                // look back for the PLT_MediaItem in the results
                PLT_MediaObject* track = NULL;
                if (NPT_SUCCEEDED(NPT_ContainerFind(*mediaController->m_MostRecentBrowseResults, PLT_MediaItemIDFinder(object_id), track))) {
                    if (track->m_Resources.GetItemCount() > 0) {
                        // look for best resource to use by matching each resource to a sink advertised by renderer
                        NPT_Cardinal resource_index = 0;
                        if (NPT_FAILED(mediaController->FindBestResource(device, *track, resource_index))) {
                            printf("No matching resource\n");
                        }
                        
                        // invoke the setUri
                        printf("Issuing SetAVTransportURI with url=%s & didl=%s",
                               (const char*)track->m_Resources[resource_index].m_Uri,
                               (const char*)track->m_Didl);
                        mediaController->SetAVTransportURI(device, 0, track->m_Resources[resource_index].m_Uri, track->m_Didl, NULL);
                        
                        mediaController->File_Play();
                    } else {
                        printf("Couldn't find the proper resource\n");
                    }
                    
                } else {
                    printf("Couldn't find the track\n");
                }
            }
            
            mediaController->m_MostRecentBrowseResults = NULL;
        }
    }

    
    
    
}






@end
