//
//  AppDelegateFBMessagingExtension.swift
//  iAlert
//
//  Created by Assaf Tayouri on 24/04/2019.
//  Copyright © 2019 Assaf Tayouri. All rights reserved.
//

import Firebase

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        iAlertService.shared.register(by:fcmToken)
    }
}
