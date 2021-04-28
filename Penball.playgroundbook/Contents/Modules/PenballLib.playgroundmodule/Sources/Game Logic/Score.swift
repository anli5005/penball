//
//  Bests.swift
//  PenballLib
//
//  Created by Anthony Li on 4/17/21.
//

import Foundation

// Structure representing score obtained from a level.
public struct Score {
    // Time between when the level was started and when it was completed.
    var time: TimeInterval
    
    // Number of strokes the user drew before and during the level.
    // Erasing strokes after the level starts doesn't count.
    var strokes: Int
    
    static let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    // Formatted version of the elapsed time.
    var timeString: String? {
        Self.formatter.string(from: time)
    }
}
