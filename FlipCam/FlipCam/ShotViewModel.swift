//
//  ShotViewModel.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import SwiftUI
import Combine

// MARK: - Input/Output Types

struct ShotViewModelInput {
	// Camera actions
	let startCamera = PassthroughSubject<Void, Never>()
	let switchCameraDevices = PassthroughSubject<Void, Never>()
	let capturePhoto = PassthroughSubject<Void, Never>()
	let focusAndExpose = PassthroughSubject<CGPoint, Never>()
	
	// Guide photo actions
	let applyGuidePhoto = PassthroughSubject<String, Never>()
	let setGuidePhotoOpacity = PassthroughSubject<Double, Never>()
	let setGuidePhotoEffect = PassthroughSubject<GuidePhotoEffect, Never>()
	let toggleGuidePhotoVisibility = PassthroughSubject<Void, Never>()
	let toggleGuideGrid = PassthroughSubject<Void, Never>()
}

final class ShotViewModelOutput: ObservableObject {
	// Camera state
	@Published var cameraStatus: CameraStatus = .unknown
	@Published var captureActivity: CaptureActivity = .idle
	@Published var isSwitchingCameraDevices: Bool = false
	@Published var shouldFlashScreen: Bool = false
	@Published var thumbnail: Image?
	
	// Guide photo state
	@Published var guidePhotoIdentifier: String?
	@Published var guidePhotoOpacity: Double = 0.5
	@Published var currentGuidePhotoEffect: GuidePhotoEffect = .normal
	@Published var processedGuidePhoto: UIImage?
	@Published var shouldShowGuidePhoto: Bool = true
	@Published var shouldShowGuideGrid: Bool = false
	
	// Error handling
	@Published var error: Error?
	@Published var showErrorAlert: Bool = false
}

// MARK: - View Model Protocol

protocol ShotViewModelType {
	var input: ShotViewModelInput { get }
	var output: ShotViewModelOutput { get }
}

// MARK: - View Model Implementation

@MainActor
final class ShotViewModel: ShotViewModelType {
	// MARK: - Properties
	
	let input: ShotViewModelInput
	let output: ShotViewModelOutput
	let cameraController: CameraController
	
	private let guidePhotoController: GuidePhotoController
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Initialization
	
	private init(cameraController: CameraController, guidePhotoController: GuidePhotoController) {
		self.cameraController = cameraController
		self.guidePhotoController = guidePhotoController
		self.input = ShotViewModelInput()
		self.output = ShotViewModelOutput()
		
		setupBindings()
	}
	
	static func create() async -> ShotViewModel {
		let cameraController = CameraController()
		let guidePhotoController = GuidePhotoController(photoLoader: cameraController)
		return ShotViewModel(cameraController: cameraController, guidePhotoController: guidePhotoController)
	}
	
	// MARK: - Private Methods
	
	private func setupBindings() {
		// Camera bindings
		input.startCamera
			.sink { [weak self] _ in
				Task {
					await self?.startCamera()
				}
			}
			.store(in: &cancellables)
		
		input.switchCameraDevices
			.sink { [weak self] _ in
				Task {
					await self?.switchCameraDevices()
				}
			}
			.store(in: &cancellables)
		
		input.capturePhoto
			.sink { [weak self] _ in
				Task {
					await self?.capturePhoto()
				}
			}
			.store(in: &cancellables)
		
		input.focusAndExpose
			.sink { [weak self] point in
				Task {
					await self?.focusAndExpose(at: point)
				}
			}
			.store(in: &cancellables)
		
		// Guide photo bindings
		input.applyGuidePhoto
			.sink { [weak self] identifier in
				self?.applyGuidePhoto(identifier)
			}
			.store(in: &cancellables)
		
		input.setGuidePhotoOpacity
			.sink { [weak self] opacity in
				self?.setGuidePhotoOpacity(opacity)
			}
			.store(in: &cancellables)
		
		input.setGuidePhotoEffect
			.sink { [weak self] effect in
				self?.setGuidePhotoEffect(effect)
			}
			.store(in: &cancellables)
		
		input.toggleGuidePhotoVisibility
			.sink { [weak self] _ in
				self?.toggleGuidePhotoVisibility()
			}
			.store(in: &cancellables)
		
		input.toggleGuideGrid
			.sink { [weak self] _ in
				self?.toggleGuideGrid()
			}
			.store(in: &cancellables)
		
		// Camera state bindings
		Task { @MainActor in
			for await status in cameraController.cameraStatus {
				output.cameraStatus = status
			}
		}
		
		Task { @MainActor in
			for await activity in cameraController.captureActivity {
				output.captureActivity = activity
			}
		}
		
		Task { @MainActor in
			for await isSwitching in cameraController.isSwitchingCameraDevices {
				output.isSwitchingCameraDevices = isSwitching
			}
		}
		
		Task { @MainActor in
			for await shouldFlash in cameraController.shouldFlashScreen {
				output.shouldFlashScreen = shouldFlash
			}
		}
		
		Task { @MainActor in
			for await thumbnail in cameraController.thumbnail {
				if let thumbnail = thumbnail {
					output.thumbnail = Image(thumbnail)
				} else {
					output.thumbnail = nil
				}
			}
		}
		
		// Guide photo state bindings
		Task { @MainActor in
			for await identifier in guidePhotoController.guidePhotoIdentifier {
				output.guidePhotoIdentifier = identifier
			}
		}
		
		Task { @MainActor in
			for await opacity in guidePhotoController.guidePhotoOpacity {
				output.guidePhotoOpacity = opacity
			}
		}
		
		Task { @MainActor in
			for await effect in guidePhotoController.currentGuidePhotoEffect {
				output.currentGuidePhotoEffect = effect
			}
		}
		
		Task { @MainActor in
			for await photo in guidePhotoController.processedGuidePhoto {
				if let photo = photo {
					output.processedGuidePhoto = Image(photo)
				} else {
					output.processedGuidePhoto = nil
				}
			}
		}
		
		Task { @MainActor in
			for await shouldShow in guidePhotoController.shouldShowGuidePhoto {
				output.shouldShowGuidePhoto = shouldShow
			}
		}
		
		Task { @MainActor in
			for await shouldShow in guidePhotoController.shouldShowGuideGrid {
				output.shouldShowGuideGrid = shouldShow
			}
		}
	}
	
	// MARK: - Camera Methods
	
	private func startCamera() async {
		do {
			try await cameraController.start()
		} catch {
			handleError(error)
		}
	}
	
	private func switchCameraDevices() async {
		do {
			try await cameraController.switchCameraDevices()
		} catch {
			handleError(error)
		}
	}
	
	private func capturePhoto() async {
		do {
			try await cameraController.capturePhoto()
		} catch {
			handleError(error)
		}
	}
	
	private func focusAndExpose(at point: CGPoint) async {
		do {
			try await cameraController.focusAndExpose(at: point)
		} catch {
			handleError(error)
		}
	}
	
	// MARK: - Guide Photo Methods
	
	private func applyGuidePhoto(_ identifier: String) {
		guidePhotoController.applyGuidePhoto(identifier)
	}
	
	private func setGuidePhotoOpacity(_ opacity: Double) {
		guidePhotoController.setGuidePhotoOpacity(opacity)
	}
	
	private func setGuidePhotoEffect(_ effect: GuidePhotoEffect) {
		guidePhotoController.setGuidePhotoEffect(effect)
	}
	
	private func toggleGuidePhotoVisibility() {
		guidePhotoController.toggleGuidePhotoVisibility()
	}
	
	private func toggleGuideGrid() {
		guidePhotoController.toggleGuideGrid()
	}
	
	// MARK: - Error Handling
	
	private func handleError(_ error: Error) {
		output.error = error
		output.showErrorAlert = true
	}
}
