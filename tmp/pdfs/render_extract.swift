import AppKit
import Foundation
import PDFKit

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: render_extract.swift INPUT_PDF OUTPUT_DIR\n", stderr)
    exit(2)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

guard let document = PDFDocument(url: inputURL) else {
    fputs("Could not open PDF\n", stderr)
    exit(1)
}

let pageCount = document.pageCount
print("PAGES \(pageCount)")
var combined = ""

for pageIndex in 0..<pageCount {
    guard let page = document.page(at: pageIndex) else { continue }
    let pageNumber = pageIndex + 1
    print("PAGE \(pageNumber) rotation=\(page.rotation) media=\(page.bounds(for: .mediaBox)) crop=\(page.bounds(for: .cropBox)) art=\(page.bounds(for: .artBox))")
    let pageText = page.string ?? ""
    let marker = String(format: "===== PAGE %03d =====\n", pageNumber)
    combined += marker + pageText + "\n\n"

    let textURL = outputURL.appendingPathComponent(String(format: "page-%03d.txt", pageNumber))
    try pageText.write(to: textURL, atomically: true, encoding: .utf8)

    let bounds = page.bounds(for: .mediaBox)
    let scale: CGFloat = 2.0
    let pixelWidth = max(1, Int(ceil(bounds.width * scale)))
    let pixelHeight = max(1, Int(ceil(bounds.height * scale)))
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelWidth,
        pixelsHigh: pixelHeight,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fputs("Could not create bitmap for page \(pageNumber)\n", stderr)
        continue
    }
    bitmap.size = NSSize(width: bounds.width, height: bounds.height)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics
    let context = graphics.cgContext
    context.setFillColor(NSColor.white.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: CGFloat(pixelWidth), height: CGFloat(pixelHeight)))
    context.scaleBy(x: scale, y: scale)
    context.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
    page.draw(with: .mediaBox, to: context)
    NSGraphicsContext.restoreGraphicsState()

    if let png = bitmap.representation(using: .png, properties: [:]) {
        let pngURL = outputURL.appendingPathComponent(String(format: "page-%03d.png", pageNumber))
        try png.write(to: pngURL)
    }
}

try combined.write(to: outputURL.appendingPathComponent("all-pages.txt"), atomically: true, encoding: .utf8)
