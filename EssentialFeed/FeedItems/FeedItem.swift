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
    public  let location: String?
    public  let imageURL: URL

    public init(id :UUID ,description : String?,location:String? ,imageURL:URL){
        
        self.id = id
        self.description = description
        self.imageURL = imageURL
        self.location = location
    }
}

