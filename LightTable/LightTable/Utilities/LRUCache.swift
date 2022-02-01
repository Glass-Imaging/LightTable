 /*
  Copyright (c) 2016 Matthijs Hollemans and contributors

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  */

import Foundation

public class LRUCache<KeyType: Hashable> {
  private let maxSize: Int
  private var cache: [KeyType: Any] = [:]
  private var priority: LinkedList<KeyType> = LinkedList<KeyType>()
  private var key2node: [KeyType: LinkedList<KeyType>.LinkedListNode<KeyType>] = [:]

  public init(_ maxSize: Int) {
    self.maxSize = maxSize
  }

  public func get(_ key: KeyType) -> Any? {
    guard let val = cache[key] else {
      return nil
    }

    remove(key)
    insert(key, val: val)

    return val
  }

  public func set(_ key: KeyType, val: Any) {
    if cache[key] != nil {
      remove(key)
    } else if priority.count >= maxSize, let keyToRemove = priority.last?.value {
      remove(keyToRemove)
    }

    insert(key, val: val)
  }

  private func remove(_ key: KeyType) {
    cache.removeValue(forKey: key)
    guard let node = key2node[key] else {
      return
    }
    priority.remove(node: node)
    key2node.removeValue(forKey: key)
  }

  private func insert(_ key: KeyType, val: Any) {
    cache[key] = val
    priority.insert(key, at: 0)
    guard let first = priority.head else {
      return
    }
    key2node[key] = first
  }
}
