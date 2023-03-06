import XCTest
import Combine
import Foundation
@testable import SimpleNetwork

final class SimpleNetworkTests: XCTestCase {
    let sut = SimpleNetworkClient()
    var cancellable: AnyCancellable?

    override func tearDown() {
        super.tearDown()
        cancellable?.cancel()
    }
    
    // MARK: - Async tests
    func testGetPostsAsync() async throws {
        let posts: Posts = try await sut.request(endpoint: TestEndpoint.getPosts)
        XCTAssertEqual(posts.count, 100)
    }
    
    func testCreatePostAsync() async throws {
        let post: Post = try await sut.request(endpoint: TestEndpoint.createPost)
        XCTAssertEqual(post.title, "Title test")
        XCTAssertEqual(post.body, "this is the body test")
        XCTAssertEqual(post.userID, 42)
    }
    
    func testUpdatePostAsync() async throws {
        let post: Post = try await sut.request(endpoint: TestEndpoint.updatePost)
        XCTAssertEqual(post.title, "Title is test updated")
        XCTAssertEqual(post.body, "this is the body test updated")
        XCTAssertEqual(post.userID, 45)
    }

    func testPatchPostAsync() async throws {
        let post: Post = try await sut.request(endpoint: TestEndpoint.patchPost)
        XCTAssertEqual(post.title, "Title test new")
    }
    
    func testDeletePostAsync() async throws {
        let _: Void = try await sut.requestNonDecodable(endpoint: TestEndpoint.deletePost)
    }
    
    func test_multipartDataAsync_withImage_shouldBeValid() async throws {
        guard let url = Bundle.module.url(forResource: "tests", withExtension: "png"),
              let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
            XCTFail("Should not return a error")
            return
        }

        let mimetype = url.mimeType
        let parts = MultiPartFormData(data: data, name: "testFile", mimeType: mimetype, fileName: "tests.png")

        let image: MultipartTestResponse = try await sut.request(endpoint: ComplexeEndpoint.multipart(data: [parts]))
        XCTAssertNotNil(image)
        XCTAssertTrue(image.files.testFile.contains("png"))
    }
 
    // MARK: - Publishers
    
    func testGetPostsPublisher() {
        let expectation = XCTestExpectation(description: "wait for completion")

        cancellable = sut.request(endpoint: TestEndpoint.getPosts)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure:
                    XCTFail("Should not return a error")
                }
            } receiveValue: { (posts: Posts) in
                XCTAssertEqual(posts.count, 100)
                expectation.fulfill()
            }
        XCTWaiter().wait(for: [expectation], timeout: 5)
    }
    
    func testCreatePostPublisher() {
        let expectation = XCTestExpectation(description: "wait for completion")

        cancellable = sut.request(endpoint: TestEndpoint.createPost)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure:
                    XCTFail("Should not return a error")
                }
            } receiveValue: { (post: Post) in
                XCTAssertEqual(post.title, "Title test")
                XCTAssertEqual(post.body, "this is the body test")
                XCTAssertEqual(post.userID, 42)
                expectation.fulfill()
            }
        XCTWaiter().wait(for: [expectation], timeout: 5)
    }
    
    func testUpdatePostPublisher() {
        let expectation = XCTestExpectation(description: "wait for completion")

        cancellable = sut.request(endpoint: TestEndpoint.updatePost)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure:
                    XCTFail("Should not return a error")
                }
            } receiveValue: { (post: Post) in
                XCTAssertEqual(post.title, "Title is test updated")
                XCTAssertEqual(post.body, "this is the body test updated")
                XCTAssertEqual(post.userID, 45)
                expectation.fulfill()
            }
        XCTWaiter().wait(for: [expectation], timeout: 5)
    }

    func testPatchPostPublisher() {
        let expectation = XCTestExpectation(description: "wait for completion")

        cancellable = sut.request(endpoint: TestEndpoint.patchPost)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure:
                    XCTFail("Should not return a error")
                }
            } receiveValue: { (post: Post) in
                XCTAssertEqual(post.title, "Title test new")
                expectation.fulfill()
            }
        XCTWaiter().wait(for: [expectation], timeout: 5)
    }
    
    func testDeletePostPublisher()  {
        let expectation = XCTestExpectation(description: "wait for completion")

        cancellable = sut.requestNonDecodable(endpoint: TestEndpoint.deletePost)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure:
                    XCTFail("Should not return a error")
                }
            } receiveValue: { (result: Void) in
                expectation.fulfill()
            }
        XCTWaiter().wait(for: [expectation], timeout: 5)
    }
    
    func test_deletePostPublisher_withMismatchReturnTypes_shouldFail() {
        let expectation = XCTestExpectation(description: "wait for completion")

        cancellable = sut.requestNonDecodable(endpoint: TestEndpoint.deletePost)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    XCTAssertTrue(error is SimpleNetwork.RequestErrors)
                    XCTAssertEqual(error as! RequestErrors, SimpleNetwork.RequestErrors.mismatchErrorInReturnType)
                }
            } receiveValue: { (result: Bool) in
                XCTFail("Should return a missmatch error")
                expectation.fulfill()
            }
        XCTWaiter().wait(for: [expectation], timeout: 5)
    }
}
