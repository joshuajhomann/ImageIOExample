//
//  ContentView.swift
//  ImageIOExample
//
//  Created by Joshua Homann on 3/10/23.
//

import Combine
import ImageIO
import SwiftUI

@MainActor
final class ViewModel: ObservableObject {
    @Published var pickFile = false
    @Published var selectedFileURL: URL?
    @Published var image: UIImage?
    @Published var metaData: [Outline] = []
    let size = CurrentValueSubject<CGSize, Never>(.zero)
    init() {
        func p(types: any UTTypesRepresentable) {
            types.uniformTypes.map(\.identifier).forEach { print($0) }
        }
        print("---IMPORT--")
        p(types: .imageIOImport)
        print("---EXPORT--")
        p(types: .imageIOExport)
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        let imageSource =  $selectedFileURL
            .map { url in
                url.flatMap { url in
                    CGImageSourceCreateWithURL(
                        url as CFURL,
                        [kCGImageSourceShouldCache: false] as CFDictionary
                    )
                }
            }

        imageSource
            .map { source in
                source.flatMap { source in
                    (CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any])
                }
                    .map(Outline.make(from:)) ?? []
            }
            .assign(to: &$metaData)

        Publishers.CombineLatest(
            imageSource,
            size
                .removeDuplicates()
                .filter { $0 != .zero }
                .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
        )
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .map { (source, size) in
            guard let source else { return nil }
            let options = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
            ] as CFDictionary
            return CGImageSourceCreateThumbnailAtIndex(source, 0, options)
                .map(UIImage.init(cgImage:))
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$image)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.displayScale) var displayScale
    var body: some View {
        NavigationStack {
            let isVertical = horizontalSizeClass == .compact
            let stack = isVertical ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
            stack {
                GeometryReader { proxy in
                    let _ = viewModel.size.send(.init(
                        width: proxy.size.width * displayScale,
                        height: proxy.size.height * displayScale
                    ))
                    ZStack {
                        Color(uiColor: .systemBackground)
                        if let image = viewModel.image {
                            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
                        } else {
                            Button("Select a file...") { viewModel.pickFile = true }
                        }
                    }
                }
                .toolbar {
                    if viewModel.selectedFileURL != nil {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                viewModel.selectedFileURL = nil
                                viewModel.image = nil
                                viewModel.metaData = []
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.pickFile = true
                        } label: {
                            Image(systemName: "photo")
                        }
                    }
                }
                .sheet(isPresented: $viewModel.pickFile) { FilePicker(types: .imageIOImport, selectedFileURL: $viewModel.selectedFileURL)
                }
                if !viewModel.metaData.isEmpty {
                    List(viewModel.metaData) { datum in
                        OutlineGroup(datum, children: \.children) { datum in
                            LabeledContent(datum.title) {
                                datum.content.map(Text.init(_:))
                            }
                        }
                    }
                    .listStyle(.sidebar)
                    .frame(maxWidth: isVertical ? .infinity : 400)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
