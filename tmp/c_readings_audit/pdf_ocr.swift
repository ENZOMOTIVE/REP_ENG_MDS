import AppKit
import Foundation
import PDFKit
import Vision

guard CommandLine.arguments.count >= 4 else { exit(2) }
let pdfPath = CommandLine.arguments[1]
let startPage = max(1, Int(CommandLine.arguments[2]) ?? 1)
let requestedEnd = Int(CommandLine.arguments[3]) ?? startPage
let renderDir = CommandLine.arguments.count >= 5 ? CommandLine.arguments[4] : nil
guard let document = PDFDocument(url: URL(fileURLWithPath: pdfPath)) else { exit(1) }
let endPage = min(document.pageCount, requestedEnd)
print("PDF: \(pdfPath) | pages: \(document.pageCount) | OCR: \(startPage)-\(endPage)")

for pageNumber in startPage...endPage {
    autoreleasepool {
        guard let page = document.page(at: pageNumber - 1) else { return }
        let bounds = page.bounds(for: .mediaBox)
        let scale: CGFloat = 2.4
        let width = max(1, Int(bounds.width * scale))
        let height = max(1, Int(bounds.height * scale))
        guard let context = CGContext(data: nil, width: width, height: height,
          bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
        context.setFillColor(NSColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.saveGState()
        context.scaleBy(x: scale, y: scale)
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()
        guard let image = context.makeImage() else { return }
        if let renderDir {
            let directory = URL(fileURLWithPath: renderDir, isDirectory: true)
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let file = directory.appendingPathComponent(String(format: "page-%03d.png", pageNumber))
            let bitmap = NSBitmapImageRep(cgImage: image)
            if let data = bitmap.representation(using: .png, properties: [:]) { try? data.write(to: file) }
        }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        do {
            try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
            let observations = (request.results ?? []).sorted {
                if abs($0.boundingBox.midY - $1.boundingBox.midY) > 0.012 { return $0.boundingBox.midY > $1.boundingBox.midY }
                return $0.boundingBox.minX < $1.boundingBox.minX
            }
            print("\n===== PAGE \(pageNumber) =====")
            for observation in observations { if let text = observation.topCandidates(1).first?.string { print(text) } }
        } catch {
            let e = error as NSError
            fputs("OCR failed page \(pageNumber): \(e.domain) \(e.code) \(e.userInfo)\n", stderr)
        }
    }
}
