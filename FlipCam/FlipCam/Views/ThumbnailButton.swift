//
//  ThumbnailButton.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/16.
//

import SwiftUI
import PhotosUI

struct ThumbnailButton<CameraModel: Camera>: View {

	@State var camera: CameraModel

	@State private var selectedItem: PhotosPickerItem?

	var body: some View {
		PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
			thumbnail
		}
		.frame(width: 64.0, height: 64.0)
		.cornerRadius(8)
		.onChange(of: selectedItem) { _, newItem in
			if let newItem {
				Task {
					if let identifier = newItem.itemIdentifier {
						camera.saveGuidePhotoIdentifier(identifier)
					} else {
						print("Can't find identifier")
					}
				}
			}
		}
	}

	@ViewBuilder
	var thumbnail: some View {
		if let thumbnail = camera.thumbnail {
			Image(thumbnail)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.animation(.easeInOut(duration: 0.3), value: thumbnail)
		} else {
			Image(systemName: "photo.stack")
		}
	}
}

