import Foundation

// MARK: - UserDefaults Keys
enum UserDefaultsKeys {
    static let guidePhotoIdentifier = "guidePhotoIdentifier"
    static let guidePhotoOpacity = "guidePhotoOpacity"
    static let guidePhotoEffect = "guidePhotoEffect"
    static let shouldShowGuidePhoto = "shouldShowGuidePhoto"
    static let shouldShowGuideGrid = "shouldShowGuideGrid"
}

// MARK: - Error Messages
enum ErrorMessages {
	static let error = "Error"
	static let exitFlipCam = "Exit FlipCam"
	static let ok = "OK"
	static let restart = "Error occurred, please restart the app."
    static let noVideoDevice = "No video device found for current input"
    static let cameraInputFailed = "Failed to add camera input to capture session"
    static let outputFailed = "Failed to add output to capture session"
    static let sessionSetupFailed = "Failed to set up camera capture session"
    static let deviceChangeFailed = "Failed to change camera device"
    static let cameraAccessDenied = "Camera access is not authorized, please go to Settings > Apps > FlipCam to turn on Camera access permission."
    static let previewLayerNotFound = "Camera preview layer not found"
    static let noActiveCameraInput = "No active camera input found"
    static let photosAccessDenied = "Photos access is not authorized, please go to Settings > Apps > FlipCam to turn on Photos access permission."
    static let guidePhotoLoadFailed = "Failed to load guide photo, pick another photo please."
}

// MARK: - System Image Names
enum SystemImageNames {
    static let photo = "photo"
    static let diagonalPatternRectangle = "circle.filled.pattern.diagonalline.rectangle"
    static let diagonalPatternRectangleFilled = "circle.rectangle.filled.pattern.diagonalline"
    static let pencilScribble = "applepencil.and.scribble"
    static let grid = "grid"
    static let photoStack = "photo.stack"
    static let eye = "eye"
    static let eyeSlash = "eye.slash"
    static let circleLeftHalfFilled = "circle.lefthalf.filled"
    static let boltSlashFill = "bolt.slash.fill"
    static let boltFill = "bolt.fill"
    static let boltBadgeA = "bolt.badge.a"
    static let cameraSwitch = "arrow.triangle.2.circlepath"
}

// MARK: - Filter Names
enum FilterNames {
    static let colorControls = "CIColorControls"
    static let colorInvert = "CIColorInvert"
    static let edges = "CIEdges"
}

// MARK: - Other Constants
enum OtherConstants {
    static let systemPreferredCameraKeyPath = "systemPreferredCamera"
    static let creationDateKey = "creationDate"
    static let launchScreenName = "Launch Screen"
    static let defaultAccentColorHex = "1BA3CE"
} 
