//
//  ShotViewModel.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import SwiftUI

@Observable
final class ShotViewModel: Camera {

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
