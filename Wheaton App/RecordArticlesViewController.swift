//
//  RecordArticlesViewController.swift
//  Wheaton App
//
//  Created by Jack Work on 7/1/15.
//
//  NOTICE: Ported to Swift 5 by an LLM (Claude Code), 2026-10-11.
//

import UIKit

@objc(RecordArticlesViewController)
class RecordArticlesViewController: UITableViewController {

    private let feedParser = RSSFeedParser()
    private var isLoading = true

    override func viewDidLoad() {
        super.viewDidLoad()

        let activity = UIActivityIndicatorView(style: .medium)
        activity.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
        activity.startAnimating()

        let url = URL(string: "https://thewheatonrecord.com/feed/")!
        DispatchQueue.global(qos: .userInitiated).async {
            self.feedParser.startParsingWithContentsOfURL(url)
            DispatchQueue.main.async {
                self.isLoading = false
                activity.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 0 : feedParser.arrParsedData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "record")
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = feedParser.arrParsedData[indexPath.row]["title"]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isLoading ? "Loading articles..." : "Most Recent"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let link = feedParser.arrParsedData[indexPath.row]["link"], let url = URL(string: link) else { return }

        let alert = UIAlertController(title: "Open Safari?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Read Article", style: .default) { _ in
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }
}
