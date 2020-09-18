//
//  NetworkWorker.swift

import Combine
import Foundation
import os
import UIKit

/// Description: Type defining for Webservice reponse handler
typealias JSONDictionary = [String:Any]
typealias JSONArray = [[String:Any]]
typealias Parameters = [String: Any]

/// Description: Type defining for Webservice reponse handler
typealias ServiceHandler<Entity, Parameter> = (Swift.Result<Entity?, Error>, Parameter?) -> Void

struct AppURL {
    static var baseURL = "https://jsonplaceholder.typicode.com/"
    static let getPhotos = "albums/%d/photos"
    static let getAlbums = "users/%d/albums"
}

// MARK: - ServiceError Type
enum ServiceError: Error {
    case noInternet
    case invalidURL
    case invalidResponse
    case apiError(String)
    case timeout
    
    func description() -> (Int, String) {
        switch self {
        case .noInternet:
            return (code:0, message:"Please check your internet connection and try again!")
        case .invalidURL:
            return (code:1, message:"Bad URL")
        case .invalidResponse:
            return (code:2, message:"Invalid response")
        case .timeout:
            return (code:6, message:"Oops! We encountered a internal error. Please check again in a while.")
        case .apiError(let message):
            return (code:5, message:message)
        }
    }
}

//MARK: - HTTPMethod
enum HTTPMethod: String {
    case get
    case post
}

struct ServiceResponse<T:Decodable> {
    var value: T?
    var requestDetail: WebServiceDetail?
    var urlResponse: URLResponse?
}

// MARK: - ServiceParamters
/// Description: Provides details regarding the webserivce
struct WebServiceDetail {
    var urlEndPoint: String            //Pass from AppURL
    var method: HTTPMethod = .get       //Http method for the request
    var body: Parameters?      //Query/Http Request Parameters to be pass in request object
    var urlString: String {
        return AppURL.baseURL + urlEndPoint
    }
    
    init(urlEndPoint: String, method: HTTPMethod = .get, parameters: Parameters? = nil) {
        self.urlEndPoint = urlEndPoint
        self.body = parameters
        self.method = method
    }
}

/// Description: Class handles Webservice calling for the applicaton
class NetworkWorker: NSObject {
    private override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60 //seconds
    }
    static let shared = NetworkWorker()

    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
        return decoder
    }

    private var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            encoder.dateEncodingStrategy = .iso8601
            encoder.keyEncodingStrategy = .convertToSnakeCase
        }
        return encoder
    }
    
    
    public func callAPI<Model:Decodable>(for requestDetail: WebServiceDetail) -> AnyPublisher<ServiceResponse<Model>, Error> {
        //check for valid URL
        guard let url = URL(string: requestDetail.urlString)  else {
            return Fail(error: ServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        //create request
        var request = URLRequest(url: url)
        request.httpMethod = requestDetail.method.rawValue
        if let body = requestDetail.body?.jsonData {
            request.httpBody = body
        }
        Logger.log(level: .debug, type: .webService, message:"[NetworkRequest:] - Request -\n \(request)")
        //return Publisher
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> ServiceResponse<Model> in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw ServiceError.invalidResponse
                }
                Logger.log(level: .debug, type: .webService, message:"[NetworkRequest:] - Response -\n \(httpResponse)")
                guard httpResponse.statusCode == 200 else {
                    let errorMsg = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    throw ServiceError.apiError(errorMsg)
                }
                let decoder = NetworkWorker.shared.jsonDecoder
                let value = try decoder.decode(Model.self, from: result.data)
                return ServiceResponse(value: value, requestDetail:requestDetail, urlResponse: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension NetworkWorker {
    func cancelAllRequests() {
        URLSession.shared.getAllTasks { (tasks) in
            tasks.forEach { $0.cancel() }
        }
    }
}
