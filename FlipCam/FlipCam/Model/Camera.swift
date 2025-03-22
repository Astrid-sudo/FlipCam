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
	var error: Error? { set get }
	var zoomFactor: CGFloat { get }
	var maxZoomFactor: CGFloat { get }
	func setZoom(factor: CGFloat) async throws
	func rampZoom(to factor: CGFloat) async throws
	func setFlashMode(_ mode: FlashMode) async
	func applyGuidePhoto(_ identifier: String)
	var guidePhotoOpacity: Double { get }
	func setGuidePhotoOpacity(_ opacity: Double)
	var currentGuidePhotoEffect: GuidePhotoEffect { get }
	func setGuidePhotoEffect(_ effect: GuidePhotoEffect)
	var isGuideGridEnabled: Bool { get set }
	var shouldShowGuidePhoto: Bool { get set }
	func toggleGuidePhotoVisibility()
	var flashMode: FlashMode { get set }
	var showErrorAlert: Bool { get set }
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
	var error: Error?
	var zoomFactor: CGFloat = 1.0
	var maxZoomFactor: CGFloat = 4.0
	var guidePhotoOpacity: Double = 0.5
	var currentGuidePhotoEffect: GuidePhotoEffect = .normal
	var isGuideGridEnabled: Bool = false
	var shouldShowGuidePhoto: Bool = true
	var flashMode: FlashMode = .off
	var showErrorAlert: Bool = false


	init(status: CameraStatus = .unknown) {
		self.status = status
	}

	func start() async {
		if status == .unknown {
			status = .running
		}
	}

	func switchCameraDevices() async {
		logger.debug("Device switching isn't implemented in PreviewCamera.")
	}

	func capturePhoto() async {
		logger.debug("Photo capture isn't implemented in PreviewCamera.")
	}

	func focusAndExpose(at point: CGPoint) async {
		logger.debug("Focus and expose isn't implemented in PreviewCamera.")
	}

	func syncState() async {
		logger.debug("Syncing state isn't implemented in PreviewCamera.")
	}

	func setZoom(factor: CGFloat) async throws {
		zoomFactor = max(1.0, min(factor, maxZoomFactor))
	}

	func rampZoom(to factor: CGFloat) async throws {
		zoomFactor = max(1.0, min(factor, maxZoomFactor))
	}

	func applyGuidePhoto(_ identifier: String) {
		logger.debug("applyGuidePhoto isn't implemented in PreviewCamera.")
	}

	func setGuidePhotoOpacity(_ opacity: Double) {
		logger.debug("setGuidePhotoOpacity isn't implemented in PreviewCamera.")
	}

	func setGuidePhotoEffect(_ effect: GuidePhotoEffect) {
		logger.debug("setGuidePhotoEffect isn't implemented in PreviewCamera.")
	}

	func toggleGuidePhotoVisibility() {
		logger.debug("toggleGuidePhotoVisibility isn't implemented in PreviewCamera.")
	}

	func setFlashMode(_ mode: FlashMode) async {
		logger.debug("setFlashMode isn't implemented in PreviewCamera.")
	}
}
