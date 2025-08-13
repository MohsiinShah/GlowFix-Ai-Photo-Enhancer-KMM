//
//  NavigationCoordinator.swift
//  iosApp
//
//  Created by Mohsin on 12/08/2025.
//  Copyright © 2025 orgName. All rights reserved.
//

import ObjectiveC
import UIKit

// Coordinator to handle swipe gesture delegate
class NavigationCoordinator: NSObject, UIGestureRecognizerDelegate {
    var onSwipeDetected: (() -> Void)?
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Trigger the callback when swipe is detected
        onSwipeDetected?()
        // Allow swipe gesture to proceed only if permitted
        return false // Block swipe by default; control via dialog
    }
}
