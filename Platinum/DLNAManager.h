//
//  DLNAManager.h
//  Platinum
//
//  Created by AlienLi on 15/4/14.
//  Copyright (c) 2015年 AlienLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <Platinum/Platinum.h>
#include "PltMicroMediaController.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

@interface DLNAManager : NSObject{
    PLT_UPnP *upnpS;
    PLT_UPnP *upnpC;
//    PLT_UPnP *upnpS;
    //    PLT_UPnP *upnpC;
    PLT_MicroMediaController *mediaController;
    NPT_Lock<PLT_DeviceMap> deviceList;
    NSMutableArray *RendererArray;
    
    NPT_String uuid;
}


+(instancetype)DefaultManager;
-(void)transferDeviceToBeServerAndControlPoint;
-(void)getServerResources;
-(NSArray*)getRendererResources;
-(void)specifyRenderer:(NSInteger) index;

@end
