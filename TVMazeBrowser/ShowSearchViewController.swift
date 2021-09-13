import UIKit

class ShowSearchViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    // MARK:- Data

    private var shows: [[String: AnyObject]] = [] {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }

    private var imageCache: [String: UIImage] = [:] {
        didSet {
            // Set the image for row matching the new key added to the cache
            let key = Set(oldValue.keys).symmetricDifference(imageCache.keys).first
            let show = shows.enumerated().filter({ (_, show) in
                let imageKey = (show["image"] as! [String: AnyObject])["original"] as! String
                return imageKey == key
            }).first
            let path = (show?.offset).map { IndexPath(row: $0, section: 0) }

            DispatchQueue.main.async {
                let cell = path.map { self.tableView.cellForRow(at: $0) } as? ShowCell
                cell?.showImageView?.image = key.map { self.imageCache[$0] } as? UIImage
            }
        }
    }

    // MARK:- ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load Shows
        let url = URL(string: "https://api.tvmaze.com/shows")!
        URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data),
                let jsonArray = json as? [[String: AnyObject]] else { return }

            // Decode Shows
            self.shows = jsonArray
        }.resume()
    }

}

// MARK:- UITableViewDataSource

extension ShowSearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let show = shows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCell", for: indexPath) as! ShowCell
        cell.titleLabel.text = show["name"] as? String
        cell.showImageView?.image = imageCache[(show["image"] as! [String: AnyObject])["original"] as! String]
        cell.scheduleLabel.text = {
            let showSchedule = show["schedule"] as! [String: AnyObject]
            let time = showSchedule["time"] as! String
            let days = showSchedule["days"] as! [String]
            let hour = Int(time[..<time.index(time.startIndex, offsetBy: 2)])!

            var schedule = ""

            if hour < 12 {
                schedule = schedule + "Mornings"
            } else if hour < 18 {
                schedule = schedule + "Afternoons"
            } else {
                schedule = schedule + "Nights"
            }

            schedule = days.reduce(into: "", { $0 = $0 + "\($1), " }) + schedule

            schedule = hour < 6 ? "Early" + schedule : schedule

            return schedule
        }()
        return cell
    }

}

// MARK:- UITableViewDelegate

extension ShowSearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let show = shows[indexPath.row]
        let imageKey = (show["image"] as! [String: AnyObject])["original"] as! String

        // Return if image already loaded
        guard imageCache[imageKey] == nil else { return }

        let url = URL(string: imageKey)!
        URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
            guard error == nil, let data = data else { return }
            let image = UIImage(data: data)
            self.imageCache[imageKey] = image
        }.resume()
    }

}
