//
//  ShotViewModel.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import SwiftUI

enum FlashMode {
	case on
	case off
	case auto
}

@Observable
@MainActor
final class ShotViewModel {
	let cameraController: CameraController
	let guidePhotoController: GuidePhotoController
	
	// Forward camera properties
	var cameraStatus: CameraStatus { cameraController.cameraStatus }
	var captureActivity: CaptureActivity { cameraController.captureActivity }
	var isSwitchingCameraDevices: Bool { cameraController.isSwitchingCameraDevices }
	var prefersMinimizedUI: Bool { cameraController.prefersMinimizedUI }
	var shouldFlashScreen: Bool { cameraController.shouldFlashScreen }
	var thumbnail: CGImage? { cameraController.thumbnail }
	
	// Error handling
	private(set) var error: Error?
	var showErrorAlert: Bool = false

	// Forward guide photo properties
	var guidePhotoIdentifier: String? { guidePhotoController.guidePhotoIdentifier }
	var guidePhotoOpacity: Double { guidePhotoController.guidePhotoOpacity }
	var currentGuidePhotoEffect: GuidePhotoEffect { guidePhotoController.currentGuidePhotoEffect }
	var processedGuidePhoto: UIImage? { guidePhotoController.processedGuidePhoto }
	var shouldShowGuidePhoto: Bool { guidePhotoController.shouldShowGuidePhoto }
	var shouldShowGuideGrid: Bool { guidePhotoController.shouldShowGuideGrid }
	
	private init(cameraController: CameraController, guidePhotoController: GuidePhotoController) {
		self.cameraController = cameraController
		self.guidePhotoController = guidePhotoController
	}
	
	static func create() async -> ShotViewModel {
		let cameraController = CameraController()
		let guidePhotoController = GuidePhotoController(photoLoader: cameraController)
		return ShotViewModel(cameraController: cameraController, guidePhotoController: guidePhotoController)
	}
	
	func startCamera() async {
		do {
			try await cameraController.start()
		} catch {
			handleError(error)
		}
	}

	func switchCameraDevices() async {
		do {
			try await cameraController.switchCameraDevices()
		} catch {
			handleError(error)
		}
	}
	
	func capturePhoto() async {
		do {
			try await cameraController.capturePhoto()
		} catch {
			handleError(error)
		}
	}
	
	func focusAndExpose(at point: CGPoint) async {
		do {
			try await cameraController.focusAndExpose(at: point)
		} catch {
			handleError(error)
		}
	}
	
	private func handleError(_ error: Error) {
		self.error = error
		self.showErrorAlert = true
	}
	
	// MARK: - Guide Photo Management

	func applyGuidePhoto(_ identifier: String) {
		guidePhotoController.applyGuidePhoto(identifier)
	}
	
	func setGuidePhotoOpacity(_ opacity: Double) {
		guidePhotoController.setGuidePhotoOpacity(opacity)
	}
	
	func setGuidePhotoEffect(_ effect: GuidePhotoEffect) {
		guidePhotoController.setGuidePhotoEffect(effect)
	}
	
	func toggleGuidePhotoVisibility() {
		guidePhotoController.toggleGuidePhotoVisibility()
	}
	
	func toggleGuideGrid() {
		guidePhotoController.toggleGuideGrid()
	}
}
