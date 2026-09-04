import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpStatus(code: Int, message: String?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpStatus(let code, let message):
            return message ?? "The request failed with status code \(code)."
        case .decoding:
            return "The server response could not be read."
        }
    }
}

struct MultipartFile {
    let data: Data
    let fieldName: String
    let fileName: String
    let mimeType: String
}

actor NetworkClient {
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH
    }

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var bearerToken: String?

    init(
        baseURL: URL,
        bearerToken: String? = nil,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.baseURL = baseURL
        self.bearerToken = bearerToken
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func setToken(_ token: String?) {
        bearerToken = token
    }

    func get<T: Decodable>(
        _ path: String,
        query: [URLQueryItem] = []
    ) async throws -> T {
        try await request(path, method: .GET, query: query)
    }

    func post<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body
    ) async throws -> T {
        let data = try encoder.encode(body)
        return try await request(path, method: .POST, body: data)
    }

    func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .GET,
        query: [URLQueryItem] = [],
        body: Data? = nil
    ) async throws -> T {
        let request = try makeRequest(
            path: path,
            method: method,
            query: query,
            body: body,
            contentType: body == nil ? nil : "application/json",
            timeout: 30
        )
        let data = try await execute(request)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    func request(
        _ path: String,
        method: HTTPMethod = .GET,
        query: [URLQueryItem] = [],
        body: Data? = nil
    ) async throws {
        let request = try makeRequest(
            path: path,
            method: method,
            query: query,
            body: body,
            contentType: body == nil ? nil : "application/json",
            timeout: 30
        )
        _ = try await execute(request)
    }

    func uploadMultipart<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .POST,
        query: [URLQueryItem] = [],
        parameters: [String: String] = [:],
        files: [MultipartFile]
    ) async throws -> T {
        let boundary = "Boundary-\(UUID().uuidString)"
        let body = makeMultipartBody(
            boundary: boundary,
            parameters: parameters,
            files: files
        )
        let request = try makeRequest(
            path: path,
            method: method,
            query: query,
            body: body,
            contentType: "multipart/form-data; boundary=\(boundary)",
            timeout: 120
        )
        let data = try await execute(request)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    func download(from url: URL) async throws -> Data {
        let request = URLRequest(url: url, timeoutInterval: 30)
        return try await execute(request)
    }

    private func makeRequest(
        path: String,
        method: HTTPMethod,
        query: [URLQueryItem],
        body: Data?,
        contentType: String?,
        timeout: TimeInterval
    ) throws -> URLRequest {
        let normalizedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpoint = baseURL.appendingPathComponent(normalizedPath)
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        components.queryItems = query.isEmpty ? nil : query
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.httpBody = body

        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        if let bearerToken, !bearerToken.isEmpty {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func execute(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard 200..<300 ~= response.statusCode else {
            throw NetworkError.httpStatus(
                code: response.statusCode,
                message: Self.serverMessage(from: data)
            )
        }
        return data
    }

    private func makeMultipartBody(
        boundary: String,
        parameters: [String: String],
        files: [MultipartFile]
    ) -> Data {
        var body = Data()

        for (name, value) in parameters.sorted(by: { $0.key < $1.key }) {
            body.appendUTF8("--\(boundary)\r\n")
            body.appendUTF8("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.appendUTF8("\(value)\r\n")
        }

        for file in files {
            body.appendUTF8("--\(boundary)\r\n")
            body.appendUTF8("Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\r\n")
            body.appendUTF8("Content-Type: \(file.mimeType)\r\n\r\n")
            body.append(file.data)
            body.appendUTF8("\r\n")
        }

        body.appendUTF8("--\(boundary)--\r\n")
        return body
    }

    private static func serverMessage(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }
        return object["detail"] as? String
            ?? object["message"] as? String
            ?? object["error"] as? String
    }
}

private extension Data {
    nonisolated mutating func appendUTF8(_ string: String) {
        append(contentsOf: string.utf8)
    }
}
