//
//  RemoteFeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro Maldonado on 29/10/21.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        // 1 - calling the client get method simulating a httpRequest
        // waiting for the client completion handler to validate result response
        client.get(from: url) { [weak self] result in
            // 4 - after execute the captured complition handler in HTTPClientSpy
            // the completion handler return to main caller (load) and get the result
            // failure or success and then executes main completion handler
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
                break
            case .failure:
                completion(.failure(Error.connectivity))
                break
            }
        }
    }
    
}
