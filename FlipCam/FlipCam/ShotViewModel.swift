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

protocol ShotViewModelType {
	var input: ShotViewModelInputType { get }
	var output: ShotViewModelOutputType { get }
}

protocol ShotViewModelInputType {
	static func create() async -> ShotViewModelType
	func startCamera() async
	func switchCameraDevices() async
	func capturePhoto() async
	func focusAndExpose(at point: CGPoint) async
	func applyGuidePhoto(_ identifier: String)
	func setGuidePhotoOpacity(_ opacity: Double)
	func setGuidePhotoEffect(_ effect: GuidePhotoEffect)
	func setFlashMode(_ mode: FlashMode) async
	func rampZoom(to factor: CGFloat) async
	func setZoom(to factor: CGFloat) async
	func toggleGuidePhotoVisibility()
	func toggleGuideGrid()
	func dismissAlert()
}

protocol ShotViewModelOutputType {
	var cameraStatus: CameraStatus { get }
	var captureActivity: CaptureActivity { get }
	var isSwitchingCameraDevices: Bool { get }
	var shouldFlashScreen: Bool { get }
	var thumbnail: CGImage? { get }
	var flashMode: FlashMode { get }
	var zoomFactor: CGFloat { get }
	var previewSource: PreviewSource { get }

	// Error handling
	var showErrorAlert: Bool { get set }
	var error: Error? { get }

	// Forward guide photo properties
	var guidePhotoIdentifier: String? { get }
	var guidePhotoOpacity: Double { get }
	var currentGuidePhotoEffect: GuidePhotoEffect { get }
	var processedGuidePhoto: UIImage? { get }
	var shouldShowGuidePhoto: Bool { get }
	var shouldShowGuideGrid: Bool { get }
}

@Observable
@MainActor
final class ShotViewModel: ShotViewModelType, ShotViewModelInputType, ShotViewModelOutputType {
	var input: ShotViewModelInputType { return self }
	var output: ShotViewModelOutputType { return self }

	let cameraController: CameraController
	let guidePhotoController: GuidePhotoController
	
	// Forward camera properties
	var cameraStatus: CameraStatus { cameraController.cameraStatus }
	var captureActivity: CaptureActivity { cameraController.captureActivity }
	var isSwitchingCameraDevices: Bool { cameraController.isSwitchingCameraDevices }
	var shouldFlashScreen: Bool { cameraController.shouldFlashScreen }
	var thumbnail: CGImage? { cameraController.thumbnail }
	var flashMode: FlashMode { cameraController.flashMode }
	var zoomFactor: CGFloat { cameraController.zoomFactor }
	var previewSource: PreviewSource { cameraController.previewSource }

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
	
	static func create() async -> ShotViewModelType {
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

	func setFlashMode(_ mode: FlashMode) async {
		await cameraController.setFlashMode(mode)
	}

	func rampZoom(to factor: CGFloat) async {
		do {
			try await cameraController.rampZoom(to: factor)
		} catch {
			handleError(error)
		}
	}

	func setZoom(to factor: CGFloat) async {
		do {
			try await cameraController.setZoom(factor: factor)
		} catch {
			handleError(error)
		}
	}

	private func handleError(_ error: Error) {
		self.error = error
		self.showErrorAlert = true
	}

	func dismissAlert() {
		self.showErrorAlert = false
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
