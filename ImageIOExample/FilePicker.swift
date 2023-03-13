//
//  FilePicker.swift
//  ImageIOExample
//
//  Created by Joshua Homann on 3/11/23.
//

import SwiftUI
import UIKit

struct FilePicker: UIViewControllerRepresentable {
    var types: any UTTypesRepresentable
    @Binding var selectedFileURL: URL?
    @Environment(\.dismiss) private var dismiss
    func makeCoordinator() -> Coordinator {
        .init(types: types, selectedFileURL: _selectedFileURL, dismiss: dismiss)
    }
    func makeUIViewController(context: Context) -> some UIViewController {
        context.coordinator.viewController
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    final class Coordinator: NSObject, UIDocumentBrowserViewControllerDelegate {
        let viewController: UIDocumentBrowserViewController
        var selectedFileURL: Binding<URL?>
        let dismiss: DismissAction
        init(
            types: any UTTypesRepresentable,
            selectedFileURL: Binding<URL?>,
            dismiss: DismissAction
        ) {
            viewController = .init(forOpening: types.uniformTypes)
            self.selectedFileURL = selectedFileURL
            self.dismiss = dismiss
            super.init()
            viewController.delegate = self
            viewController.allowsDocumentCreation = false
            viewController.allowsPickingMultipleItems = false
            viewController.additionalLeadingNavigationBarButtonItems = [
                .init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            ]
        }
        @objc func cancel() {
            dismiss()
        }
        func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
            selectedFileURL.wrappedValue = documentURLs.first
            dismiss()
        }
    }
}
