//
//  Observable+Cycle.swift
//  Cycle
//
//  Created by jinseo on 2017. 2. 13..
//  Copyright © 2017년 Riiid. All rights reserved.
//

import RxSwift

public extension ObservableType {
    func cast<T>(to: T.Type) -> Observable<T> {
        return filter { $0 is T }.map { $0 as! T }
    }
    
    func castToAny() -> Observable<Any> {
        return cast(to: Any.self)
    }
}

public func +(lhs: Disposable, rhs: Disposable) -> Disposable {
    return Disposables.create(lhs, rhs)
}
