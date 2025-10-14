//
//  WebDocumentView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI
import WebKit

struct WebDocumentView: View {
    let doc: SettingsViewModel.Doc

    var body: some View {
        NavigationStack {
            WebView(url: doc.url, localFallbackFilename: doc.localFallback)
                .navigationTitle(doc.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct WebView: UIViewRepresentable {
    let url: URL
    let localFallbackFilename: String

    func makeUIView(context: Context) -> WKWebView {
        let conf = WKWebViewConfiguration()
        let web = WKWebView(frame: .zero, configuration: conf)
        web.allowsBackForwardNavigationGestures = true
        web.navigationDelegate = context.coordinator
        return web
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if url.isFileURL {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let request = URLRequest(url: url,
                                     cachePolicy: .returnCacheDataElseLoad,
                                     timeoutInterval: 20)
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(localFallbackFilename: localFallbackFilename) }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let localFallbackFilename: String
        init(localFallbackFilename: String) { self.localFallbackFilename = localFallbackFilename }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            loadLocal(into: webView)
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            loadLocal(into: webView)
        }

        private func loadLocal(into webView: WKWebView) {
            if let url = Bundle.main.url(forResource: localFallbackFilename, withExtension: "html") {
                webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            }
        }
    }
}
