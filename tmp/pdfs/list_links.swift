import Foundation
import PDFKit

guard CommandLine.arguments.count == 2,
      let document = PDFDocument(url: URL(fileURLWithPath: CommandLine.arguments[1])) else {
    fputs("usage: list_links.swift INPUT.pdf\n", stderr)
    exit(2)
}

for pageIndex in 0..<document.pageCount {
    guard let page = document.page(at: pageIndex) else { continue }
    for annotation in page.annotations {
        if let url = annotation.url {
            print("page \(pageIndex + 1): \(url.absoluteString)")
        }
    }
}
