import Foundation

protocol Servicing {
    func fetchData<T: Decodable>(urlText: String,
                                 resultType: T.Type,
                                 completion: @escaping (Result<T, RequestError>) -> Void)
}


protocol CatServicing {
    func fetchCat(url: URL?, completion: @escaping (Result<Cat, RequestError>) -> Void)
}

struct Service: CatServicing {
    func fetchCat(url: URL?, completion: @escaping (Result<Cat, RequestError>) -> Void) {
        guard let url = url else {
            completion(.failure(.invalidUrl))
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                if let requestError = getError(with: response) {
                    completion(.failure(requestError))
                }
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode(Cat.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func getError(with response: URLResponse?)  -> RequestError? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .invalidResponse
        }
        
        let statusCode = StatusCode.getType(code: httpResponse.statusCode)
        
        return statusCode == .success ? nil : .serverError
    }
}

enum RequestError: Error {
    case invalidUrl
    case invalidData
    case invalidResponse
    case serverError
    case unknown
}

enum StatusCode: Equatable {
    case informational
    case success
    case redirection
    case clientError
    case serverError
    case unknown
    
    static func getType(code: Int) -> Self {
        switch code {
        case 100..<200:
            return .informational
        case 200..<300:
            return .success
        case 300..<400:
            return .redirection
        case 400..<500:
            return .clientError
        case 500..<600:
            return .serverError
        default:
            return .unknown
        }
    }
}
