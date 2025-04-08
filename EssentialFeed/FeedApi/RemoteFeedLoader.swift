//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Foundation



public final class RemoteFeedLoader {
    
    public enum Error : Swift.Error {
        
        case Connectivity
        case invalidData
    }
    
    public enum Result : Equatable {
        
        case success([FeedItem])
        case failure(Error)
    }
    

    private let client : HTTPClient?
    private let url : URL
    
    public  init (client : HTTPClient, url : URL){
        
        self.client = client
        self.url = url
    }
    
    public  func load (completion : @escaping (Result?) -> Void ){
        
        client!.get(fromUrl :url) { response in
            
            switch response {
            case let .success(data,response):
                
                if let items = try?
                    FeedItemsMapper.map(data,response)
                {
                    completion(.success(items))
                }else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.Connectivity))
            case .none:
                print("nil value")
            }
        }
    }
}



