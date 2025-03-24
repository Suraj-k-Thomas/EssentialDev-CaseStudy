//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Testing
import XCTest

class RemoteFeedLoader {
    
    let client : HTTPClient?
    let url : URL
   
    init (client : HTTPClient, url : URL){
       
        self.client = client
        self.url = url
    }
   
    func load (){
        
        client!.get(fromUrl :url)
        
    }
}

protocol HTTPClient {
    
    func get (fromUrl url: URL)
    
}



class RemoteFeedLoaderTests : XCTestCase {
    
    func test_init_DoesNotREqruireDataFromURL () {
       
        let url = URL(string: "https://TestUrl.com")!
        let (_,Client) = makeSUTAndCient(url: url)
        XCTAssertNil(Client.requestedUrl)
        
    }
    
    func test_LoadRequestDataFromURL () {
        
        let url = URL(string: "https://TestUrl.com")!
        let (SUT,Client) = makeSUTAndCient(url: url)
        
        SUT.load()
        XCTAssertEqual(url,Client.requestedUrl)
        
    }
}

//Helpers
func makeSUTAndCient (url:URL) -> (SUT : RemoteFeedLoader, client : HTTPClientSpy){
    
    let client = HTTPClientSpy ()
    let SUT = RemoteFeedLoader(client: client, url: url)
    return (SUT:SUT,client:client)
    
}

class HTTPClientSpy : HTTPClient {
    
    var requestedUrl: URL?
    func get (fromUrl url: URL) {
        requestedUrl = url
    }
}
