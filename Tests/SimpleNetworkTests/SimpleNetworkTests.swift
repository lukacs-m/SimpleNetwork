import XCTest
import Combine
@testable import SimpleNetwork

enum TestEndpoint {
    case getPosts
    case createPost
    case updatePost
    case patchPost
    case deletePost
}

extension TestEndpoint: Endpoint {
    var baseUrl: String? {
        "https://jsonplaceholder.typicode.com"
    }
    
    var path: String {
        switch self {
        case .getPosts, .createPost:
            return "/posts"
        case .updatePost, .patchPost, .deletePost:
            return "/posts/1"
        }
    }
    
    var method: CRUDRequestMethod {
        switch self {
        case .getPosts:
            return .get
        case .createPost:
            return .post
        case .updatePost:
            return .put
        case .patchPost:
            return .patch
        case .deletePost:
            return .delete
        }
    }
    
    var header: [String: String]? {
        switch self {
        default:
            return [
                "Content-type": "application/json; charset=UTF-8"
            ]
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .createPost:
            return [
                "title": "Title test",
                "body": "this is the body test",
                "userId": 42,
            ]
        case .updatePost:
            return [
                "id": "1",
                "title": "Title is test updated",
                "body": "this is the body test updated",
                "userId": 45,
            ]
        case .patchPost:
            return [
                "title": "Title test new",
            ]
        default:
            return nil
        }
    }
}

// MARK: - Post
struct Post: Codable {
    let id: Int
    let title, body: String
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case userID = "userId"
    }
}

typealias Posts = [Post]


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
        let _: Void = try await sut.requestNonDecadable(endpoint: TestEndpoint.deletePost)
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

        cancellable = sut.requestNonDecadable(endpoint: TestEndpoint.deletePost)
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
    
    func testDeletePostFailurePublisher() {
        let expectation = XCTestExpectation(description: "wait for completion")

        cancellable = sut.requestNonDecadable(endpoint: TestEndpoint.deletePost)
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
