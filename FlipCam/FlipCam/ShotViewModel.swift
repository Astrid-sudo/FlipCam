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
	var error: Error?
	var showErrorAlert = false
	private(set) var zoomFactor: CGFloat = 1.0
	private(set) var maxZoomFactor: CGFloat = 1.0

	/// Guide Photo
	private var guidePhoto: UIImage?
	private(set) var guidePhotoIdentifier: String?
	private(set) var guidePhotoOpacity: Double = 0.5 // Default opacity value

	private(set) var currentGuidePhotoEffect: GuidePhotoEffect = .normal
	private(set) var processedGuidePhoto: UIImage?
	var shouldShowGuidePhoto: Bool = true

	/// Guide Grid
	var isGuideGridEnabled: Bool = false

	var flashMode: FlashMode = .off

	init() {
		/// Guide Photo
		loadSavedGuidePhotoIdentifier()
		loadSavedGuidePhotoOpacity()
		loadSavedGuidePhotoEffect()
		loadSavedGuidePhotoVisibility()
		
		/// Guide Grid
		loadSavedGuideGridSetting()
	}

	// MARK: - Error Handling
	private func handleError(_ error: Error) {
		self.error = error
		self.showErrorAlert = true
	}

	// MARK: - Starting the camera

	func start() async {
		guard await captureService.isAuthorized else {
			cameraStatus = .unauthorized
			handleError(CameraError.cameraUnauthorized)
			return
		}
		do {
			try await captureService.start()
			observeState()
			cameraStatus = .running
		} catch {
			logger.error("Failed to start capture service. \(error)")
			cameraStatus = .failed
			handleError(error)
		}
	}

	// MARK: - Device selection

	func switchCameraDevices() async {
		isSwitchingCameraDevices = true
		defer { isSwitchingCameraDevices = false }
		do {
			try await captureService.selectNextCameraDevice()
		} catch {
			handleError(error)
		}
	}

	// MARK: - Photo capture

	func capturePhoto() async {
		do {
			flashScreen()
			let photo = try await captureService.capturePhoto()
			try await mediaLibrary.save(photo: photo)
		} catch {
			handleError(error)
		}
	}

	func focusAndExpose(at point: CGPoint) async {
		do {
			try await captureService.focusAndExpose(at: point)
		} catch {
			handleError(error)
		}
	}

	func setZoom(factor: CGFloat) async throws {
		try await captureService.setZoom(factor: factor)
		zoomFactor = factor
	}

	func rampZoom(to factor: CGFloat) async throws {
		try await captureService.rampZoom(to: factor)
		zoomFactor = factor
	}

	private func flashScreen() {
		shouldFlashScreen = true
		withAnimation(.linear(duration: 0.01)) {
			shouldFlashScreen = false
		}
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
			self.guidePhoto = try await mediaLibrary.loadPhoto(withIdentifier: identifier)
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

	func setGuidePhotoEffect(_ effect: GuidePhotoEffect) {
		currentGuidePhotoEffect = effect
		saveGuidePhotoEffect()
		processGuidePhoto()
	}

	private func processGuidePhoto() {
		guard let guidePhoto = guidePhoto else {
			processedGuidePhoto = nil
			logger.info("There is no guide photo selected.")
			return
		}
		
		switch currentGuidePhotoEffect {
		case .normal:
			processedGuidePhoto = guidePhoto
			
		case .contrast:
			if let ciImage = CIImage(image: guidePhoto) {
				let context = CIContext(options: nil)
				
				let parameters = [
					kCIInputImageKey: ciImage,
					kCIInputContrastKey: NSNumber(value: 10.0),
					kCIInputBrightnessKey: NSNumber(value: 0.2)
				] as [String : Any]
				
				if let filter = CIFilter(name: "CIColorControls", parameters: parameters),
				   let outputImage = filter.outputImage,
				   let cgImg = context.createCGImage(outputImage, from: outputImage.extent) {
					processedGuidePhoto = UIImage(cgImage: cgImg)
				} else {
					processedGuidePhoto = guidePhoto
				}
			} else {
				processedGuidePhoto = guidePhoto
			}
			
		case .inverse:
			if let ciImage = CIImage(image: guidePhoto) {
				let context = CIContext(options: nil)
				
				// First invert the colors
				guard let invertFilter = CIFilter(name: "CIColorInvert") else {
					processedGuidePhoto = guidePhoto
					logger.error("There is no CIFilter named CIColorInvert.")
					return
				}
				invertFilter.setValue(ciImage, forKey: kCIInputImageKey)
				
				guard let invertedImage = invertFilter.outputImage else {
					processedGuidePhoto = guidePhoto
					return
				}
				
				// Then apply high contrast
				guard let contrastFilter = CIFilter(name: "CIColorControls") else {
					processedGuidePhoto = guidePhoto
					logger.error("There is no CIFilter named CIColorControls.")
					return
				}
				contrastFilter.setValue(invertedImage, forKey: kCIInputImageKey)
				contrastFilter.setValue(NSNumber(value: 10), forKey: kCIInputContrastKey)
				contrastFilter.setValue(NSNumber(value: -2), forKey: kCIInputBrightnessKey)
				contrastFilter.setValue(NSNumber(value: 1.2), forKey: kCIInputSaturationKey)
				
				if let outputImage = contrastFilter.outputImage,
				   let cgImg = context.createCGImage(outputImage, from: outputImage.extent) {
					processedGuidePhoto = UIImage(cgImage: cgImg)
				} else {
					processedGuidePhoto = guidePhoto
				}
			} else {
				processedGuidePhoto = guidePhoto
			}
			
		case .outline:
			if let ciImage = CIImage(image: guidePhoto) {
				let context = CIContext(options: nil)
				
				// First invert the colors
				guard let invertFilter = CIFilter(name: "CIColorInvert") else {
					processedGuidePhoto = guidePhoto
					logger.error("There is no CIFilter named CIColorInvert.")
					return
				}
				invertFilter.setValue(ciImage, forKey: kCIInputImageKey)
				
				guard let invertedImage = invertFilter.outputImage else {
					processedGuidePhoto = guidePhoto
					return
				}
				
				// Increase contrast of inverted image
				guard let contrastFilter = CIFilter(name: "CIColorControls") else {
					processedGuidePhoto = guidePhoto
					logger.error("There is no CIFilter named CIColorControls.")
					return
				}
				contrastFilter.setValue(invertedImage, forKey: kCIInputImageKey)
				contrastFilter.setValue(NSNumber(value: 3.0), forKey: kCIInputContrastKey)
				contrastFilter.setValue(NSNumber(value: 0.0), forKey: kCIInputBrightnessKey)
				
				guard let contrastedImage = contrastFilter.outputImage else {
					processedGuidePhoto = guidePhoto
					return
				}
				
				// Apply edge detection
				guard let edgeFilter = CIFilter(name: "CIEdges") else {
					processedGuidePhoto = guidePhoto
					logger.error("There is no CIFilter named CIEdges.")
					return
				}
				edgeFilter.setValue(contrastedImage, forKey: kCIInputImageKey)
				edgeFilter.setValue(NSNumber(value: 6.0), forKey: kCIInputIntensityKey)
				
				guard let edgeOutput = edgeFilter.outputImage else {
					processedGuidePhoto = guidePhoto
					return
				}
				
				// Make it brighter and increase contrast
				guard let brightnessFilter = CIFilter(name: "CIColorControls") else {
					processedGuidePhoto = guidePhoto
					logger.error("There is no CIFilter named CIColorControls.")
					return
				}
				brightnessFilter.setValue(edgeOutput, forKey: kCIInputImageKey)
				brightnessFilter.setValue(NSNumber(value: 8.0), forKey: kCIInputContrastKey)
				brightnessFilter.setValue(NSNumber(value: 0.3), forKey: kCIInputBrightnessKey) // Make it brighter
				brightnessFilter.setValue(NSNumber(value: 0.0), forKey: kCIInputSaturationKey)
				
				if let outputImage = brightnessFilter.outputImage,
				   let cgImg = context.createCGImage(outputImage, from: outputImage.extent) {
					processedGuidePhoto = UIImage(cgImage: cgImg)
				} else {
					processedGuidePhoto = guidePhoto
				}
			} else {
				processedGuidePhoto = guidePhoto
			}
		}
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
		isGuideGridEnabled.toggle()
		saveGuideGridSetting()
	}

	private func saveGuideGridSetting() {
		UserDefaults.standard.set(isGuideGridEnabled, forKey: "isGuideGridEnabled")
	}

	private func loadSavedGuideGridSetting() {
		isGuideGridEnabled = UserDefaults.standard.bool(forKey: "isGuideGridEnabled")
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

	func setFlashMode(_ mode: FlashMode) async {
		flashMode = mode
		await captureService.setFlashMode(mode)
	}
}
