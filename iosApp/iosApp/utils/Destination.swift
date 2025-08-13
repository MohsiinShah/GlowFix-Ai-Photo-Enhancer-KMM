//
//  Destination.swift
//  iosApp
//
//  Created by Mohsin on 12/08/2025.
//  Copyright © 2025 orgName. All rights reserved.
//
import shared
import UIKit

enum Destination: Hashable {
    case dashboard
    case gallery(processor: PROCESSOR)
    case processing(processor: PROCESSOR)
    case filters(path: String, processor: PROCESSOR)
    case result(path: String, processor: PROCESSOR)
}
