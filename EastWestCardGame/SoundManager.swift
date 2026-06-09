import AVFoundation

class SoundManager {

    static let shared = SoundManager()
    private init() {}

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    private var backgroundPlayer: AVAudioPlayer?
    private var flipPlayer: AVAudioPlayer?
    private var resultPlayer: AVAudioPlayer?


    // Start looping background music from the moment the game begins
    func startBackgroundMusic() {
        setupAudioSession()
        guard backgroundPlayer == nil else {
            backgroundPlayer?.play()
            return
        }
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else { return }
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1 // loop forever
            backgroundPlayer?.volume = 0.4
            backgroundPlayer?.play()
        } catch {
            print("Background music error: \(error)")
        }
    }

    // Pause background music
    func pauseBackgroundMusic() {
        backgroundPlayer?.pause()
    }

    // Resume background music after returning to the app
    func resumeBackgroundMusic() {
        backgroundPlayer?.play()
    }

    // Stop background music (when leaving the game)
    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer?.currentTime = 0
        backgroundPlayer = nil
    }


    // Play the card flip sound
    func playFlip() {
        guard let url = Bundle.main.url(forResource: "flipCard", withExtension: "mp3") else { return }
        do {
            flipPlayer = try AVAudioPlayer(contentsOf: url)
            flipPlayer?.volume = 0.8
            flipPlayer?.play()
        } catch {
            print("Flip sound error: \(error)")
        }
    }

    // Play the victory sound
    func playVictory() {
        playResultEffect(named: "victorySound")
    }

    // Play the lose sound
    func playLose() {
        playResultEffect(named: "loseGame")
    }

    private func playResultEffect(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            resultPlayer = try AVAudioPlayer(contentsOf: url)
            resultPlayer?.volume = 0.8
            resultPlayer?.play()
        } catch {
            print("Result sound error: \(error)")
        }
    }
}
