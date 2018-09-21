//
//  TODOAPIClientTests.swift
//  KataTODOAPIClient
//
//  Created by Pedro Vicente Gomez on 12/02/16.
//  Copyright © 2016 Karumi. All rights reserved.
//

import Foundation
import Nocilla
import Nimble
import XCTest
import Result
@testable import KataTODOAPIClient

class TODOAPIClientTests: NocillaTestCase {

    fileprivate let apiClient = TODOAPIClient()
    fileprivate let anyTask = TaskDTO(userId: "1", id: "2", title: "Finish this kata", completed: true)

    func testSendsContentTypeHeader() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .withHeaders(["Content-Type": "application/json", "Accept": "application/json"])?
            .andReturn(200)

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result).toEventuallyNot(beNil())
    }

    func testParsesTasksProperlyGettingAllTheTasks() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(200)?
            .withJsonBody(fromJsonFile("getTasksResponse"))

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.value?.count).toEventually(equal(200))
        assertTaskContainsExpectedValues(task: (result?.value?[0])!)
    }
    


    func testReturnsNetworkErrorIfThereIsNoConnectionGettingAllTasks() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andFailWithError(NSError.networkError())

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.networkError))
    }

    private func assertTaskContainsExpectedValues(task: TaskDTO) {
        expect(task.id).to(equal("1"))
        expect(task.userId).to(equal("1"))
        expect(task.title).to(equal("delectus aut autem"))
        expect(task.completed).to(beFalse())
    }
    
    
    func test_return_unknown_error_500_getting_all_tasks(){
        
        _  = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
        .andReturn(500)
        
        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { (response) in
            result = response
        }
        
        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 500)))
        
        
    }
    
    
    func test_return_error_getting_all_task_if_malformed_json(){
        
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(200)?
            .withJsonBody(fromJsonFile("malformed"))
        
        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { (response) in
            result = response
        }
        
        expect(result?.error).toEventually(equal(TODOAPIClientError.networkError))
        
    }
    
    
    func test_success_getting_task_with_id(){
        
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
        .andReturn(200)?
        .withJsonBody(fromJsonFile("getTaskByIdResponse"))
        
        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1"){ (response) in
            result = response
        }
        
        expect(result?.value?.id).toEventually(equal("1"))
        
    }
    
    func test_getting_task_with_not_existing_id(){
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/2")
            .andReturn(404)
        
        
        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("2"){ (response) in
            result = response
        }
        
        expect(result?.error).toEventually(equal(TODOAPIClientError.itemNotFound))
        
        
    }
    
    func test_getting_task_and_server_returning_invalid_json(){
        
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/2")
            .andReturn(200)?
            .withJsonBody(fromJsonFile("malformed"))
        
        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("2"){ (response) in
            result = response
        }
        
        expect(result?.error).toEventually(equal(TODOAPIClientError.networkError))
        
    }
    
    func test_return_unknown_error_500_getting_task_with_id(){
        
        _  = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/2")
            .andReturn(500)
        
        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("2"){ (response) in
            result = response
        }
        
        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 500)))
        
        
    }
    
    func test_success_adding_task(){
        
        _ = stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
        .andReturn(201)?
        .withBody(fromJsonFile("addTaskToUserRequest"))
        
        //{"completed":false,"userId":"1","title":"Finish this kata"}
        var result : Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "Finish this kata", completed: false) { (response) in
            result = response
        }
        
        expect(result?.value?.userId).toEventually(equal("1"))
        expect(result?.value?.title).toEventually(equal("Finish this kata"))
        expect(result?.value?.completed).toEventually(equal(false))
        
        
    }
    
    
    func test_return_unknown_error_500_adding_task(){
        _ = stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(500)
        
        var result : Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "Finish this kata", completed: false) { (response) in
            result = response
        }
        
        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 500)))
        
    }
    
    func test_adding_task_and_server_returning_invalid_json(){
        
        _ = stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(201)?
            .withJsonBody(fromJsonFile("malformed"))
        
        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "Finish this kata", completed: false) { (response) in
            result = response
        }
        
        expect(result?.error).toEventually(equal(TODOAPIClientError.networkError))
        
    }
    
    
    func test_success_delete_task(){
        
        _ = stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/2")
        .andReturn(200)
        
        var result : Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("2") { (response) in
            result = response
        }
        
      expect(result?.value).toEventuallyNot(beNil())
        
        
    }
    
    
    func test_success_update_task(){
        
        _ = stubRequest("PUT", "http://jsonplaceholder.typicode.com/todos/2")
        .andReturn(200)?
        .withJsonBody(fromJsonFile("updateTaskResponse"))
        
        let taskToBeUpdated = TaskDTO(userId: "1", id: "2", title: "Finish this kata", completed: false)
        
        
        var result : Result<TaskDTO, TODOAPIClientError>?
        apiClient.updateTask(taskToBeUpdated) { (response) in
            result = response
        }
        
        expect(result?.value?.userId).toEventually(equal("1"))
        
    }
    
    
    
    
    
}
