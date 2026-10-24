// Run from the repository root: swift scripts/verify-captures.swift
import AppKit

let expected: [String: [[Int]]] = [
    "paper": [[74, 88, 102], [124, 93, 41], [160, 88, 63], [216, 211, 201]],
    "night": [[154, 175, 198], [178, 147, 98], [197, 135, 111], [58, 57, 53]]
]
var failures = 0
for theme in ["paper", "night"] {
    for (index, verdict) in ["good", "fair", "poor", "fair-reduce-motion"].enumerated() {
        let path = "docs/screenshots/gauge-\(theme)-\(verdict).png"
        guard let bitmap = NSBitmapImageRep(data: try Data(contentsOf: URL(fileURLWithPath: path))) else {
            fatalError("Unreadable capture: \(path)")
        }
        func pixel(_ x: Int) -> [Int] {
            // Read encoded samples directly; NSColor conversion can change profiles.
            var components = [Int](repeating: 0, count: 4)
            bitmap.getPixel(&components, atX: x, y: 510)
            return Array(components.prefix(3))
        }
        let fill = expected[theme]![index == 3 ? 1 : index]
        let passed = pixel(50) == fill && pixel(745) == expected[theme]![3]
        print("\(path): \(passed ? "PASS" : "FAIL") (filled and idle tick colors)")
        if !passed { failures += 1 }
    }
}
exit(failures == 0 ? 0 : 1)
