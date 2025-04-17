//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 21/03/25.
//

import Foundation

public enum LoadFeedResult {
    
    case success([FeedItem])
    case failure(Error)
}


// protocol feedloader
public protocol FeedLoader {
    func loadFeed(completion:@escaping(LoadFeedResult)->Void)
}
