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
final class ShotViewModel: CameraGuideOverlay {
	let cameraController = CameraController()
	
	// Forward camera properties
	var previewSource: PreviewSource { cameraController.previewSource }
	var cameraStatus: CameraStatus { cameraController.cameraStatus }
	var captureActivity: CaptureActivity { cameraController.captureActivity }
	var isSwitchingCameraDevices: Bool { cameraController.isSwitchingCameraDevices }
	var prefersMinimizedUI: Bool { cameraController.prefersMinimizedUI }
	var shouldFlashScreen: Bool { cameraController.shouldFlashScreen }
	var thumbnail: CGImage? { cameraController.thumbnail }
	var error: Error?
	var showErrorAlert: Bool = false
	var flashMode: FlashMode {
		get { cameraController.flashMode }
		set { Task { await cameraController.setFlashMode(newValue) } }
	}
	
	// Guide Photo properties
	private var guidePhoto: UIImage?
	private(set) var guidePhotoIdentifier: String?
	private(set) var guidePhotoOpacity: Double = 0.5
	private(set) var currentGuidePhotoEffect: GuidePhotoEffect = .normal
	private(set) var processedGuidePhoto: UIImage?
	var shouldShowGuidePhoto: Bool = true
	var shouldShowGuideGrid: Bool = false
	
	init() {
		loadSavedGuidePhotoIdentifier()
		loadSavedGuidePhotoOpacity()
		loadSavedGuidePhotoEffect()
		loadSavedGuidePhotoVisibility()
		loadSavedGuideGridSetting()
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
		saveGuidePhotoIdentifier(identifier)
		resetGuidePhotoSetting()
		Task {
			await loadGuidePhoto()
		}
	}

	private func loadGuidePhoto() async {
		guard let identifier = guidePhotoIdentifier else {
			guidePhoto = nil
			processedGuidePhoto = nil
			logger.info("There is no guide photo selected.")
			return
		}

		do {
			self.guidePhoto = try await cameraController.loadPhoto(withIdentifier: identifier)
			processGuidePhoto()
		} catch {
			logger.error("Failed to load guide photo: \(error)")
			self.guidePhoto = nil
			self.processedGuidePhoto = nil
		}
	}

	private func saveGuidePhotoIdentifier(_ identifier: String) {
		self.guidePhotoIdentifier = identifier
		UserDefaults.standard.set(identifier, forKey: "guidePhotoIdentifier")
	}

	private func loadSavedGuidePhotoIdentifier() {
		if let savedIdentifier = UserDefaults.standard.string(forKey: "guidePhotoIdentifier") {
			self.guidePhotoIdentifier = savedIdentifier
			Task {
				await loadGuidePhoto()
			}
		}
	}

	func setGuidePhotoOpacity(_ opacity: Double) {
		self.guidePhotoOpacity = opacity
		saveGuidePhotoOpacity()
	}

	private func saveGuidePhotoOpacity() {
		UserDefaults.standard.set(guidePhotoOpacity, forKey: "guidePhotoOpacity")
	}

	private func loadSavedGuidePhotoOpacity() {
		if let savedOpacity = UserDefaults.standard.object(forKey: "guidePhotoOpacity") as? Double {
			self.guidePhotoOpacity = savedOpacity
		}
	}

	private func resetGuidePhotoSetting() {
		self.shouldShowGuidePhoto = true
		saveGuidePhotoVisibility()

		self.guidePhotoOpacity = 0.5
		saveGuidePhotoOpacity()

		self.currentGuidePhotoEffect = .normal
		saveGuidePhotoEffect()
	}

	// MARK: - Guide Photo Effects

	private func processGuidePhoto() {
		guard let guidePhoto = guidePhoto else {
			processedGuidePhoto = nil
			logger.info("There is no guide photo selected.")
			return
		}
		processedGuidePhoto = PhotoEffectProcessor.processPhoto(guidePhoto, with: currentGuidePhotoEffect)
	}

	func setGuidePhotoEffect(_ effect: GuidePhotoEffect) {
		currentGuidePhotoEffect = effect
		saveGuidePhotoEffect()
		processGuidePhoto()
	}

	private func saveGuidePhotoEffect() {
		UserDefaults.standard.set(currentGuidePhotoEffect.rawValue, forKey: "guidePhotoEffect")
	}

	private func loadSavedGuidePhotoEffect() {
		if let savedEffect = UserDefaults.standard.string(forKey: "guidePhotoEffect"),
		   let effect = GuidePhotoEffect(rawValue: savedEffect) {
			self.currentGuidePhotoEffect = effect
		}
	}

	// MARK: - Guide Photo Visibility

	func toggleGuidePhotoVisibility() {
		shouldShowGuidePhoto.toggle()
		saveGuidePhotoVisibility()
	}

	private func saveGuidePhotoVisibility() {
		UserDefaults.standard.set(shouldShowGuidePhoto, forKey: "shouldShowGuidePhoto")
	}

	private func loadSavedGuidePhotoVisibility() {
		shouldShowGuidePhoto = UserDefaults.standard.bool(forKey: "shouldShowGuidePhoto")
	}

	// MARK: - Guide Grid Management

	func toggleGuideGrid() {
		shouldShowGuideGrid.toggle()
		saveGuideGridSetting()
	}

	private func saveGuideGridSetting() {
		UserDefaults.standard.set(shouldShowGuideGrid, forKey: "shouldShowGuideGrid")
	}

	private func loadSavedGuideGridSetting() {
		shouldShowGuideGrid = UserDefaults.standard.bool(forKey: "shouldShowGuideGrid")
	}
}
