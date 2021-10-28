//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hiram Castro Maldonado on 28/10/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
