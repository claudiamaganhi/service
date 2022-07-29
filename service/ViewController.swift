import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://api.thecatapi.com/v1/images/search?breed_id=beng")
        Service().fetchCat(url: url) { result in
            switch result {
            case .success(let result):
                print("FOI SUCESSO: \(result)")
            case .failure(let error):
                print("DEU RUIM: \(error)")
            }
        }
    }
}

