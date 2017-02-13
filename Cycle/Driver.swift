//
//  Driver.swift
//  Cycle
//
//  Created by jinseo on 2017. 2. 13..
//  Copyright © 2017년 Riiid. All rights reserved.
//

import Foundation
import RxSwift

public struct Driver<Source, Sink> {
    let drive: (Observable<Sink>) -> (Observable<Source>, Disposable)
}

extension Driver {
    var anyDriver: Driver<Any, Any> {
        return Driver<Any,Any> { anySink$ in
            let concreteSink$ = anySink$.cast(to: Sink.self)
            let (observable, disposable) = self.drive(concreteSink$)
            return (observable.castToAny(), disposable)
        }
    }
}

