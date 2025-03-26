//
//  GuidePhotoController.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/26.
//

import SwiftUI

@Observable
final class GuidePhotoController: CameraGuideOverlay {
	// MARK: - Properties
	private let photoLoader: PhotoLoader
	private var guidePhoto: UIImage?
	private(set) var guidePhotoIdentifier: String?
	private(set) var guidePhotoOpacity: Double = 0.5
	private(set) var currentGuidePhotoEffect: GuidePhotoEffect = .normal
	var processedGuidePhoto: UIImage? {
		guard let guidePhoto = guidePhoto else {
			logger.info("There is no guide photo selected.")
			return nil
		}
		return PhotoEffectProcessor.processPhoto(guidePhoto, with: currentGuidePhotoEffect)
	}
	private(set) var shouldShowGuidePhoto: Bool = true
	private(set) var shouldShowGuideGrid: Bool = false

	// MARK: - Initialization
	init(photoLoader: PhotoLoader) {
		self.photoLoader = photoLoader
		loadSavedGuidePhotoIdentifier()
		loadSavedGuidePhotoOpacity()
		loadSavedGuidePhotoEffect()
		loadSavedGuidePhotoVisibility()
		loadSavedGuideGridSetting()
	}

	// MARK: - Public Methods
	func applyGuidePhoto(_ identifier: String) {
		saveGuidePhotoIdentifier(identifier)
		resetGuidePhotoSetting()
		Task {
			await loadGuidePhoto()
		}
	}

	func setGuidePhotoOpacity(_ opacity: Double) {
		self.guidePhotoOpacity = opacity
		saveGuidePhotoOpacity()
	}

	func setGuidePhotoEffect(_ effect: GuidePhotoEffect) {
		currentGuidePhotoEffect = effect
		saveGuidePhotoEffect()
	}

	func toggleGuidePhotoVisibility() {
		shouldShowGuidePhoto.toggle()
		saveGuidePhotoVisibility()
	}

	func toggleGuideGrid() {
		shouldShowGuideGrid.toggle()
		saveGuideGridSetting()
	}

	// MARK: - Private Methods
	private func loadGuidePhoto() async {
		guard let identifier = guidePhotoIdentifier else {
			guidePhoto = nil
			logger.info("There is no guide photo selected.")
			return
		}

		do {
			self.guidePhoto = try await photoLoader.loadPhoto(withIdentifier: identifier)
		} catch {
			logger.error("Failed to load guide photo: \(error)")
			self.guidePhoto = nil
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

	// MARK: - UserDefaults Management
	private func saveGuidePhotoIdentifier(_ identifier: String) {
		self.guidePhotoIdentifier = identifier
		UserDefaults.standard.set(identifier, forKey: UserDefaultsKeys.guidePhotoIdentifier)
	}

	private func loadSavedGuidePhotoIdentifier() {
		if let savedIdentifier = UserDefaults.standard.string(forKey: UserDefaultsKeys.guidePhotoIdentifier) {
			self.guidePhotoIdentifier = savedIdentifier
			Task {
				await loadGuidePhoto()
			}
		}
	}

	private func saveGuidePhotoOpacity() {
		UserDefaults.standard.set(guidePhotoOpacity, forKey: UserDefaultsKeys.guidePhotoOpacity)
	}

	private func loadSavedGuidePhotoOpacity() {
		if let savedOpacity = UserDefaults.standard.object(forKey: UserDefaultsKeys.guidePhotoOpacity) as? Double {
			self.guidePhotoOpacity = savedOpacity
		}
	}

	private func saveGuidePhotoEffect() {
		UserDefaults.standard.set(currentGuidePhotoEffect.rawValue, forKey: UserDefaultsKeys.guidePhotoEffect)
	}

	private func loadSavedGuidePhotoEffect() {
		if let savedEffect = UserDefaults.standard.string(forKey: UserDefaultsKeys.guidePhotoEffect),
		   let effect = GuidePhotoEffect(rawValue: savedEffect) {
			self.currentGuidePhotoEffect = effect
		}
	}

	private func saveGuidePhotoVisibility() {
		UserDefaults.standard.set(shouldShowGuidePhoto, forKey: UserDefaultsKeys.shouldShowGuidePhoto)
	}

	private func loadSavedGuidePhotoVisibility() {
		shouldShowGuidePhoto = UserDefaults.standard.bool(forKey: UserDefaultsKeys.shouldShowGuidePhoto)
	}

	private func saveGuideGridSetting() {
		UserDefaults.standard.set(shouldShowGuideGrid, forKey: UserDefaultsKeys.shouldShowGuideGrid)
	}

	private func loadSavedGuideGridSetting() {
		shouldShowGuideGrid = UserDefaults.standard.bool(forKey: UserDefaultsKeys.shouldShowGuideGrid)
	}
}
