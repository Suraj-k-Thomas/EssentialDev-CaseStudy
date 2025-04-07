//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Foundation

public enum HTTPClientResult {
    
    case success (Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    func get (fromUrl url: URL, completion: @escaping (HTTPClientResult?) -> Void)
    
}

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
                
            if response.statusCode == 200
                    , let root = try? JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.items))
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

private struct Root : Decodable {
    
    let items : [FeedItem]
}
