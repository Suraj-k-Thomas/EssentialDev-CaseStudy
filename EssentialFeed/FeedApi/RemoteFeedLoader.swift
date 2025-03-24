//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Foundation

public protocol HTTPClient {
    
    func get (fromUrl url: URL)
    
}

public final class RemoteFeedLoader {
    
    private let client : HTTPClient?
    private let url : URL
    
    public  init (client : HTTPClient, url : URL){
        
        self.client = client
        self.url = url
    }
    
    public  func load (){
        
        client!.get(fromUrl :url)
        
    }
}
