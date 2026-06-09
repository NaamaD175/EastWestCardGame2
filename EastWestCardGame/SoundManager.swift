import AVFoundation

/// Manages all audio in the app: background music and sound effects.
/// Background music loops continuously and pauses/resumes with the app lifecycle.
/// Sound effects (flip, win, lose) play once on demand.
class SoundManager {

    static let shared = SoundManager()
    private init() {}

    private var backgroundPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?

    // MARK: - Background Music

    /// Start looping background music from the moment the game begins.
    func startBackgroundMusic() {
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

    /// Pause background music (app goes to background or game ends).
    func pauseBackgroundMusic() {
        backgroundPlayer?.pause()
    }

    /// Resume background music after returning to the app.
    func resumeBackgroundMusic() {
        backgroundPlayer?.play()
    }

    /// Stop and reset background music (when leaving the game screen).
    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer?.currentTime = 0
        backgroundPlayer = nil
    }

    // MARK: - Sound Effects

    /// Play the card flip sound between rounds.
    func playFlip() {
        playEffect(named: "flipCard")
    }

    /// Play the victory sound when the player wins a round or the game.
    func playVictory() {
        playEffect(named: "victorySound")
    }

    /// Play the lose sound when the player loses a round or the game.
    func playLose() {
        playEffect(named: "loseGame")
    }

    private func playEffect(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.volume = 0.8
            effectPlayer?.play()
        } catch {
            print("Sound effect error: \(error)")
        }
    }
}
