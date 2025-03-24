import SwiftUI

@Observable
final class CameraController: Camera {
    var previewSource: PreviewSource { captureService.previewSource }
    private let captureService = CaptureService()
    private let mediaLibrary = MediaLibrary()
    
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
    var flashMode: FlashMode = .off
    
    init() {
        observeThumbnails()
    }
    
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
    
    func switchCameraDevices() async {
        isSwitchingCameraDevices = true
        defer { isSwitchingCameraDevices = false }
        do {
            try await captureService.selectNextCameraDevice()
        } catch {
            handleError(error)
        }
    }
    
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
    
    func setFlashMode(_ mode: FlashMode) async {
        flashMode = mode
        await captureService.setFlashMode(mode)
    }
    
    private func flashScreen() {
        shouldFlashScreen = true
        withAnimation(.linear(duration: 0.01)) {
            shouldFlashScreen = false
        }
    }
    
    private func handleError(_ error: Error) {
        self.error = error
        self.showErrorAlert = true
    }
    
    private func observeState() {
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
    
    func loadPhoto(withIdentifier identifier: String) async throws -> UIImage {
		guard let photo = try await mediaLibrary.loadPhoto(withIdentifier: identifier) else {
			throw CameraError.loadGuidePhotoFailed
		}
		return photo
    }
    
    private func observeThumbnails() {
        Task {
            for await thumbnail in mediaLibrary.thumbnails.compactMap({ $0 }) {
                self.thumbnail = thumbnail
            }
        }
    }
} 
