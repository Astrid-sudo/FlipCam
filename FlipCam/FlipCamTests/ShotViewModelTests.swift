//
//  ShotViewModelTests.swift
//  FlipCamTests
//
//  Created by Astrid Lin on 2025/3/29.
//
import UIKit
import Testing
@testable import FlipCam

@Suite("ShotViewModel Tests")
struct ShotViewModelTests {
	@Test("ShotViewModel can be created")
	func testViewModelCreation() async throws {
		let viewModel = await ShotViewModel.create()

		await #expect(viewModel.input != nil)
		await #expect(viewModel.output != nil)
	}

	@Test("Guide photo can be applied through view model")
	func testGuidePhotoApplication() async throws {
		let mockPhotoLoader = MockPhotoLoader()
		let viewModel = await ShotViewModel(cameraController: CameraController(),
											guidePhotoController: GuidePhotoController(photoLoader: mockPhotoLoader))

		let testIdentifier = "test_photo"
		await viewModel.input.applyGuidePhoto(testIdentifier)

		await #expect(viewModel.output.guidePhotoIdentifier == testIdentifier)
		await #expect(viewModel.output.processedGuidePhoto != nil)
	}

	@Test("Guide photo effect can be set through view model")
	func testGuidePhotoEffect() async throws {
		let mockPhotoLoader = MockPhotoLoader()
		let viewModel = await ShotViewModel(cameraController: CameraController(),
											guidePhotoController: GuidePhotoController(photoLoader: mockPhotoLoader))

		let testEffect = GuidePhotoEffect.outline
		await viewModel.input.setGuidePhotoEffect(testEffect)

		await #expect(viewModel.output.currentGuidePhotoEffect == testEffect)
		await #expect(viewModel.output.processedGuidePhoto != nil)
	}

	private class MockPhotoLoader: PhotoLoader {
		func loadPhoto(withIdentifier identifier: String) async throws -> UIImage {
			return UIImage()
		}
	}
}
