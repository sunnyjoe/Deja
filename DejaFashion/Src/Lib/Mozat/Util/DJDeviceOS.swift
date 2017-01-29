//
//  DJDeviceOS.swift
//  DejaFashion
//
//  Created by Sun lin on 28/7/15.
//  Copyright (c) 2015 Mozat. All rights reserved.
//


class DJDeviceOS: NSObject
{
    static func enableNotification()->Bool
    {
        
        let userNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if userNotificationSettings != nil
        {
            return userNotificationSettings!.types != UIUserNotificationType.None
        }
        
        return false
    }
}
