// Run from the repository root: swift scripts/render-menubar-icon.swift
// Static template assets only; the app continues to use native template rendering.
import AppKit

// Five 2pt ticks with 2pt gaps, framed by two 1pt rules.
// The separate, dynamic verdict dot supplies the marker beside the glyph.
let rectangles: [CGRect] = [
    CGRect(x: 2, y: 3, width: 18, height: 1),
    CGRect(x: 2, y: 18, width: 18, height: 1)
] + stride(from: 2, through: 18, by: 4).map {
    CGRect(x: $0, y: 7, width: 2, height: 8)
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

for scale in [1, 2] {
    let pixels = 22 * scale
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: pixels * 4, bitsPerPixel: 32)!
    let context = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.cgContext.clear(CGRect(x: 0, y: 0, width: pixels, height: pixels))
    context.cgContext.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
    context.cgContext.setFillColor(NSColor.black.cgColor)
    for rectangle in rectangles { context.cgContext.fill(rectangle) }
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    bitmap.size = NSSize(width: 22, height: 22)
    let suffix = scale == 2 ? "@2x" : ""
    let target = root.appendingPathComponent("Sources/Gauge/Resources/Icons/status-22\(suffix).png")
    try bitmap.representation(using: .png, properties: [:])!.write(to: target)
    print("Rendered \(target.path)")
}
