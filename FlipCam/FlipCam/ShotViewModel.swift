//
//  ShotViewModel.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import SwiftUI

@Observable
final class ShotViewModel: Camera {

	/// Camera protocol
	var previewSource: PreviewSource { captureService.previewSource }
	private let mediaLibrary = MediaLibrary()
	private let captureService = CaptureService()

	private(set) var cameraStatus = CameraStatus.unknown
	private(set) var captureActivity = CaptureActivity.idle
	private(set) var isSwitchingCameraDevices = false
	private(set) var prefersMinimizedUI = false
	private(set) var shouldFlashScreen = false
	private(set) var thumbnail: CGImage?
	private(set) var error: Error?
	private(set) var zoomFactor: CGFloat = 1.0
	private(set) var maxZoomFactor: CGFloat = 1.0

	/// Guide Photo
	private(set) var guidePhoto: UIImage?
	private(set) var guidePhotoIdentifier: String?
	private(set) var guidePhotoOpacity: Double = 0.5 // Default opacity value

	init() {
		/// Guide Photo
		loadSavedGuidePhotoIdentifier()
		loadSavedGuidePhotoOpacity()
	}

	// MARK: - Starting the camera

	func start() async {
		guard await captureService.isAuthorized else {
			cameraStatus = .unauthorized
			return
		}
		do {
			try await captureService.start()
			observeState()
			cameraStatus = .running
		} catch {
			logger.error("Failed to start capture service. \(error)")
			cameraStatus = .failed
		}
	}

	// MARK: - Device selection

	func switchCameraDevices() async {
		isSwitchingCameraDevices = true
		defer { isSwitchingCameraDevices = false }
		await captureService.selectNextCameraDevice()
	}

	// MARK: - Photo capture

	func capturePhoto() async {
		do {
			let photo = try await captureService.capturePhoto()
			try await mediaLibrary.save(photo: photo)
		} catch {
			self.error = error
		}
	}

	func focusAndExpose(at point: CGPoint) async {
		await captureService.focusAndExpose(at: point)
	}

	func setZoom(factor: CGFloat) async {
		await captureService.setZoom(factor: factor)
		zoomFactor = factor
	}

	func rampZoom(to factor: CGFloat) async {
		await captureService.rampZoom(to: factor)
		zoomFactor = factor
	}

	private func flashScreen() {
		shouldFlashScreen = true
		withAnimation(.linear(duration: 0.01)) {
			shouldFlashScreen = false
		}
	}

	// MARK: - Guide Photo Management

	func loadGuidePhoto() async {
		guard let identifier = guidePhotoIdentifier else {
			guidePhoto = nil
			logger.info("There is no guide photo selected.")
			return
		}

		do {
			self.guidePhoto = try await mediaLibrary.loadPhoto(withIdentifier: identifier)
		} catch {
			logger.error("Failed to load guide photo: \(error)")
			self.guidePhoto = nil
		}
	}

	func saveGuidePhotoIdentifier(_ identifier: String) {
		self.guidePhotoIdentifier = identifier
		UserDefaults.standard.set(identifier, forKey: "guidePhotoIdentifier")
		Task {
			await loadGuidePhoto()
		}
	}

	func loadSavedGuidePhotoIdentifier() {
		if let savedIdentifier = UserDefaults.standard.string(forKey: "guidePhotoIdentifier") {
			self.guidePhotoIdentifier = savedIdentifier
			Task {
				await loadGuidePhoto()
			}
		}
	}

	func clearGuidePhoto() {
		guidePhoto = nil
		guidePhotoIdentifier = nil
		UserDefaults.standard.removeObject(forKey: "guidePhotoIdentifier")
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

	// MARK: - Internal state observations

	private func observeState() {
		Task {
			for await thumbnail in mediaLibrary.thumbnails.compactMap({ $0 }) {
				self.thumbnail = thumbnail
			}
		}

		Task {
			for await activity in await captureService.$captureActivity.values {
				if activity.willCapture {
					flashScreen()
				} else {
					captureActivity = activity
				}
			}
		}

		Task {
			for await isShowingFullscreenControls in await captureService.$isShowingFullscreenControls.values {
				withAnimation {
					prefersMinimizedUI = isShowingFullscreenControls
				}
			}
		}
	}
}
