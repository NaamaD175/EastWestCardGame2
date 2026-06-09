import Foundation
import UIKit

extension UIViewController {

    func showAlert(message: String, duration: Double = 2.0) {
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.alpha = 0
        label.layer.cornerRadius = 14
        label.clipsToBounds = true

        let padding: CGFloat = 32
        let maxWidth = view.frame.width - padding * 2
        let size = label.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))

        label.frame = CGRect(
            x: padding,
            y: view.frame.height - size.height - 120,
            width: maxWidth,
            height: size.height + 20
        )

        view.addSubview(label)

        UIView.animate(withDuration: 0.25, animations: {
            label.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: duration, options: .curveEaseOut) {
                label.alpha = 0
            } completion: { _ in
                label.removeFromSuperview()
            }
        }
    }
}

extension String {

    // Returns true if the string is empty or contains only spaces
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Returns true if the string contains English letters and spaces
    var isValidEnglishName: Bool {
        guard !self.isEmpty else { return false }
        return self.range(of: #"^[A-Za-z ]+$"#, options: .regularExpression) != nil
    }
}
