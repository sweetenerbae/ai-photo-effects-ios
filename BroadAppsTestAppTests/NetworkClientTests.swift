import Foundation
import XCTest
@testable import BroadAppsTestApp

final class NetworkClientTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.handler = nil
        super.tearDown()
    }

    func testGetAddsAuthorizationQueryAndDecodesResponse() async throws {
        URLProtocolStub.handler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
            XCTAssertEqual(
                URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false)?
                    .queryItems,
                [URLQueryItem(name: "lang", value: "en")]
            )

            let response = try XCTUnwrap(
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
            )
            return (response, Data(#"{"id":42,"name":"Portrait"}"#.utf8))
        }

        let client = try makeClient(token: "test-token")
        let result: ResponseFixture = try await client.get(
            "/api/effects",
            query: [URLQueryItem(name: "lang", value: "en")]
        )

        XCTAssertEqual(result, ResponseFixture(id: 42, name: "Portrait"))
    }

    func testRequestThrowsTypedErrorForServerFailure() async throws {
        URLProtocolStub.handler = { request in
            let response = try XCTUnwrap(
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: 422,
                    httpVersion: nil,
                    headerFields: nil
                )
            )
            return (response, Data(#"{"detail":"Invalid prompt"}"#.utf8))
        }

        let client = try makeClient()

        do {
            let _: ResponseFixture = try await client.get("/api/effects")
            XCTFail("Expected NetworkError.httpStatus")
        } catch NetworkError.httpStatus(let code, let message) {
            XCTAssertEqual(code, 422)
            XCTAssertEqual(message, "Invalid prompt")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func makeClient(token: String? = nil) throws -> NetworkClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return NetworkClient(
            baseURL: try XCTUnwrap(URL(string: "https://example.com")),
            bearerToken: token,
            session: session
        )
    }
}

private struct ResponseFixture: Codable, Equatable {
    let id: Int
    let name: String
}

private final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override nonisolated class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override nonisolated class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override nonisolated func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override nonisolated func stopLoading() {}
}
