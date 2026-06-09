import Foundation

protocol RoundTimerDelegate: AnyObject {
    func timerDidTick(secondsLeft: Int)
    func timerDidFinish()
}

class RoundTimer {

    //Seconds each round lasts - 5
    private let roundDuration = 5

    weak var delegate: RoundTimerDelegate?
    private var timer: Timer?
    private var secondsLeft = 5

    init(delegate: RoundTimerDelegate) {
        self.delegate = delegate
    }

    //Start from the beginning
    func start() {
        stop()
        secondsLeft = roundDuration
        delegate?.timerDidTick(secondsLeft: secondsLeft)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: tick(_:))
    }

    //Stop the timer
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    //Resume from wherever the counter left off
    func resume() {
        stop()
        delegate?.timerDidTick(secondsLeft: secondsLeft)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: tick(_:))
    }

    //Called every second by the timer
    private func tick(_ t: Timer) {
        secondsLeft -= 1
        delegate?.timerDidTick(secondsLeft: secondsLeft)
        if secondsLeft == 0 {
            t.invalidate()
            delegate?.timerDidFinish()
        }
    }
}
