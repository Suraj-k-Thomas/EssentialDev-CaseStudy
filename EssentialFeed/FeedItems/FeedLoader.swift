//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 21/03/25.
//

import Foundation

public enum LoadFeedResult <Error: Swift.Error>{
    
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult:Equatable where Error:Equatable{}

// protocol feedloader
protocol FeedLoader {
    associatedtype Error: Swift.Error
    func loadFeed(completion:@escaping(LoadFeedResult<Error>)->Void)
}
