import Foundation
import UIKit

extension UIView {
    func addFillingSubview(_ subview: UIView) {
        self.addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}

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
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        footer.addSubview(label)
        scheduleTable.tableFooterView = footer
        
        [NSLayoutConstraint(item: label, attribute: .width, relatedBy: .lessThanOrEqual, toItem: footer, attribute: .width, multiplier: 1.0, constant: 0),
         NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: footer, attribute: .centerX, multiplier: 1.0, constant: 0)].activateAll()
        
        
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let stack = UIStackView()
        stack.axis = .vertical
        
        let eventName = UILabel()
        eventName.text = event.name
        stack.addArrangedSubview(eventName)
        
        let eventDetails = UILabel()
        eventDetails.text = "\(event.startTime) - \(event.endTime) - \(event.location)"
        stack.addArrangedSubview(eventDetails)
        
        cell.addFillingSubview(stack)
        
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
