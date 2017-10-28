//
//  CategoryColor.swift
//  RandomMe
//
//  Created by Joe on 14.09.17.
//
//

import Foundation

typealias CategoryColor = MaterialColor

enum MaterialColor: Int, CustomStringConvertible {
    
    case black = 0, red, purple, indigo, lightBlue, cyan, teal, green, amber
    
    static var count: Int { return MaterialColor.amber.hashValue + 1 }
    
    var description: String {
        switch self {
            case .black   : return "Black"
            case .red : return "Red"
            case .purple : return "Purple"
            case .indigo : return "Indigo"
            case .lightBlue : return "Light Blue"
            case .cyan : return "Cyan"
            case .teal : return "Teal"
            case .green : return "Green"
            case .amber : return "Amber"
        }
    }
    
    var hexCode: String {
        switch self {
        case .black   : return "#434343"
        case .red : return "#FF1744"
        case .purple : return "#E040FB"
        case .indigo : return "#536DFE"
        case .lightBlue : return "#40C4FF"
        case .cyan : return "#00BCD4"
        case .teal : return "#009688"
        case .green : return "#4CAF50"
        case .amber : return "#FFC400"
        }
    }
    
    static var palette: [String] {
        return [0..<self.count].flatMap{$0}.map{ MaterialColor(rawValue: $0)!.description }
    }
    
    static var paletteCodes: [String] {
        return [0..<self.count].flatMap{$0}.map{ MaterialColor(rawValue: $0)!.hexCode }
    }
    
    static func parse(colorName _color: String) -> String {
        let index = MaterialColor.palette.index(of: _color) ?? 0
        return MaterialColor(rawValue: index)!.hexCode
    }
    
    static func invert(hexColor _color: String) -> String {
        let index = MaterialColor.paletteCodes.index(of: _color) ?? 0
        return MaterialColor(rawValue: index)!.description
    }
}
