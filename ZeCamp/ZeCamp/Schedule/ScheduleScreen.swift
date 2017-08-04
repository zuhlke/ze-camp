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
        let scheduleTable = ScheduleTableView()

        scheduleTable.strongDataSource = dataSource
        scheduleTable.rowHeight = UITableViewAutomaticDimension
        scheduleTable.estimatedRowHeight = 50
        
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
}

struct TimeSlot {
    let date: Date
    let events: [Event]
}

class ScheduleDataSource: NSObject, UITableViewDataSource {
    
    let timeSlots: [TimeSlot]
    
    init(_ schedule: Schedule) {
        self.timeSlots = schedule.events.group(by: { $0.date }).map { date, events in
            return TimeSlot(date: date, events: events)
        }
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
        
        let label = UILabel()
        label.text = event.name
        cell.addFillingSubview(label)
        return cell
    }
}

fileprivate extension TimeSlot {
    var sectionTitle: String {
        //TODO: time zone?
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, HH:mm"
        return formatter.string(from: date)
    }
}
