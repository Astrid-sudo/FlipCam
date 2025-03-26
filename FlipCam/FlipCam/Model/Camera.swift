//
//  Camera.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import SwiftUI

// Core camera functionality
@MainActor
protocol Camera: AnyObject {
	var cameraStatus: CameraStatus { get }
	var captureActivity: CaptureActivity { get }
	var previewSource: PreviewSource { get }
	var isSwitchingCameraDevices: Bool { get }
	var shouldFlashScreen: Bool { get }
	var thumbnail: CGImage? { get }
	var zoomFactor: CGFloat { get }
	var maxZoomFactor: CGFloat { get }
	var flashMode: FlashMode { get }

	func start() async throws
	func switchCameraDevices() async throws
	func focusAndExpose(at point: CGPoint) async throws
	func capturePhoto() async throws
	func setZoom(factor: CGFloat) async throws
	func rampZoom(to factor: CGFloat) async throws
	func setFlashMode(_ mode: FlashMode) async
}

// Guide and overlay features
@MainActor
protocol CameraGuideOverlay: AnyObject {
	var guidePhotoOpacity: Double { get }
	var currentGuidePhotoEffect: GuidePhotoEffect { get }
	var shouldShowGuideGrid: Bool { get }
	var shouldShowGuidePhoto: Bool { get }
	
	func applyGuidePhoto(_ identifier: String)
	func setGuidePhotoOpacity(_ opacity: Double)
	func setGuidePhotoEffect(_ effect: GuidePhotoEffect)
	func toggleGuidePhotoVisibility()
}

protocol PhotoLoader {
	func loadPhoto(withIdentifier identifier: String) async throws -> UIImage
}

@Observable
class PreviewCameraModel: Camera {
	var cameraStatus: CameraStatus { status }
	var prefersMinimizedUI = false
	var shouldFlashScreen = false
	struct PreviewSourceStub: PreviewSource {
		// Stubbed out for test purposes.
		func connect(to target: PreviewTarget) {}
	}
	let previewSource: PreviewSource = PreviewSourceStub()
	private(set) var status = CameraStatus.unknown
	private(set) var captureActivity = CaptureActivity.idle
	private(set) var isSwitchingModes = false
	private(set) var isVideoDeviceSwitchable = true
	private(set) var isSwitchingCameraDevices = false
	private(set) var thumbnail: CGImage?
	var zoomFactor: CGFloat = 1.0
	var maxZoomFactor: CGFloat = 4.0
	var flashMode: FlashMode = .off


	init(status: CameraStatus = .unknown) {
		self.status = status
	}

	func start() async throws {
		if status == .unknown {
			status = .running
		}
	}

	func switchCameraDevices() async throws {
		logger.debug("Device switching isn't implemented in PreviewCamera.")
	}

	func capturePhoto() async throws {
		logger.debug("Photo capture isn't implemented in PreviewCamera.")
	}

	func focusAndExpose(at point: CGPoint) async throws {
		logger.debug("Focus and expose isn't implemented in PreviewCamera.")
	}

	func setZoom(factor: CGFloat) async throws {
		zoomFactor = max(1.0, min(factor, maxZoomFactor))
	}

	func rampZoom(to factor: CGFloat) async throws {
		zoomFactor = max(1.0, min(factor, maxZoomFactor))
	}

	func setFlashMode(_ mode: FlashMode) async {
		logger.debug("setFlashMode isn't implemented in PreviewCamera.")
	}
}
