//
//  FeedItem.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro Maldonado on 28/10/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id:UUID
    let description:String?
    let location:String?
    let imageURL:URL
}
