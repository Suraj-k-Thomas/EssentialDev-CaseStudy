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
                let jsondata = makeItemsJSON([])
                Client.complete(withStatusCode: value, data: jsondata, at: index)
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
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUTAndClient()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        
        let client = HTTPClientSpy()
        let url:URL = URL(string:"https://AnyUrl.com" )!
        var SUT:RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        SUT?.load{
            capturedResults.append($0!)
        }
        SUT = nil
        
        client.complete(withStatusCode: 200, data:makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
        
    }
    
    
    //Helpers

    func makeSUTAndClient (url:URL = URL(string:"https://TestUrl.com" )!, file: StaticString = #filePath,
                           line: UInt = #line) ->
    (RemoteFeedLoader,  HTTPClientSpy){
        
        let client = HTTPClientSpy ()
        let SUT = RemoteFeedLoader(client: client, url: url)
        trackMemoryLeaks(client,file: file, line: line)
        trackMemoryLeaks(SUT,file: file, line: line)
        return (SUT,client)
        
    }
    
    private func trackMemoryLeaks(
        _ anyinstance :AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line){
            
            addTeardownBlock {
                [weak anyinstance] in
                XCTAssertNil(anyinstance , "Instance should have  been deallocated.Potential memory leak",file: file,line: line)
            }
            
            
        }
        
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
    
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
        
        return (item, json)
    }
    
    private func makeItemsJSON (_ items :[[String:Any]])->Data{
        
        let json = ["items":items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
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
    
    func complete(withStatusCode code: Int ,data :Data, at index:Int = 0){
        
        let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data,response))
    }
}
 
