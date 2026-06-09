import UIKit

struct Card {
    let imageName: String
    let value: Int // 2 to 14
}

class BattleViewController: UIViewController {


    @IBOutlet weak var battle_LBL_leftName: UILabel! // Player name
    @IBOutlet weak var battle_LBL_leftScore: UILabel! // Score of the player name
    @IBOutlet weak var battle_LBL_rightName: UILabel! // PC
    @IBOutlet weak var battle_LBL_rightScore: UILabel! // Score of the PC
    @IBOutlet weak var battle_IMG_leftCard: UIImageView!
    @IBOutlet weak var battle_IMG_rightCard: UIImageView!
    @IBOutlet weak var battle_IMG_clock: UIImageView!
    @IBOutlet weak var battle_LBL_countdown: UILabel!
    @IBOutlet weak var battle_VIEW_leftGlow: UIView!
    @IBOutlet weak var battle_VIEW_rightGlow: UIView! 


    var playerName: String = ""
    var playerSide: PlayerSide = .west

    private var playerScore   = 0
    private var computerScore = 0
    private var roundsPlayed  = 0
    private let totalRounds   = 10 // Game ends after 10 rounds

    private var roundTimer: RoundTimer?
    private var isScreenActive = false

    // All 52 cards as pairs
    private let deck: [Card] = {
        let values: [(String, Int)] = [
            // Ace = 14 (strongest)
            ("ace", 14), ("two", 2), ("three", 3), ("four", 4),
            ("five", 5), ("six", 6), ("seven", 7), ("eight", 8),
            ("nine", 9), ("ten", 10), ("jack", 11), ("queen", 12), ("king", 13)
        ]
        let suits = ["spades", "clubs", "diamonds", "hearts"]
        var cards: [Card] = []
        for (name, value) in values {
            for suit in suits {
                cards.append(Card(imageName: "\(name) of \(suit)", value: value))
            }
        }
        return cards
    }()

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupNameLabels()
        setupScoreLabels()
        setupClockIcon()
        refreshScoreLabels()
        hideGlowViews()
        battle_IMG_leftCard.image  = UIImage(named: "card-back")
        battle_IMG_rightCard.image = UIImage(named: "card-back")
        applyDarkModeAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isScreenActive = true
        SoundManager.shared.startBackgroundMusic()
    
        // Create a timer and start the first round
        roundTimer = RoundTimer(delegate: self)
        roundTimer?.start()

        // Pause the timer and start the first round
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackground),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        // Resume when they come back to the app
        NotificationCenter.default.addObserver(self, selector: #selector(handleForeground),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // Stop everthing when leaving the screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isScreenActive = false
        roundTimer?.stop()
        SoundManager.shared.stopBackgroundMusic()
        NotificationCenter.default.removeObserver(self)
    }


    @objc private func handleBackground() {
        roundTimer?.stop()
        SoundManager.shared.pauseBackgroundMusic()
    }

    @objc private func handleForeground() {
        roundTimer?.resume()
        SoundManager.shared.resumeBackgroundMusic()
    }


    // Pick two random card -> show them -> update scores
    private func playRound() {
        guard let leftCard = deck.randomElement(),
              let rightCard = deck.randomElement() else { return }

        SoundManager.shared.playFlip()
        battle_IMG_leftCard.image  = UIImage(named: leftCard.imageName)
        battle_IMG_rightCard.image = UIImage(named: rightCard.imageName)

        let playerValue   = playerSide == .west ? leftCard.value  : rightCard.value
        let computerValue = playerSide == .west ? rightCard.value : leftCard.value

        // Award points
        let tie       = (playerValue == computerValue)
        let playerWon = playerValue > computerValue
        if playerWon {
            playerScore += 1
            SoundManager.shared.playVictory()
        } else if !tie {
            computerScore += 1
            SoundManager.shared.playLose()
        }

        refreshScoreLabels()
        // Mark the winning side's card
        highlightRoundWinner(playerWon: playerWon, tie: tie)
    }

    // Move to the next round or end game
    private func advanceRound() {
        roundsPlayed += 1

        if roundsPlayed >= totalRounds {
            // Finish - go to the results screen
            performSegue(withIdentifier: "toResult", sender: self)
            return
        }

        // Reset cards to the next round
        battle_IMG_leftCard.image  = UIImage(named: "card-back")
        battle_IMG_rightCard.image = UIImage(named: "card-back")
        hideGlowViews()
        roundTimer?.start()
    }

    // Update scores
    private func refreshScoreLabels() {
        if playerSide == .west {
            battle_LBL_leftScore.text  = "\(playerScore)"
            battle_LBL_rightScore.text = "\(computerScore)"
        } else {
            battle_LBL_leftScore.text  = "\(computerScore)"
            battle_LBL_rightScore.text = "\(playerScore)"
        }
    }

    private func highlightRoundWinner(playerWon: Bool, tie: Bool) {
        if tie {
            hideGlowViews()
            return
        }

        let isDark = traitCollection.userInterfaceStyle == .dark
        let winColor: UIColor = isDark
            ? UIColor.systemYellow.withAlphaComponent(0.35)
            : UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 0.15)

        let playerIsLeft = (playerSide == .west)
        let leftWon = playerWon ? playerIsLeft : !playerIsLeft

        battle_VIEW_leftGlow.isHidden         = !leftWon
        battle_VIEW_rightGlow.isHidden        = leftWon
        battle_VIEW_leftGlow.backgroundColor  = winColor
        battle_VIEW_rightGlow.backgroundColor = winColor
    }

    private func hideGlowViews() {
        battle_VIEW_leftGlow.isHidden  = true
        battle_VIEW_rightGlow.isHidden = true
    }


    private func setupNameLabels() {
        if playerSide == .west {
            battle_LBL_leftName.text  = playerName
            battle_LBL_rightName.text = "PC"
        } else {
            battle_LBL_leftName.text  = "PC"
            battle_LBL_rightName.text = playerName
        }
        battle_LBL_leftName.font  = UIFont.systemFont(ofSize: 16)
        battle_LBL_rightName.font = UIFont.systemFont(ofSize: 16)
        battle_LBL_leftName.translatesAutoresizingMaskIntoConstraints  = true
        battle_LBL_rightName.translatesAutoresizingMaskIntoConstraints = true
    }

    private func setupScoreLabels() {
        battle_LBL_leftScore.font  = UIFont.boldSystemFont(ofSize: 36)
        battle_LBL_rightScore.font = UIFont.boldSystemFont(ofSize: 36)
        battle_LBL_leftScore.translatesAutoresizingMaskIntoConstraints  = true
        battle_LBL_rightScore.translatesAutoresizingMaskIntoConstraints = true
    }

    private func setupClockIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .regular)
        battle_IMG_clock.image     = UIImage(systemName: "stopwatch", withConfiguration: config)
        battle_IMG_clock.tintColor = .darkGray
    }


    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyDarkModeAppearance()
        }
    }

    // Updates all text and icon colors for the currect mode (dark or light)
    private func applyDarkModeAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        let textColor: UIColor = isDark ? .white : .label
        battle_LBL_leftName.textColor   = textColor
        battle_LBL_rightName.textColor  = textColor
        battle_LBL_leftScore.textColor  = textColor
        battle_LBL_rightScore.textColor = textColor
        battle_LBL_countdown.textColor  = textColor
        battle_IMG_clock.tintColor      = isDark ? .lightGray : .darkGray
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe   = view.safeAreaInsets
        let left   = safe.left + 16
        let right  = view.bounds.width - safe.right - 16
        let top    = safe.top + 8
        let nameH: CGFloat  = 22
        let scoreH: CGFloat = 46
        let w: CGFloat      = 160

        battle_LBL_leftName.frame   = CGRect(x: left,      y: top,              width: w, height: nameH)
        battle_LBL_leftScore.frame  = CGRect(x: left,      y: top + nameH + 2,  width: w, height: scoreH)
        battle_LBL_rightName.frame  = CGRect(x: right - w, y: top,              width: w, height: nameH)
        battle_LBL_rightScore.frame = CGRect(x: right - w, y: top + nameH + 2,  width: w, height: scoreH)
    }


    // Pass game results to the result screen before navigating
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toResult",
              let resultVC = segue.destination as? ResultViewController else { return }

        if playerScore >= computerScore {
            resultVC.winnerName = playerName
            resultVC.finalScore = playerScore
            resultVC.playerWon  = true
        } else {
            resultVC.winnerName = "Computer"
            resultVC.finalScore = computerScore
            resultVC.playerWon  = false
        }
    }
}


extension BattleViewController: RoundTimerDelegate {

    func timerDidTick(secondsLeft: Int) {
        battle_LBL_countdown.text = "\(secondsLeft)"
    }

    // Timer reaches zero -> reveal the cards for 3 seconds -> countinuing
    func timerDidFinish() {
        playRound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self, self.isScreenActive else { return }
            self.advanceRound()
        }
    }
}
