//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Suraj  Thomas on 24/03/25.
//

import Testing
import XCTest
@testable import EssentialFeed
// test

class RemoteFeedLoaderTests : XCTestCase {
    
    func test_init_DoesNotReqruireDataFromURL () {
        
        let (_,Client) = makeSUTAndCient()
        XCTAssertTrue(Client.requestedUrls.isEmpty)
        
    }
    
    func test_Load_RequestDataFromURL () {
        
        let url = URL(string: "https://TestUrl.com")!
        let (SUT,Client) = makeSUTAndCient()
        
        SUT.load{_ in}
        XCTAssertEqual(Client.requestedUrls, [url])
        
    }
    
    func test_LoadTwice_RequestedDataFromURLTwice () {
        
        let url = URL(string: "https://TestUrl.com")!
        let (SUT,Client) = makeSUTAndCient()
        
        SUT.load{_ in}
        SUT.load{_ in}
        XCTAssertEqual(Client.requestedUrls, [url, url])
    }
    
    func test_Load_deliversErrorOnClientError () {
        
        let (SUT,Client) = makeSUTAndCient()
        var capturedErrors = [RemoteFeedLoader.Error]()
        SUT.load{
            capturedErrors.append($0!)
        }
        let  ClientError = NSError(domain: "TestError", code: 0, userInfo: nil)
        Client.complete(with: ClientError)
        XCTAssertEqual(capturedErrors,[.Connectivity])
    }
    
    func test_Load_deliversErrorOnNon200HTTPResponse() {
        let (SUT,Client) = makeSUTAndCient()
        let samples = [199,299,399,400,500]
        samples.enumerated().forEach { index, value in
            var capturedErrors = [RemoteFeedLoader.Error]()
            SUT.load{
                capturedErrors.append($0!)
            }
           // Client.complete(withStatusCode: value,index:index)
            Client.complete(withStatusCode: value, at: index)
            
            XCTAssertEqual(capturedErrors,[.invalidData])
            
        }
       
    }
    
}

//Helpers
func makeSUTAndCient (url:URL = URL(string:"https://TestUrl.com" )!) -> ( RemoteFeedLoader,  HTTPClientSpy){
    
    let client = HTTPClientSpy ()
    let SUT = RemoteFeedLoader(client: client, url: url)
    return (SUT,client)
    
}

class HTTPClientSpy : HTTPClient {
    
    var requestedUrls: [URL] {
        
        messages.map{$0.url}
    }
    private var messages  = [(url: URL, completion: (HTTPClientResult?) -> Void) ]()
    
    func get (fromUrl url: URL, completion: @escaping (HTTPClientResult?) -> Void) {
        
        messages.append((url,completion))
    }
    
    func complete(with error : Error, at index:Int = 0){
        
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int , at index:Int){
        
        let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)
        messages[index].completion(.success(response!))
    }
}
