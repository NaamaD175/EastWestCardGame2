import UIKit
import CoreLocation

enum PlayerSide: String {
    case west = "west"
    case east = "east"
}

class HomeViewController: UIViewController {

    @IBOutlet weak var home_BTN_enterName: UIButton!
    @IBOutlet weak var home_BTN_play: UIButton!
    @IBOutlet weak var home_LBL_greeting: UILabel!
    @IBOutlet weak var home_VIEW_westHighlight: UIView!
    @IBOutlet weak var home_VIEW_eastHighlight: UIView!

    private var westLocationLabel = UILabel()
    private var eastLocationLabel = UILabel()
    private var westGlobe: UIImageView!
    private var eastGlobe: UIImageView!
    private var westSideLabel: UILabel!
    private var eastSideLabel: UILabel!

    private var activeGlobeConstraints: [NSLayoutConstraint] = []
    private var playBtnStoryboardTop: NSLayoutConstraint?
    private var playBtnPortraitBottom: NSLayoutConstraint?

    var playerName: String = ""
    var playerSide: PlayerSide?

    private var locationManager = CLLocationManager()
    private let referenceLongitude: Double = 34.817549168324334

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft, .landscapeRight]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        home_BTN_play.isEnabled = false
        home_LBL_greeting.isHidden = true
        home_BTN_enterName.isHidden = false
        view.clipsToBounds = true

        let safe = view.safeAreaLayoutGuide
        for lbl in [home_LBL_greeting!, home_BTN_enterName!] as [UIView] {
            view.constraints
                .filter { ($0.firstItem as? UIView) == lbl && $0.firstAttribute == .top }
                .forEach { $0.isActive = false }
        }
        NSLayoutConstraint.activate([
            home_LBL_greeting.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            home_BTN_enterName.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
        ])

        for hv in [home_VIEW_westHighlight!, home_VIEW_eastHighlight!] {
            hv.translatesAutoresizingMaskIntoConstraints = false
            view.constraints
                .filter { ($0.firstItem as? UIView) == hv || ($0.secondItem as? UIView) == hv }
                .forEach { $0.isActive = false }
        }

        playBtnStoryboardTop = view.constraints.first {
            ($0.firstItem as? UIButton) == home_BTN_play && $0.firstAttribute == .top
        }
        playBtnPortraitBottom = home_BTN_play.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)

        setupGlobeImages()

        // If name was saved from a previous session hide the insert name button
        if let saved = UserDefaults.standard.string(forKey: "savedPlayerName") {
            playerName = saved
            home_LBL_greeting.text = "Hi \(playerName)!"
            home_LBL_greeting.isHidden = false
            home_BTN_enterName.isHidden = true
        }

        home_VIEW_westHighlight.isHidden = true
        home_VIEW_eastHighlight.isHidden = true

        styleButton(home_BTN_play, title: "START", color: .systemBlue)
        styleButton(home_BTN_enterName, title: "Insert Name", color: .systemGray)
        home_LBL_greeting.font = UIFont.boldSystemFont(ofSize: 26)

        applyDarkModeAppearance()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ask for location every time the screen appers
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            playerSide = nil
            home_VIEW_westHighlight.isHidden = true
            home_VIEW_eastHighlight.isHidden = true
            westLocationLabel.isHidden = true
            eastLocationLabel.isHidden = true
            home_BTN_play.isEnabled = false
            locationManager.requestLocation()
        }
    }

    private func styleButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    }


    private func setupGlobeImages() {
        westGlobe = UIImageView(image: UIImage(named: "globe-west"))
        westGlobe.contentMode = .scaleAspectFit
        westGlobe.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(westGlobe, aboveSubview: home_VIEW_westHighlight)

        eastGlobe = UIImageView(image: UIImage(named: "globe-east"))
        eastGlobe.contentMode = .scaleAspectFit
        eastGlobe.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(eastGlobe, aboveSubview: home_VIEW_eastHighlight)

        westSideLabel = makeLabel(text: "West Side", bold: true, size: 17)
        eastSideLabel = makeLabel(text: "East Side", bold: true, size: 17)
        westLocationLabel = makeLabel(text: "You are on the West Side", bold: false, size: 13)
        eastLocationLabel = makeLabel(text: "You are on the East Side", bold: false, size: 13)
        westLocationLabel.isHidden = true
        eastLocationLabel.isHidden = true

        for lbl in [westSideLabel!, eastSideLabel!, westLocationLabel, eastLocationLabel] {
            view.addSubview(lbl)
        }

        let globeSize: CGFloat = 200
        NSLayoutConstraint.activate([
            westGlobe.widthAnchor.constraint(equalToConstant: globeSize),
            westGlobe.heightAnchor.constraint(equalToConstant: globeSize),
            eastGlobe.widthAnchor.constraint(equalToConstant: globeSize),
            eastGlobe.heightAnchor.constraint(equalToConstant: globeSize),
            westSideLabel.centerXAnchor.constraint(equalTo: westGlobe.centerXAnchor),
            westSideLabel.topAnchor.constraint(equalTo: westGlobe.bottomAnchor, constant: 4),
            westSideLabel.widthAnchor.constraint(equalToConstant: globeSize),
            westLocationLabel.centerXAnchor.constraint(equalTo: westGlobe.centerXAnchor),
            westLocationLabel.topAnchor.constraint(equalTo: westSideLabel.bottomAnchor, constant: 4),
            westLocationLabel.widthAnchor.constraint(equalToConstant: globeSize),
            eastSideLabel.centerXAnchor.constraint(equalTo: eastGlobe.centerXAnchor),
            eastSideLabel.topAnchor.constraint(equalTo: eastGlobe.bottomAnchor, constant: 4),
            eastSideLabel.widthAnchor.constraint(equalToConstant: globeSize),
            eastLocationLabel.centerXAnchor.constraint(equalTo: eastGlobe.centerXAnchor),
            eastLocationLabel.topAnchor.constraint(equalTo: eastSideLabel.bottomAnchor, constant: 4),
            eastLocationLabel.widthAnchor.constraint(equalToConstant: globeSize),
        ])

        applyLayoutForOrientation(isPortrait: view.bounds.height > view.bounds.width)
    }

    private func makeLabel(text: String, bold: Bool, size: CGFloat) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size, weight: .medium)
        lbl.textColor = .systemBlue
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }


    private func applyLayoutForOrientation(isPortrait: Bool) {
        NSLayoutConstraint.deactivate(activeGlobeConstraints)
        activeGlobeConstraints.removeAll()

        for hv in [home_VIEW_westHighlight!, home_VIEW_eastHighlight!] {
            view.constraints
                .filter { ($0.firstItem as? UIView) == hv || ($0.secondItem as? UIView) == hv }
                .forEach { $0.isActive = false }
            hv.constraints
                .filter { $0.firstAttribute == .width || $0.firstAttribute == .height }
                .forEach { $0.isActive = false }
        }

        let safe = view.safeAreaLayoutGuide

        if isPortrait {
            let globeCenterY = view.centerYAnchor

            activeGlobeConstraints = [
                westGlobe.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
                westGlobe.centerYAnchor.constraint(equalTo: globeCenterY, constant: -30),

                eastGlobe.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
                eastGlobe.centerYAnchor.constraint(equalTo: globeCenterY, constant: -30),

                home_VIEW_westHighlight.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                home_VIEW_westHighlight.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
                home_VIEW_westHighlight.topAnchor.constraint(equalTo: westGlobe.topAnchor, constant: -8),
                home_VIEW_westHighlight.bottomAnchor.constraint(equalTo: westLocationLabel.bottomAnchor, constant: 12),

                home_VIEW_eastHighlight.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
                home_VIEW_eastHighlight.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                home_VIEW_eastHighlight.topAnchor.constraint(equalTo: eastGlobe.topAnchor, constant: -8),
                home_VIEW_eastHighlight.bottomAnchor.constraint(equalTo: eastLocationLabel.bottomAnchor, constant: 12),

                home_BTN_play.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -30),
            ]

            home_VIEW_westHighlight.layer.cornerRadius = 0
            home_VIEW_eastHighlight.layer.cornerRadius = 0

            playBtnStoryboardTop?.isActive = false
            playBtnPortraitBottom?.isActive = true

        } else {
            activeGlobeConstraints = [
                westGlobe.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 30),
                westGlobe.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                eastGlobe.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -30),
                eastGlobe.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                home_VIEW_westHighlight.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                home_VIEW_westHighlight.topAnchor.constraint(equalTo: view.topAnchor),
                home_VIEW_westHighlight.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                home_VIEW_westHighlight.trailingAnchor.constraint(equalTo: westGlobe.trailingAnchor, constant: 20),

                home_VIEW_eastHighlight.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                home_VIEW_eastHighlight.topAnchor.constraint(equalTo: view.topAnchor),
                home_VIEW_eastHighlight.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                home_VIEW_eastHighlight.leadingAnchor.constraint(equalTo: eastGlobe.leadingAnchor, constant: -20),
            ]

            home_VIEW_westHighlight.layer.cornerRadius = 0
            home_VIEW_eastHighlight.layer.cornerRadius = 0

            playBtnPortraitBottom?.isActive = false
            playBtnStoryboardTop?.isActive = true
        }

        NSLayoutConstraint.activate(activeGlobeConstraints)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.applyLayoutForOrientation(isPortrait: size.height > size.width)
        })
    }

    // Dark mode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyDarkModeAppearance()
        }
    }

    private func applyDarkModeAppearance() {
        let isDark = traitCollection.userInterfaceStyle == .dark

        westGlobe?.image = UIImage(named: isDark ? "globe-west-dark" : "globe-west")
        eastGlobe?.image = UIImage(named: isDark ? "globe-east-dark" : "globe-east")

        let labelColor: UIColor = isDark ? UIColor(white: 0.85, alpha: 1) : .systemBlue
        home_LBL_greeting.textColor = isDark ? .white : .label
        westSideLabel?.textColor = labelColor
        eastSideLabel?.textColor = labelColor
        westLocationLabel.textColor = labelColor
        eastLocationLabel.textColor = labelColor
    }

    // User type his name
    @IBAction func tappedEnterName(_ sender: UIButton) {
        let dialog = UIAlertController(title: "Your Name", message: "Enter your name (English only)", preferredStyle: .alert)
        dialog.addTextField { field in
            field.placeholder = "e.g. Dana"
            field.autocorrectionType = .no
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            let input = dialog.textFields?.first?.text ?? ""
            if input.isBlank {
                self.showAlert(message: "Name cannot be empty")
                return
            }
            if !input.isValidEnglishName {
                self.showAlert(message: "Use English letters only")
                return
            }
            let cleanName = String(input.capitalized.prefix(10))
            self.playerName = cleanName
            UserDefaults.standard.set(cleanName, forKey: "savedPlayerName")
            
            // Show greeting, hide Insert name button completely
            self.home_LBL_greeting.text = "Hi \(cleanName)!"
            self.home_LBL_greeting.isHidden = false
            self.home_BTN_enterName.isHidden = true
            self.checkReadyToPlay()
        }
        dialog.addAction(confirmAction)
        present(dialog, animated: true)
    }

    @IBAction func tappedPlay(_ sender: UIButton) {
        performSegue(withIdentifier: "toGame", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGame" {
            let battleVC = segue.destination as! BattleViewController
            battleVC.playerName = playerName
            battleVC.playerSide = playerSide ?? .west
        }
    }

    // Enable start only when both name and loaction are confirmed
    private func checkReadyToPlay() {
        home_BTN_play.isEnabled = !playerName.isEmpty && playerSide != nil
    }

    // Ligh up the correct side and show the message in the matching globe
    private func showSideHighlight(for side: PlayerSide) {
        let isDark = traitCollection.userInterfaceStyle == .dark
        let color = isDark
            ? UIColor.systemYellow.withAlphaComponent(0.55)
            : UIColor.systemBlue.withAlphaComponent(0.15)
        if side == .west {
            home_VIEW_westHighlight.backgroundColor = color
            home_VIEW_westHighlight.isHidden = false
            home_VIEW_eastHighlight.isHidden = true
            westLocationLabel.isHidden = false
            eastLocationLabel.isHidden = true
        } else {
            home_VIEW_eastHighlight.backgroundColor = color
            home_VIEW_eastHighlight.isHidden = false
            home_VIEW_westHighlight.isHidden = true
            eastLocationLabel.isHidden = false
            westLocationLabel.isHidden = true
        }
    }
}

// Location
extension HomeViewController: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        // Compare to decide east or west
        let side: PlayerSide = location.coordinate.longitude < referenceLongitude ? .west : .east
        playerSide = side
        showSideHighlight(for: side)
        checkReadyToPlay()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
