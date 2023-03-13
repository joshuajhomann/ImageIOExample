//
//  UTTypesRepresentable.swift
//  ImageIOExample
//
//  Created by Joshua Homann on 3/11/23.
//

import ImageIO
import UniformTypeIdentifiers

protocol UTTypesRepresentable {
    var uniformTypes: [UTType] { get }
}

struct AnyUniformTypeArray: UTTypesRepresentable {
    var uniformTypes: [UTType]
}

extension AnyUniformTypeArray {
    init(identifiers: [String]) {
        uniformTypes = identifiers.compactMap(UTType.init(_:))
    }
    init(identifier: String) {
        self = .init(identifiers: [identifier])
    }
}

extension UTTypesRepresentable where Self == AnyUniformTypeArray {
    static var jpeg: Self {
        .init(identifier: "public.jpeg")
    }
    static var imageIOImport: Self {
        .init(identifiers: CGImageSourceCopyTypeIdentifiers() as? [String] ?? [])
    }
    static var imageIOExport: Self {
        .init(identifiers: CGImageDestinationCopyTypeIdentifiers() as? [String] ?? [])
    }
}
