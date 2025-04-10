//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 21/03/25.
//

import Foundation

enum LoadFeedResult {
    
    case success([FeedItem])
    case failure(Error)
}
// protocol feedloader
protocol FeedLoader {
    
    func loadFeed(completion:@escaping([LoadFeedResult])->Void)
}
