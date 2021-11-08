//
//  HTTPClientResult.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro Maldonado on 08/11/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url:URL, completion: @escaping (HTTPClientResult) -> Void)
}
