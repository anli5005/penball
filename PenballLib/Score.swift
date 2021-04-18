//
//  Bests.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

public struct Score {
    var time: TimeInterval
    var strokes: Int
    
    static let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var timeString: String? {
        Self.formatter.string(from: time)
    }
}
