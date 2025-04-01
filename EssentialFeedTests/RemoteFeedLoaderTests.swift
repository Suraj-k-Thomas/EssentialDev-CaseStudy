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
    
    func test_init_DoesNotReqruireDataFromURL () {
        
        let (_,Client) = makeSUTAndCient()
        XCTAssertTrue(Client.requestedUrls.isEmpty)
        
    }
    
    func test_Load_RequestDataFromURL () {
        
        let url = URL(string: "https://TestUrl.com")!
        let (SUT,Client) = makeSUTAndCient()
        
        SUT.load()
        XCTAssertEqual(Client.requestedUrls, [url])
        
    }
    
    func test_LoadTwice_RequestedDataFromURLTwice () {
        
        let url = URL(string: "https://TestUrl.com")!
        let (SUT,Client) = makeSUTAndCient()
        
        SUT.load()
        SUT.load()
        XCTAssertEqual(Client.requestedUrls, [url, url])
    }
    
    func test_Load_deliversErrorOnClientError () {
        
        let (SUT,Client) = makeSUTAndCient()
        var capturedErrors = [RemoteFeedLoader.Error]()
        SUT.load{
            capturedErrors.append($0!)
        }
        let  ClientError = NSError(domain: "TestError", code: 0, userInfo: nil)
        Client.completions[0](ClientError)
        
        XCTAssertEqual(capturedErrors,[.Connectivity])
    }
}

//Helpers
func makeSUTAndCient (url:URL = URL(string:"https://TestUrl.com" )!) -> ( RemoteFeedLoader,  HTTPClientSpy){
    
    let client = HTTPClientSpy ()
    let SUT = RemoteFeedLoader(client: client, url: url)
    return (SUT,client)
    
}

class HTTPClientSpy : HTTPClient {
    
    var error:Error?
    var requestedUrl: URL?
    var requestedUrls: [URL] = []
    var completions = [(Error?) -> Void]()
    func get (fromUrl url: URL, completion : @escaping (Error?) -> Void) {
        
        if let error = error {
            completion(error)
        }
        completions.append(completion)
        requestedUrls.append(url)
    }
}
