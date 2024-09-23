//
//  EventQueue.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 19.09.2024.
//

import Foundation

public struct DeferedQueuedEvent {
    let event: AnalyticsEvent
    let dateAdded: Date
    let parameters: [String: AnalyticsBaseParameterValue]?
}

/// A generic node class for the linked list
class Node<T> {
    var value: T
    var next: Node<T>?
    
    init(value: T) {
        self.value = value
    }
}

/// A generic queue implemented using a linked list
class Queue<T> {
    private var head: Node<T>?
    private var tail: Node<T>?
    
    /// Check if the queue is empty
    public var isEmpty: Bool {
        return head == nil
    }
    
    /// Enqueue an element to the end of the queue
    /// - Parameter value: The value to enqueue
    public func enqueue(_ value: T) {
        let newNode = Node(value: value)
        if let tailNode = tail {
            tailNode.next = newNode
        } else {
            // If the queue is empty, new node is both head and tail
            head = newNode
        }
        tail = newNode
    }
    
    /// Dequeue an element from the front of the queue
    /// - Returns: The dequeued value, or nil if the queue is empty
    public func dequeue() -> T? {
        if let headNode = head {
            let value = headNode.value
            head = headNode.next
            // If the queue is now empty, reset the tail to nil
            if head == nil {
                tail = nil
            }
            return value
        } else {
            return nil // Queue is empty
        }
    }
    
    /// Peek at the front element of the queue without dequeuing it
    /// - Returns: The value at the front of the queue, or nil if the queue is empty
    public func peek() -> T? {
        return head?.value
    }
    
    /// Remove elements that satisfy the given predicate and perform an action before removal
    /// - Parameters:
    ///   - predicate: A closure that takes an element as its argument and returns a Boolean value indicating whether the element should be removed
    ///   - action: An optional closure that takes an element as its argument and performs an action on it before removal
    public func remove(where predicate: (T) -> Bool, action: ((T) -> Void)? = nil) {
        var currentNode = head
        var previousNode: Node<T>? = nil
        
        while let node = currentNode {
            if predicate(node.value) {
                // Perform the action before removing the node
                action?(node.value)
                
                if node === head {
                    // Removing the head node
                    head = node.next
                    if head == nil {
                        // Queue is now empty
                        tail = nil
                    }
                    currentNode = head
                } else {
                    // Bypass the current node
                    previousNode?.next = node.next
                    if node.next == nil {
                        // Removed the tail node
                        tail = previousNode
                    }
                    currentNode = node.next
                }
            } else {
                previousNode = currentNode
                currentNode = node.next
            }
        }
    }
}

extension Queue: Sequence {
    public func makeIterator() -> AnyIterator<T> {
        var currentNode = head
        return AnyIterator {
            if let node = currentNode {
                currentNode = node.next
                return node.value
            } else {
                return nil
            }
        }
    }
}

extension Queue: CustomStringConvertible {
    /// Provides a string representation of the queue's contents
    public var description: String {
        var values = [String]()
        var currentNode = head
        while let node = currentNode {
            values.append("\(node.value)")
            currentNode = node.next
        }
        return values.joined(separator: " -> ")
    }
}
