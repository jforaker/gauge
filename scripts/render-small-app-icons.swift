import AppKit

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconSet = root.appendingPathComponent("Sources/Gauge/Resources/Icons/gauge.iconset")

let background = NSColor(red: 0.06, green: 0.07, blue: 0.065, alpha: 1).cgColor
let rule = NSColor(red: 0.38, green: 0.40, blue: 0.37, alpha: 1).cgColor
let bright = NSColor(red: 0.91, green: 0.90, blue: 0.84, alpha: 1).cgColor
let dim = NSColor(red: 0.40, green: 0.40, blue: 0.36, alpha: 1).cgColor
let marker = NSColor(red: 0.60, green: 0.70, blue: 0.79, alpha: 1).cgColor

func fill(_ rect: CGRect, color: CGColor, in context: CGContext, scale: CGFloat) {
    context.setFillColor(color)
    context.fill(rect.applying(CGAffineTransform(scaleX: scale, y: scale)))
}

for scale in [1, 2] {
    let pixels = 16 * scale
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: pixels * 4,
        bitsPerPixel: 32
    )!
    let context = NSGraphicsContext(bitmapImageRep: bitmap)!.cgContext
    context.setShouldAntialias(false)

    let factor = CGFloat(scale)
    fill(CGRect(x: 0, y: 0, width: 16, height: 16), color: background, in: context, scale: factor)
    fill(CGRect(x: 2, y: 3, width: 12, height: 1), color: rule, in: context, scale: factor)
    fill(CGRect(x: 2, y: 12, width: 12, height: 1), color: rule, in: context, scale: factor)

    for x in [3, 5, 7, 9] {
        fill(CGRect(x: x, y: 5, width: 1, height: 6), color: bright, in: context, scale: factor)
    }
    fill(CGRect(x: 11, y: 5, width: 1, height: 6), color: dim, in: context, scale: factor)
    fill(CGRect(x: 11, y: 11, width: 2, height: 1), color: marker, in: context, scale: factor)

    bitmap.size = NSSize(width: 16, height: 16)
    let suffix = scale == 2 ? "@2x" : ""
    let target = iconSet.appendingPathComponent("icon_16x16\(suffix).png")
    try bitmap.representation(using: .png, properties: [:])!.write(to: target)
    print("Rendered \(target.path)")
}
