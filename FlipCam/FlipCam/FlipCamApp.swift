//
//  FlipCamApp.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/6.
//
import os
import SwiftUI
import PhotosUI
import Photos


@main
struct FlipCamApp: App {

    var body: some Scene {
        WindowGroup {
			ShotView()
        }
    }


}
let logger = Logger()
