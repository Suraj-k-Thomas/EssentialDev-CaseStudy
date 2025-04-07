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
        expect(SUT, toCompleteWith:.failure(.Connectivity)) {
            let  ClientError = NSError(domain: "TestError", code: 0)
            Client.complete(with: ClientError)
        }
        
    }
    
    func test_Load_deliversErrorOnNon200HTTPResponse() {
        let (SUT,Client) = makeSUTAndClient()
        let samples = [199,299,399,400,500]
        samples.enumerated().forEach { index, value in
            
            expect(SUT, toCompleteWith: .failure(.invalidData)) {
                Client.complete(withStatusCode: value, at: index)
            }}
    }
    
    
    func test_Load_deliversErrorOnNon200HTTPResponseWithInvalidJSON (){
        
        let (SUT,Client) = makeSUTAndClient()
        expect(SUT, toCompleteWith: .failure(.invalidData), when: {
            
            let invalidJson = Data("Invalid JSON".utf8)
            
            Client.complete(withStatusCode: 200,data: invalidJson)
            
        })
    }
    
    func test_Load_deliversSuccessOn200HTTPResponseWithEmptyJSONList (){
        
        let (SUT,Client) = makeSUTAndClient()
        
        expect(SUT, toCompleteWith: .success([])) {
            let emptyJsonList = Data("{\"items\":[]}".utf8)
            Client.complete(withStatusCode: 200, data: emptyJsonList)
        }
    }
    
    
    
    func test_Load_deliversItemsOn200HTTPResponseWithValidJSONList(){
        
        let (SUT,Client) = makeSUTAndClient()
        let item1 =  FeedItem(id: UUID(),
                              description: nil,
                              location: nil,
                              imageURL: URL(string: "https://a-Url.com")!)
      let   item1Json = [
        "id" : item1.id.uuidString,
        "image" : item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "https://anotherurl.com")!)
        
        let   item2Json = [
            "id":item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJson = [
            "items": [item1Json,item2Json]
        ]
        
        expect(SUT, toCompleteWith: .success([item1,item2])) {
            let json = try!
            JSONSerialization.data(withJSONObject: itemsJson)
            Client.complete(withStatusCode: 200 , data: json)
            }
        
    }
    
}

//Helpers

private func expect (_ SUT : RemoteFeedLoader , toCompleteWith result : RemoteFeedLoader.Result ,
    when  action: ()-> Void,
    file: StaticString = #filePath,
    line: UInt = #line){
    
    var captureResults = [RemoteFeedLoader.Result]()
    SUT.load{
        captureResults.append($0!)
    }
    action()
    XCTAssertEqual(captureResults, [result],file: file, line: line)
    
    
}

func makeSUTAndClient (url:URL = URL(string:"https://TestUrl.com" )!) ->
  (RemoteFeedLoader,  HTTPClientSpy){
    
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
 
