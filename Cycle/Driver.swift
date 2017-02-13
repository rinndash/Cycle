//
//  Driver.swift
//  Cycle
//
//  Created by jinseo on 2017. 2. 13..
//  Copyright © 2017년 Riiid. All rights reserved.
//

import Foundation
import RxSwift

public struct CycleDriver<Source, Sink> {
    public let drive: (Observable<Sink>) -> (Observable<Source>, Disposable)
}

extension CycleDriver {
    public init(_ f: @escaping (Observable<Sink>) -> (Observable<Source>, Disposable)) {
        drive = f
    }
}

extension CycleDriver {
    public var anyDriver: CycleDriver<Any, Any> {
        return CycleDriver<Any,Any> { anySink$ in
            let concreteSink$ = anySink$.cast(to: Sink.self)
            let (observable, disposable) = self.drive(concreteSink$)
            return (observable.castToAny(), disposable)
        }
    }
}
