//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedModuleTests
//
//  Created by Hiram Castro Maldonado on 29/10/21.
//

import XCTest
import EssentialFeedModule

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURls.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURls, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURls, [url, url])
    }
    
    func test_load_deliverysErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError)
        }
        
        /*
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load {
            // 4 - after execute the completion handler in load method from RemoteFeedLoader
            // we return the result to be saved and then validated
            capturedError.append($0)
        }
        
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
        */
    }
    
    func test_load_deliverysErrorOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        /*
        samples.enumerated().forEach {
            index, code in
            
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load {
                // 4.1 - after execute the completion handler in load method from RemoteFeedLoader
                // we return the result to be saved and then validated
                capturedErrors.append($0)
            }
            
            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
        */
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJSON = Data.init("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = Data(bytes: "{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
        
        /*
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        let emptyListJSON = Data(bytes: "{\"items\":[]}".utf8)
        client.complete(withStatusCode: 200, data: emptyListJSON)
        
        XCTAssertEqual(capturedResults, [.success([])])
        */
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "http://a-url.com")!)
        
        let item2 = FeedItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "http://another-url.com")!)
        
        let item1JSON = [
            "id":item1.id.uuidString,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2JSON = [
            "id":item2.id.uuidString,
            "description":item2.description,
            "location":item2.location,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJSON = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWithResult: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-different-url.com")!) -> (sut:RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithResult result: RemoteFeedLoader.Result,
                        whenActionOccurs action: () -> Void,
                        file: StaticString = #file, line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file:file, line:line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void )]()
        
        var requestedURls:[URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            // 2 - capturing the completion habdler.
            // won't execute because it's captured in a array of closures to excute it later
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            // 3 - executing previous captured completion handler
            // and return it to the main caller (RemoteFeedLoader - load)
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            // 3 - executing previous captured completion handler
            // and return it to the main caller (RemoteFeedLoader - load)
            let response = HTTPURLResponse(url: requestedURls[index],
                                           statusCode: 400,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }

}
