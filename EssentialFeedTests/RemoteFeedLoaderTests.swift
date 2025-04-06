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
        
        let (_,Client) = makeSUTAndClient()
        XCTAssertTrue(Client.requestedUrls.isEmpty)
        
    }
    
    func test_Load_RequestDataFromURL () {
        
        let url = URL(string: "https://TestUrl.com")!
        let (SUT,Client) = makeSUTAndClient()
        
        SUT.load{_ in}
        XCTAssertEqual(Client.requestedUrls, [url])
        
    }
    
    func test_LoadTwice_RequestedDataFromURLTwice () {
        
        let url = URL(string: "https://TestUrl.com")!
        let (SUT,Client) = makeSUTAndClient()
        
        SUT.load{_ in}
        SUT.load{_ in}
        XCTAssertEqual(Client.requestedUrls, [url, url])
    }
    
    func test_Load_deliversErrorOnClientError () {
        
        let (SUT,Client) = makeSUTAndClient()
        expect(SUT, toCompleteWith: .Connectivity) {
            let  ClientError = NSError(domain: "TestError", code: 0)
            Client.complete(with: ClientError)
        }
        
    }
    
    func test_Load_deliversErrorOnNon200HTTPResponse() {
        let (SUT,Client) = makeSUTAndClient()
        let samples = [199,299,399,400,500]
        samples.enumerated().forEach { index, value in
            
            expect(SUT, toCompleteWith: .invalidData) {
                Client.complete(withStatusCode: value, at: index)
            }
        }
    }
    
    
    func test_Load_deliversErrorOnNon200HTTPResponseWithInvalidJSON (){
        
        let (SUT,Client) = makeSUTAndClient()
        expect(SUT, toCompleteWith: .invalidData, when: {
            
            let invalidJson = Data("Invalid JSON".utf8)
            
            Client.complete(withStatusCode: 200,data: invalidJson)
            
        })
    }
}

//Helpers

private func expect (_ SUT : RemoteFeedLoader , toCompleteWith error : RemoteFeedLoader.Error ,when  action: ()-> Void, file: StaticString = #filePath, line: UInt = #line){
    
    var captureResults = [RemoteFeedLoader.Result]()
    SUT.load{
        captureResults.append($0!)
    }
    action()
    XCTAssertEqual(captureResults, [.failure(error)],file: file, line: line)
    
    
}

func makeSUTAndClient (url:URL = URL(string:"https://TestUrl.com" )!) -> ( RemoteFeedLoader,  HTTPClientSpy){
    
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
    
    func complete(withStatusCode code: Int ,data :Data = Data(), at index:Int = 0){
        
        let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data,response))
    }
}
 
