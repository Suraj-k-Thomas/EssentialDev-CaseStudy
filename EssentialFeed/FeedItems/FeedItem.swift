//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 21/03/25.
//

import Foundation

public struct  FeedItem : Equatable {
    let id: String
    let description: String?
    let imageURL: URL
    let location: String?
}
