//
//  RemoteFeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro Maldonado on 29/10/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url:URL, completion: @escaping (HTTPClientResult) -> Void)
}

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
                
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items.map { $0.item } ))
                } else {
                    completion(.failure(.invalidData))
                }
                
                break
            case .failure:
                completion(.failure(.connectivity))
                break
            }
        }
    }
}

private struct Root: Decodable {
    let items: [Item]
}

private struct Item: Decodable {
    
    let id:UUID
    let description:String?
    let location:String?
    let image:URL
    
    var item: FeedItem {
        return FeedItem(id: id,
                        description: description,
                        location: location,
                        imageURL: image)
    }
}
