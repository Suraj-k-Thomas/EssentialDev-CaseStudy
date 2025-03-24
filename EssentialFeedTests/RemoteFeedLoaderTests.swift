//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Testing
import XCTest
@testable import EssentialFeed

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
func makeSUTAndCient (url:URL) -> ( RemoteFeedLoader,  HTTPClientSpy){
    
    let client = HTTPClientSpy ()
    let SUT = RemoteFeedLoader(client: client, url: url)
    return (SUT,client)
    
}

class HTTPClientSpy : HTTPClient {
    
    var requestedUrl: URL?
    func get (fromUrl url: URL) {
        requestedUrl = url
    }
}
