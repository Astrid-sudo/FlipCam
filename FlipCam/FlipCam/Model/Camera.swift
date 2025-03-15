//
//  Camera.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import SwiftUI

@MainActor
protocol Camera: AnyObject {
	var cameraStatus: CameraStatus { get }
	var captureActivity: CaptureActivity { get }
	var previewSource: PreviewSource { get }
	func start() async
	var prefersMinimizedUI: Bool { get }
	func switchCameraDevices() async
	var isSwitchingCameraDevices: Bool { get }
	func focusAndExpose(at point: CGPoint) async
	func capturePhoto() async
	var shouldFlashScreen: Bool { get }
	var thumbnail: CGImage? { get }
	var error: Error? { get }
	var zoomFactor: CGFloat { get }
	var maxZoomFactor: CGFloat { get }
	func setZoom(factor: CGFloat) async
	func rampZoom(to factor: CGFloat) async
}
