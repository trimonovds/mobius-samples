//
//  TimerAction.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 03/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

class TimerAction {

    // MARK: Public Nested Types

    typealias Block = () -> Void

    // MARK: Public

    init(timeInterval: TimeInterval, repeats: Bool, onTick: @escaping Block) {
        let timerTarget = TimerTarget(onTick: onTick)
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: timerTarget,
                                          selector: #selector(TimerTarget.timerTickHandler),
                                          userInfo: nil, repeats: repeats)
    }

    deinit {
        invalidate()
    }

    // MARK: -

    func invalidate() {
        timer.invalidate()
    }

    // MARK: Private Properties

    private let timer: Timer

    // MARK: Private Nested Types

    private class TimerTarget {

        var onTick: Block

        init(onTick: @escaping Block) {
            self.onTick = onTick
        }

        @objc fileprivate func timerTickHandler() {
            onTick()
        }

    }

}
