//
//  NetworkManager.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 10.08.2025.
//

import Foundation
import RxSwift

// MARK: - AccessToken Model
struct AccessTokenResponse: Decodable {
    let accessToken: String
    let expiresIn: Int
}

// MARK: - Errors
enum NetworkError: LocalizedError {
    case configurationFailed(Error)
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .configurationFailed(let error):
            return "NetworkManager configuration failed: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

// MARK: - API constants
enum API: String {
    case tokenEndpoint = "https://id.twitch.tv/oauth2/token"
    case baseEndpoint = "https://api.igdb.com/v4"
    case imageBasePoint = "https://images.igdb.com/igdb/image/upload/t_"
    
    case gamesEndpoint = "/games"
    case companiesEndpoint = "/companies"
    case gameEnginesEndpoint = "/game_engines"
}

enum APIImageSize: String {
    case coverSmall = "cover_small_2x"
    case screenshotMedium = "screenshot_med_2x"
    case coverBig = "cover_big_2x"
    case logoMedium = "logo_med_2x"
    case screenshotBig = "screenshot_big_2x"
    case screenshotHuge = "screenshot_huge_2x"
    case thumb = "thumb_2x"
    case micro = "micro_2x"
    case hd = "720p"
    case fullHd = "1080p"
}

// MARK: - NetworkManager
final class NetworkManager {
    static let shared = NetworkManager()
    
    // MARK: - Properties
    
    private let clientId: String
    private let clientSecret: String
    private let dataManager = DataManager.shared
    private let loadLimit = 10
    
    private var urlSession: URLSession?
    private let configurationSubject = PublishSubject<URLSession>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Configuration
    
    private init() {
        clientId = PropertyListHelpers.shared.getValue(
            String.self,
            with: "Client ID",
            from: "Secrets"
        )
        clientSecret = PropertyListHelpers.shared.getValue(
            String.self,
            with: "Client Secret",
            from: "Secrets"
        )
    }
    
    func configure() -> Completable {
        guard urlSession == nil else { return .empty() }
        
        return fetchAccessToken()
            .map { [weak self] accessToken in
                self?.createConfiguredURLSession(with: accessToken)
            }
            .compactMap { $0 }
            .do { [weak self] session in
                self?.urlSession = session
                self?.configurationSubject.onNext(session)
            }
            .ignoreElements()
            .asCompletable()
            .catch { [weak self] error in
                self?.configurationSubject.onError(NetworkError.configurationFailed(error))
                return .error(NetworkError.configurationFailed(error))
            }
    }
    
    // MARK: - Type fetching functions
    
    func fetchGames(at page: Int, with searchQuery: String? = "where rating_count > 5") -> Observable<[Game]> {
        fetch(
            type: [Game].self,
            endpoint: API.gamesEndpoint,
            fields: GameQuery.fields,
            page: page,
            searchQuery: searchQuery
        )
    }
    
    func fetchCompanies(at page: Int, with searchQuery: String? = "where logo != null") -> Observable<[Company]> {
        fetch(
            type: [Company].self,
            endpoint: API.companiesEndpoint,
            fields: CompanyQuery.fields,
            page: page,
            searchQuery: searchQuery
        )
    }
    
    func fetchGameEngines(at page: Int, with searchQuery: String? = "where logo != null") -> Observable<[GameEngine]> {
        fetch(
            type: [GameEngine].self,
            endpoint: API.gameEnginesEndpoint,
            fields: GameEngineQuery.fields,
            page: page,
            searchQuery: searchQuery
        )
    }
    
    func fetchImageFromIGDB(by id: String, of size: APIImageSize) -> Observable<Data> {
        guard let url = URL(string: "\(API.imageBasePoint.rawValue)\(size.rawValue)/\(id).jpg") else {
            return .error(NetworkError.invalidURL)
        }
        
        return fetchImage(from: url)
    }
    
    func fetchImage(from url: URL) -> Observable<Data> {
        Observable.create { [weak self] observer in
            let request = URLRequest(url: url)
            let task = self?.urlSession?.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode,
                      let data = data else {
                    observer.onError(URLError(.badServerResponse))
                    return
                }
                if let error {
                    observer.onError(error)
                    return
                }
                
                observer.onNext(data)
                observer.onCompleted()
            }
            
            task?.resume()
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}

// MARK: - Private fetching methods
private extension NetworkManager {
    func fetch<T: Decodable>(
        type: T.Type,
        endpoint: API,
        fields: [String],
        page: Int?,
        searchQuery: String? = nil
    ) -> Observable<T> {
        let query = QueryBuilder.build(
            searchQuery: searchQuery,
            fields: fields,
            limit: (page != nil) ? loadLimit : nil,
            offset: (page != nil) ? loadLimit * (page! - 1) : nil
        )
        
        guard let url = URL(string: "\(API.baseEndpoint.rawValue)\(endpoint.rawValue)") else {
            return .error(NetworkError.invalidURL)
        }
        
        return configuredURLSession()
            .flatMapLatest { session in
                self.performRequest(type, to: url, with: query, using: session)
            }
    }
    
    func configuredURLSession() -> Observable<URLSession> {
        if let urlSession {
            return .just(urlSession)
        }
        
        return configurationSubject
            .take(1)
            .timeout(.seconds(30), scheduler: MainScheduler.instance)
    }
    
    func performRequest<T: Decodable>(
        _ type: T.Type,
        to url: URL,
        with query: String,
        using urlSession: URLSession
    ) -> Observable<T> {
        return Observable.create { observer in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = query.data(using: .utf8)
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            
            let task = urlSession.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode,
                      let data = data else {
                    observer.onError(URLError(.badServerResponse))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

// MARK: - AccessToken configuring functions
private extension NetworkManager {
    func createConfiguredURLSession(with accessToken: String) -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Client-ID": clientId,
            "Authorization": "Bearer \(accessToken)"
        ]
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }
    
    func fetchAccessToken() -> Observable<String> {
        if let cachedToken = dataManager.loadAccessToken() {
            return .just(cachedToken)
        }
        
        return requestAccessToken()
            .do { [weak self] response in
                self?.dataManager.saveAccessToken(response.accessToken, expiresIn: response.expiresIn)
            }
            .map { $0.accessToken }
    }
    
    func requestAccessToken() -> Observable<AccessTokenResponse> {
        guard let url = URL(string: API.tokenEndpoint.rawValue) else {
            return .error(NetworkError.invalidURL)
        }
        
        return Observable.create { [weak self] observer in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let bodyParameters = [
                "client_id": self?.clientId,
                "client_secret": self?.clientSecret,
                "grant_type": "client_credentials"
            ]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters)
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error {
                    observer.onError(error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode,
                      let data else {
                    observer.onError(NetworkError.invalidResponse)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(AccessTokenResponse.self, from: data)
                    observer.onNext(response)
                    observer.onCompleted()
                } catch {
                    observer.onError(NetworkError.decodingError(error))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
