//
//  Cycle.swift
//  Cycle
//
//  Created by jinseo on 2017. 2. 13..
//  Copyright © 2017년 Riiid. All rights reserved.
//

import Foundation
import RxSwift

public protocol Cycle {
    static func cycle(_ sources: Sources) -> (Sinks, Disposable)
}

public enum CycleKey {
    public static let view: String = "view"
}

public protocol CycleApp: Cycle {
    associatedtype Intent
    associatedtype Model
    associatedtype ViewModel
    
    static func initialModel(from sources: Sources) -> Model
    static func intent(from sources: Sources, model$: Observable<Model>) -> Observable<Intent>
    static func update(model: Model, after intent: Intent) -> (Model, [SinkType])
    static func viewModel(from model: Model) -> ViewModel
    static var commandKeys: [String] { get }
}

public extension CycleApp {
    static func cycle(_ sources: Sources) -> (Sinks, Disposable) {
        let initModel = initialModel(from: sources)
        let modelProxy = BehaviorSubject<Model>(value: initModel)
        let intent$ = intent(from: sources, model$: modelProxy)
        let model_effects = intent$
            .scan((initModel, [])) { model_effect, intent -> (Model, [SinkType]) in
                let (model, _) = model_effect
                return update(model: model, after: intent)
            }
            .shareReplay(1)
        
        let subscription = model_effects.map { $0.0 }
            .subscribe(modelProxy)
        
        let viewModel$ = modelProxy.map(viewModel)
        let sinkType$ = model_effects.map { $0.1 }
            .flatMap { Observable.from($0) }
        
        var sinks: Sinks = [:]
        commandKeys.forEach { key in
            sinks[key] = sinkType$.filter { $0.name == key }.castToAny()
        }
        sinks[CycleKey.view] = viewModel$.castToAny()
        return (sinks, subscription)
    }
}
