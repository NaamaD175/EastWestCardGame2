import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var result_LBL_winner: UILabel!
    @IBOutlet weak var result_LBL_score: UILabel!
    @IBOutlet weak var result_BTN_back: UIButton!

    var winnerName: String = ""
    var finalScore: Int = 0
    var playerWon: Bool = true

    // Result screen stays in landscape, matching the battle screen
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        result_LBL_winner.text = "Winner: \(winnerName)"
        result_LBL_score.text  = "Score: \(finalScore)"

        styleBackButton()
        applyDarkModeAppearance()

        // Play the appropriate end-game sound
        playerWon ? SoundManager.shared.playVictory() : SoundManager.shared.playLose()
    }


    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyDarkModeAppearance()
        }
    }

    // Updates text colors for dark or light mode
    private func applyDarkModeAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        let textColor: UIColor = isDark ? .white : .label
        result_LBL_winner.textColor = textColor
        result_LBL_score.textColor  = textColor
    }


    private func styleBackButton() {
        result_BTN_back.setTitle("BACK TO MENU", for: .normal)
        result_BTN_back.setTitleColor(.white, for: .normal)
        result_BTN_back.backgroundColor = .systemBlue
        result_BTN_back.layer.cornerRadius = 12
        result_BTN_back.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    }


    @IBAction func tappedBackToHome(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true)
    }
}
