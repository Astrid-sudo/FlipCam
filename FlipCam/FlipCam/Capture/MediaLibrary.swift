//
//  MediaLibrary.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/13.
//

import Foundation
import Photos
import UIKit

actor MediaLibrary {

	enum Error: Swift.Error {
		case unauthorized
		case saveFailed
	}

	let thumbnails: AsyncStream<CGImage?>
	private let continuation: AsyncStream<CGImage?>.Continuation?

	init() {
		let (thumbnails, continuation) = AsyncStream.makeStream(of: CGImage?.self)
		self.thumbnails = thumbnails
		self.continuation = continuation
	}

	// MARK: - Authorization

	private var isAuthorized: Bool {
		get async {
			let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
			var isAuthorized = status == .authorized
			if status == .notDetermined {
				let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
				isAuthorized = status == .authorized
			}
			return isAuthorized
		}
	}

	// MARK: - Saving media

	/// Saves a photo to the Photos library.
	func save(photo: Photo) async throws {
		let location = try await currentLocation
		do {
			try await performChange {
				let creationRequest = PHAssetCreationRequest.forAsset()

				// Save primary photo.
				let options = PHAssetResourceCreationOptions()
				// Specify the appropriate resource type for the photo.
				creationRequest.addResource(with: photo.isProxy ? .photoProxy : .photo, data: photo.data, options: options)
				creationRequest.location = location

				return creationRequest.placeholderForCreatedAsset
			}
		} catch {
			throw CameraError.mediaLibraryUnauthorized
		}
	}

	private func performChange(_ change: @Sendable @escaping () -> PHObjectPlaceholder?) async throws {
		guard await isAuthorized else {
			throw Error.unauthorized
		}

		do {
			var placeholder: PHObjectPlaceholder?
			try await PHPhotoLibrary.shared().performChanges {
				placeholder = change()
			}

			if let placeholder {
				guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier],
													  options: nil).firstObject else { return }
				await createThumbnail(for: asset)
			}
		} catch {
			throw Error.saveFailed
		}
	}

	// MARK: - Thumbnail handling

	private func loadInitialThumbnail() async {
		guard PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized else { return }

		let options = PHFetchOptions()
		options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		if let asset = PHAsset.fetchAssets(with: options).lastObject {
			await createThumbnail(for: asset)
		}
	}

	private func createThumbnail(for asset: PHAsset) async {
		PHImageManager.default().requestImage(for: asset,
											  targetSize: .init(width: 256, height: 256),
											  contentMode: .default,
											  options: nil) { [weak self] image, _ in
			guard let self, let image = image else { return }
			continuation?.yield(image.cgImage)
		}
	}

	// MARK: - Location management

	private let locationManager = CLLocationManager()

	private var currentLocation: CLLocation? {
		get async throws {
			if locationManager.authorizationStatus == .notDetermined {
				locationManager.requestWhenInUseAuthorization()
			}
			return try await CLLocationUpdate.liveUpdates().first(where: { _ in true })?.location
		}
	}

	// MARK: - Loading photos by identifier
	func loadPhoto(withIdentifier identifier: String) async throws -> UIImage? {
		guard await isAuthorized else {
			throw Error.unauthorized
		}
		
		let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
		guard let asset = fetchResult.firstObject else {
			return nil
		}
		
		return await withCheckedContinuation { continuation in
			let options = PHImageRequestOptions()
			options.deliveryMode = .highQualityFormat
			options.isNetworkAccessAllowed = true
			options.isSynchronous = false
			
			PHImageManager.default().requestImage(
				for: asset,
				targetSize: PHImageManagerMaximumSize,
				contentMode: .default,
				options: options
			) { image, info in
				continuation.resume(returning: image)
			}
		}
	}
}

