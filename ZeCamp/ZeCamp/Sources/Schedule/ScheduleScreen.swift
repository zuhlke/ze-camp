import Foundation
import UIKit

struct ScheduleScreen {
    
    private let dataSource: UITableViewDataSource!
    
    init(schedule: Schedule) {
        dataSource = ScheduleDataSource(schedule)
    }
    
    func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Schedule"
        let scheduleTable = ScheduleTableView()

        scheduleTable.strongDataSource = dataSource
        scheduleTable.rowHeight = UITableViewAutomaticDimension
        scheduleTable.estimatedRowHeight = 50
        
        let footer = UIView()
        let label = UILabel()
        label.text = "ZeCamp commit \(Bundle.main.shortCommitId!).\n© 2017 Zuhlke Engineering Ltd. ✨"
        label.numberOfLines = 0
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        footer.addSubview(label)
        
        scheduleTable.tableFooterView = footer
        footer.layoutMargins = UIEdgeInsets(top: 15, left: 8, bottom: 8, right: 8)
        
        [
            label.topAnchor.constraint(equalTo: footer.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: footer.layoutMarginsGuide.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: footer.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: footer.layoutMarginsGuide.trailingAnchor),
            ].activateAll()
        
        footer.layoutIfNeeded()
        footer.frame.size = footer.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        
        
        
        let delegate = ScheduleDelegate()
        delegate.viewController = viewController
        scheduleTable.strongDelegate = delegate
        viewController.view.addFillingSubview(scheduleTable)

        
        return viewController
    }
}

class ScheduleTableView: UITableView {
    fileprivate var strongDataSource: UITableViewDataSource? {
        didSet {
            dataSource = strongDataSource
        }
    }
    fileprivate var strongDelegate: UITableViewDelegate? {
        didSet {
            delegate = strongDelegate
        }
    }
}

struct TimeSlot {
    let date: Date
    let events: [Event]
}

class ScheduleDelegate: NSObject, UITableViewDelegate {
    weak var viewController: UIViewController?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let emptyScreen = UIViewController()
        emptyScreen.title = "Event"
        emptyScreen.view.backgroundColor = .white
        if #available(iOS 11.0, *) {
            emptyScreen.navigationItem.largeTitleDisplayMode = .never
        }
        viewController?.navigationController?.pushViewController(emptyScreen, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

class ScheduleDataSource: NSObject, UITableViewDataSource {
    
    let timeSlots: [TimeSlot]
    
    init(_ schedule: Schedule) {
        self.timeSlots = schedule.asOrderedTimeSlots()
    }
    
    @available(iOS 2.0, *)
    public func numberOfSections(in tableView: UITableView) -> Int {
        return timeSlots.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeSlots[section].events.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return timeSlots[section].sectionTitle
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.timeSlots[indexPath.section].events[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = "\(event.startTime) - \(event.endTime) - \(event.location)"

        return cell
    }
}

//TODO: time zone?
fileprivate let dayAndTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, HH:mm"
    return formatter
}()


fileprivate let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()

fileprivate extension Event {
    var startTime: String {
        return timeFormatter.string(from: date)
    }
    
    var endTime: String {
        let endDate = Calendar.current.date(byAdding: .minute, value: durationInMinutes, to: date)!
        return timeFormatter.string(from: endDate)
    }
}

fileprivate extension Schedule {
    
    func asOrderedTimeSlots() -> [TimeSlot] {
        return self.events.group(by: { $0.date }).map { date, events in
            return TimeSlot(date: date, events: events)
        }.sorted(by: { timeSlot, otherTimeSlot in
            return timeSlot.date.compare(otherTimeSlot.date) == ComparisonResult.orderedAscending
        })
    }
}

fileprivate extension TimeSlot {
    var sectionTitle: String {
        return dayAndTimeFormatter.string(from: date)
    }
}
