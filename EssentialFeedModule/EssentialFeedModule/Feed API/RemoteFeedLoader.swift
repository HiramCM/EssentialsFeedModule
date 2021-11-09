//
//  RemoteFeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro Maldonado on 29/10/21.
//

import Foundation

public final class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        // 1 - calling the client get method simulating a httpRequest
        // waiting for the client completion handler to validate result response
        client.get(from: url) { result in
            // 4 - after execute the captured complition handler in HTTPClientSpy
            // the completion handler return to main caller (load) and get the result
            // failure or success and then executes main completion handler
            switch result {
            case let .success(data, response):
                completion(self.map(data, from: response))
                break
            case .failure:
                completion(.failure(.connectivity))
                break
            }
        }
    }
    
    private func map(_ data:Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items)
        } catch {
            return .failure(.invalidData)
        }
    }
    
}
