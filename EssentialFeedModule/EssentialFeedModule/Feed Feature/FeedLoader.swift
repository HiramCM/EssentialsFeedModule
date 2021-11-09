//
//  FeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro Maldonado on 28/10/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
