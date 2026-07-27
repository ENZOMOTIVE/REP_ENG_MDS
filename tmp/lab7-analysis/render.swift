import AppKit
import Foundation
import PDFKit

let input = URL(fileURLWithPath: CommandLine.arguments[1])
let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
guard let document = PDFDocument(url: input) else { fatalError("Unable to open PDF") }
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
for pageIndex in 0..<document.pageCount {
    guard let page = document.page(at: pageIndex) else { continue }
    let bounds = page.bounds(for: .mediaBox)
    let scale: CGFloat = 2
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(bounds.width * scale),
        pixelsHigh: Int(bounds.height * scale),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else { continue }
    bitmap.size = bounds.size
    NSGraphicsContext.saveGraphicsState()
    guard let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmap) else { continue }
    NSGraphicsContext.current = graphicsContext
    NSColor.white.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: bounds.size)).fill()
    page.draw(with: .mediaBox, to: graphicsContext.cgContext)
    NSGraphicsContext.restoreGraphicsState()
    guard let data = bitmap.representation(using: .png, properties: [:]) else { continue }
    try data.write(to: outputDirectory.appendingPathComponent(String(format: "page-%02d.png", pageIndex + 1)))
}
