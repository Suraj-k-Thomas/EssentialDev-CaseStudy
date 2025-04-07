//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 21/03/25.
//

import Foundation

public struct  FeedItem : Equatable {
    public  let id: UUID
    public  let description: String?
    public  let imageURL: URL
    public  let location: String?
    
    public init(id :UUID ,description : String?,location:String? ,imageURL:URL){
        
        self.id = id
        self.description = description
        self.imageURL = imageURL
        self.location = location
    }
}

extension FeedItem : Decodable {
    
    private enum CodingKeys : String , CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
