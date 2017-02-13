//
//  Run.swift
//  Cycle
//
//  Created by jinseo on 2017. 2. 13..
//  Copyright © 2017년 Riiid. All rights reserved.
//

import Foundation
import RxSwift

public typealias Sources = [String: Observable<Any>]
public typealias Sinks = [String: Observable<Any>]
public typealias DriversDefinition = [String: Driver<Any, Any>]

typealias SinkProxies = [String: PublishSubject<Any>]

fileprivate func makeSinkProxies(_ drivers: DriversDefinition) -> SinkProxies {
    var sinkProxies: SinkProxies = [:]
    drivers.forEach { key, _ in
        let subject = PublishSubject<Any>()
        sinkProxies[key] = subject
    }
    return sinkProxies
}

fileprivate func callDrivers(_ drivers: DriversDefinition, _ sinkProxies: SinkProxies) -> (Sources, Disposable){
    var result: [String: Observable<Any>] = [:]
    var disposables: [Disposable] = []
    drivers.forEach { key, driver in
        guard let proxy = sinkProxies[key] else { return }
        let (observable, disposable) = driver.drive(proxy)
        result[key] = observable
        disposables.append(disposable)
    }
    return (result, Disposables.create(disposables))
}

fileprivate func replicateMany(_ sinks: Sinks, _ sinkProxies: SinkProxies) -> Disposable {
    let subscriptions = sinks.flatMap { key, sink -> Disposable? in
        guard let proxy = sinkProxies[key] else { return nil }
        return sink.subscribe(proxy)
    }
    return Disposables.create(subscriptions)
}

public func run(main: (Sources) -> (Sinks, Disposable), drivers: DriversDefinition) -> Disposable {
    let sinkProxies: SinkProxies = makeSinkProxies(drivers)
    let (sources, driverSubscription) = callDrivers(drivers, sinkProxies)
    let (sinks, mainDispoable) = main(sources)
    return Disposables.create(replicateMany(sinks, sinkProxies), driverSubscription + mainDispoable)
}
