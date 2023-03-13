//
//  Outline.swift
//  ImageIOExample
//
//  Created by Joshua Homann on 3/11/23.
//

import Foundation

struct Outline: Identifiable {
    var id: UUID = .init()
    var title: String
    var content: String? = nil
    var children: [Self]?
}

extension Outline {
    static func make(from dictionary: [String: Any]) -> [Outline] {
        dictionary.keys.sorted().compactMap { key -> Outline? in
            switch dictionary[key] {
            case nil: return nil
            case let value as [String: Any]:
                return .init(title: key, children: Outline.make(from: value))
            case let .some(value):
                return .init(title: key, content: String(describing: value), children: nil)
            }
        }
    }
}
